---
name: outsystems-integrations
description: Standards for OutSystems integration modules (_IS) that consume external systems (REST, SOAP, SAP, external databases) - one _IS per system, consumed methods and imported structures kept private, public actions with business names that return the team's own lean structure with only the attributes the application needs, attribute mapping and type conversion, and translating external errors into User Exceptions. Use when consuming an API or service, creating or reviewing an _IS module, or deciding what an integration returns to Core.
---

# OutSystems integrations (`_IS`)

An `_IS` module is the only place that knows the external system. Everything else in the application talks to the `_IS` in the team's own terms. When the external API changes, adds 40 fields or renames one, only the `_IS` changes.

## Rules

1. **One `_IS` per external system**: `Weather_IS`, `Salesforce_IS`, `SAP_IS`. Never one `Integrations_IS` for everything (see `outsystems-module-naming`).
2. **Consumed methods and imported structures stay private.** The REST/SOAP methods and the structures Service Studio generates from the API are `Public = No`. Nothing outside the `_IS` references them.
3. **Public actions have business names** and do one business operation: `GetWeatherForecast`, `CreateInvoice`, `GetCustomerByTaxNumber`. Not the API's method names (`GET_v2_forecast_daily`), not `CallWeatherApi`.
4. **Public actions return the team's own structure, with only the attributes the application needs.** If the API returns 30 fields and the application uses 4, the structure has 4 attributes. No "just in case" fields.
5. **The structure has a business name**, singular CamelCase, defined and public in the `_IS`: `WeatherForecast`, not `ForecastResponse`, `WeatherApiResult` or `DailyItem`. Attributes follow `outsystems-crud-conventions`: CamelCase, singular, Booleans `Is`/`Has`.
6. **Convert types at the boundary.** Text dates become `Date` / `Date Time`, numeric text becomes `Integer` / `Decimal`, codes become the team's values (or a static entity reference resolved in Core), `"Y"`/`"N"` become a Boolean. Consumers never parse API text.
7. **The raw response never leaves the `_IS`**: no external structure, no JSON text, no HTTP status code in a public output. Logging the raw request and response, when needed, happens inside the `_IS`.
8. **External errors become User Exceptions** defined in the `_IS`, with a business meaning (`WeatherServiceUnavailableException`, `CustomerNotFoundInCrmException`). Consumers handle exceptions, not status codes or `Success`/`ErrorMessage` pairs.
9. **Endpoints and credentials are configuration**: Effective URL / Site Properties in O11, Settings in ODC. Never hard-coded in the flow.

## Example

The weather API returns one object per day with 30 fields (`dt_txt`, `main.temp`, `main.feels_like`, `main.pressure`, `weather[0].description`, `wind.speed`, `wind.deg`, `clouds.all`, …). The application shows the date, temperature, condition and wind speed.

**Own structure** (`Weather_IS`, `Public = Yes`):

| Attribute | Type | From |
|---|---|---|
| `Date` | Date | `dt_txt` converted from text |
| `Temperature` | Decimal | `main.temp` |
| `Condition` | Text (100) | `weather[0].description` |
| `WindSpeed` | Decimal | `wind.speed` |

**Public action** `GetWeatherForecast` (`Weather_IS`):

```
          Start                     inputs: City (Text), Days (Integer)
            │
     GetForecastDaily               consumed REST method, Public = No
            │
    ◇ Has forecast? ──False──► Raise WeatherForecastNotFoundException
            │ True
     ListAppendAll "Map response to WeatherForecast"
            │                       mapping: 4 attributes, types converted
           End                      output: WeatherForecastList (List of WeatherForecast)
```

- For a single record, map in one Assign labelled `Map response to <Structure>`.
- For a list, use `ListAppendAll` with an element mapping, or a For Each (Cycle connector to the right, see `outsystems-action-flows`).
- Wrap the consumed method in an exception handler that raises the `_IS` User Exception with a readable message.

| Good | Bad | Why |
|---|---|---|
| `GetWeatherForecast` returns `List of WeatherForecast` (4 attributes) | `GetWeatherForecast` returns the imported `DailyItem` (30 attributes) | Core would depend on the API's contract and carry 26 unused fields |
| `WeatherForecast.Date` is a `Date` | `WeatherForecast.dt_txt` is `Text` | Business names and real types at the boundary |
| `_IS` raises `WeatherServiceUnavailableException` | Output `StatusCode = 503` | Consumers handle meaning, not HTTP |
| `Weather_IS` and `Salesforce_IS` | `Integrations_IS` | One system per `_IS` |

## When the application needs one more field

1. Add the attribute to the own structure (business name, real type).
2. Map it in the `_IS` action.
3. Refresh the consumers that use it. Consumers that don't use it are unaffected.

Never switch the public output to the imported structure "to get everything".

## ODC note

The same rules apply. An `_IS` is usually a **library** in ODC (consumed REST APIs are allowed there), with the endpoint in Settings.

## Rules for reviews

Flag as **Critical** any Core or End-user module that references an imported external structure or a consumed method directly. Flag as **Major** a public `_IS` output with unused attributes, text-typed dates or numbers, or a status-code / `Success`-`ErrorMessage` output.
