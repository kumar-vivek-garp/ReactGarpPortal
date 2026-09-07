# Backend request — `register()` drops `riskNetSelected` on the membership form

Raised from the portal rewrite (`garp_portal`), verified against **devjuly25a**
on 7 Sep 2026 by reading the deployed Apex. Nothing in this document has been
changed — it is a request, and the Apex it concerns is not in the portal repo.

## What the portal built

The Individual membership registration form (`type: "mem"`,
`kind: "membership"`), served to guests at `/registration/membership` and to
members at `/membership/register`, as GarpAppv1 serves it. It carries the
Risk.net content-hub add-on as a cart control (product `MEMR`), exactly as
GarpAppv1's `RiskNetCard` does: ticking it sends `riskNetSelected: true` on
**both** `POST examreg/fees` and `POST examreg/register`.

## What blocks it

`riskNetSelected` exists only on the fees request. The register request has no
such field, and the authoritative re-price inside `register()` never sees it.

- `GARP_ExamReg_Dto.FeesRequest` declares `riskNetSelected` (Dto ~line 235).
- `GARP_ExamReg_Dto.RegisterRequest` (Dto ~lines 278–305) does **not**.
- `GARP_ExamReg_RegService.feesRequestFrom(req)` (RegService ~lines 1100–1123)
  copies `membershipSelected` and `autoRenew` from the register request into
  the pricing request but never `riskNetSelected`, so
  `GARP_ExamReg_PricingService.addRiskNet` is a no-op at register time.

**Effect.** A candidate who adds Risk.net sees a quoted total that includes
MEMR (e.g. 295 = MEMI 195 + MEMR 100). At `register()` the order is re-priced
without it: the Opportunity lines, the staged `Priced_JSON__c`, the Stripe
charge and any resumed form all carry 195. The member is not overcharged — but
they are not sold what they added, and the confirmation figure does not match
the quote they agreed to.

GarpAppv1 has the same gap (its `buildRegisterRequest` sends `riskNetSelected`
into a field the DTO silently drops), so this is not new to the portal; the
portal simply makes it visible.

## How to reproduce without writing records

Anonymous Apex inside a savepoint, using the exact JSON the portal sends (the
`register` body from the mocked e2e spec `registration.membership.stripe.spec.ts`
with `riskNetSelected: true`):

```apex
Savepoint sp = Database.setSavepoint();
try {
    GARP_ExamReg_RegService svc = new GARP_ExamReg_RegService();
    GARP_ExamReg_Dto.RegisterResult reg = svc.register(
        (GARP_ExamReg_Dto.RegisterRequest) JSON.deserialize(ourBody,
            GARP_ExamReg_Dto.RegisterRequest.class));
    System.debug('total=' + reg.total); // 195, not 295
} catch (Exception e) { System.debug('FAILED ' + e.getMessage()); }
Database.rollback(sp);
```

## The change we are asking for

1. Add `public Boolean riskNetSelected;` to `GARP_ExamReg_Dto.RegisterRequest`.
2. In `GARP_ExamReg_RegService.feesRequestFrom(req)`, copy it across:
   `fees.riskNetSelected = req.riskNetSelected;`
3. Confirm the MEMR line then lands on the Opportunity (and the staged payload
   under the deferred flow) at `riskNetAmount(unitPrice, monthsLeft, true)`.

No client change is needed once this lands — the portal already sends the flag
on both calls.

## Side notes (no action needed)

- `Form__c` `membership-individual` exists in devjuly25a, so `verifyCustomer`
  opens a `Form_Data__c` session for this form and `Track_CTA__c` is written
  from the `?track_cta=` tag the portal's entry links carry.
- The legacy gated-content upsell appended `garp_gated_url` to the membership
  link. Neither GarpAppv1's form nor any Apex read it, so the portal no longer
  sends it; the tag (`PortalGatedContent`) still travels.

## Impact if nothing changes

The Risk.net card stays visible (a deliberate product decision, matching
GarpAppv1) and quotes a line the order will not carry. Worth fixing before the
membership form takes real money.
