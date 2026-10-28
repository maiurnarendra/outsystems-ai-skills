# Front-end (Reactive Web and Mobile)

Start in the browser: **Console** for errors, **Network** for failing or slow requests, **Elements** for what was actually rendered. Then read the JavaScript node, block or screen in the model.

## JavaScript nodes

| Symptom | Usual cause | Fix |
|---|---|---|
| `TypeError: Cannot read properties of undefined` / `null` | DOM element not rendered yet (code in **OnInitialize**), a widget Id that does not exist, or a missing input | DOM work goes in **OnReady** (once) or **OnRender** (every render); pass `WidgetName.Id` as an input; check `$parameters` names |
| `$parameters.X` is `undefined` | Input not declared on the JavaScript node, or a typo; output never assigned | Declare the input; assign outputs with `$parameters.Out = …` |
| Code after `$actions.SomeAction()` runs too early | Client actions called from JavaScript return a **Promise** | `$actions.SomeAction().then(…)`, or `await` inside an async function |
| The JavaScript node "finishes" before async work does | Asynchronous code (timers, fetch, callbacks) in a node that ends immediately | Use `$resolve()` / `$reject()` in the node so the flow waits for it |
| Event fires twice, three times, more after each navigation | `addEventListener` / `setInterval` added in OnReady/OnRender/OnInitialize and never removed | Keep the handler or interval id, remove it in **OnDestroy**; never attach listeners in OnRender |
| Polling never stops / CPU stays high | `setInterval` waiting for something that never appears, with no limit | A maximum number of attempts or a timeout, and `clearInterval` in OnDestroy |
| Changes made with JavaScript disappear | Reactive re-renders the block and overwrites manual DOM changes | Change **variables** and let OutSystems render; touch the DOM only for what OutSystems can't express |
| Works after a delay, fails sometimes | `setTimeout` used to wait for rendering or data (a race) | Wait for the real event: OnReady, OnAfterFetch, the component's own event |
| `X is not defined` for a library | Script not loaded, or loaded after it is used | Add it to the screen/block **Required Scripts**, or `RequireScript` before use; check load order |
| Works in Development, fails after publish in another environment | Cached old resources, or an environment-specific URL in JavaScript | Hard refresh / clear cache to confirm; read URLs from Site Properties / Settings passed as inputs |

## Forge components (OutSystems UI, Data Grid, …)

- Use the component's **client actions and events** (`Set…`, `Get…`, `OnInitialize`) instead of reaching into its internal DOM or JavaScript objects. Internals change between versions.
- Errors right after an upgrade: compare the component version in each environment, and its release notes.
- Wait for the component's initialised event before calling its API; don't poll for it.

## Blocks and events

- **OnParametersChanged** runs whenever an input changes. Refreshing data or triggering events there without comparing old and new values causes loops and refresh storms.
- A block that changes its own input, or raises an event whose handler changes the block's input, re-renders in a loop.
- Event handlers that pass a **local** list must pass the updated list, not the original input (a common copy-paste bug).

## CSS and layout

- **Block and screen styles are global** once loaded: a rule in one block can change another screen. Scope rules with a block-specific class.
- Theme vs screen order: check which rule wins in DevTools › Elements › Styles; avoid `!important` as a fix.
- Different results per browser: check the feature in the browser's compatibility table before rewriting.

## Mobile

- Plugins don't run in the browser preview: check plugin availability (the plugin's "Check…" action) before calling it.
- Plugin or native setting changes need a **new app build**; publishing the module is not enough.
- Offline sync issues: log the sync steps and check the server-side `_Sync` / `_MBL` actions in the Errors log.

## Security notes while debugging

- Everything in client-side JavaScript is visible to the user: no secrets, keys or hidden business rules there.
- Validation in JavaScript is for usability only; the server action validates again.
- Never use `eval` or build HTML from unescaped input.
