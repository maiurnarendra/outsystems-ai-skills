# Code review: report example

Reference for `outsystems-code-review`, step 6. The verdict rules are in [../SKILL.md](../SKILL.md#6-report).

```
# Code review: ORD-123 Add discount to orders
Scope (confirmed): Order_CS › Order_CreateOrUpdate; Order_BL › GetOrderById, ApplyDiscount

## Verdict: Needs changes        (Ready | Needs changes | Blocked)

## Spec
| # | Acceptance criterion                         | Verdict      | Evidence |
| 1 | Discount is stored on the order              | Met          | Order_CreateOrUpdate › Assign "SetUpdateFields" |
| 2 | Discount cannot exceed 20%                   | Not found    | ApplyDiscount has no check on Discount |
| 3 | Total shows the discounted value             | Needs testing| Screen OrderDetail; test with 0%, 20%, 21% |
Out of scope: ApplyDiscount also recalculates shipping (not in the story).

## Standards
### Critical
- Order_CS → Order_BL reference (upward). Move ApplyDiscount out of Order_CS.
### Major
- ApplyDiscount › If "If1": label it "IsDiscountValid".
### Minor
- GetOrderById › SQL "GetOrder": `join` in lowercase on line 4; use `INNER JOIN`. (pre-existing?)

## Service Studio messages
- Warning: Order_BL › GetOrderById › Aggregate "GetOrders" returns more records than used.

Summary: Spec 1/3 met, 1 not found, 1 needs testing · Standards 1 critical, 1 major, 1 minor.
```
