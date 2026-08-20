# Membership card (My Account) — auto-renew, Renew Now, Stripe setup

**Purpose:** Record how MyGarp actually behaves, what GarpAppv1 / `GARP_Portal_*` already expose, and what `garpportal` must do on `my-account?tab=account-information`. Use this when talking to the backend team.

**Constraint:** New portal uses Apex REST (`/services/apexrest/memberportal/*`) via `sdk.fetch`. Do **not** collect card PAN/CCV in React. Do **not** call `@RemoteAction` / `garpAppRemoter`. Do **not** load `GET …/membership` on this tab (that is the benefits catalogue).

| Repo | Role |
|------|------|
| **MyGarp** | UX source of truth. Two Angular apps: older **garpApp2** (credit-card *dialog* + remoting) and current **garpApp** (REST-shaped remoting + **Stripe Checkout setup**). Sandbox matches **garpApp**. |
| **GarpAppv1** | REST catalog. `POST membershipAutoRenewOn` / `Off` exist in `portalApi.ts`. The My Account card only wired **turn off**; Turn On was left as a comment. |
| **garp_portal** | Implement the card from `GET account.standing` + the same On/Off actions. |

---

## 1. Scenarios (sandbox / garpApp)

These are **client** branches on top of standing + one write API. Stripe Checkout and `sfdcApp` registration are **site pages**, not JSON from Apex.

### 1.1 Auto-renew off (Individual, not expired, no pending order)

- Red callout: “Auto renew is off… on **{expire date}**.”
- Link **Turn On Auto-Renew**.
- Footer **Renew Now** (enabled).

### 1.2 Turn On Auto-Renew

`enableAutoRenew()`:

1. `POST` enable (legacy remoting `setAutorenewMembershipOn`; new stack `membershipAutoRenewOn`). Empty body.
2. If `statusCode === 200` and `needPaymentInfo === true` → `location.href = "/stripe_checkout?mode=setup&id=" + orderId`.
3. If `200` and not `needPaymentInfo` → reload standing (Stripe already has a card; subscription is done).
4. If `statusCode === 201` → reload standing (legacy only; Apex currently uses 200/401/500).

**Stripe page** (not React): `…/stripe_checkout?mode=setup&id={opportunityId}` — SetupIntent / save payment method. “Return to My Account” is on that VF/LWC page.

If `orderId` is missing, the URL becomes `id=undefined` (same as legacy JS string concat). Frontend does not invent an Opportunity Id.

### 1.3 After Stripe save — `?status=autorenewsetupcomplete`

Checkout redirects to My Account with **`status=autorenewsetupcomplete`** (query on the portal URL; written by the checkout page, not by `GET account`).

On load, if that query is present **and** `isAutoRenewEnabled` is still false:

- `isAutoRenewPending = true`
- Disable Turn On / Disable Auto Renew (treat as in-flight)
- Copy: **“Auto-Renew is being setup, please check back later.”**
- **Renew Now** still listed but **disabled**

When standing later shows auto-renew on (async Contract / Recurring Opp), the green callout and **Disable Auto Renew** appear. Relogin **without** the query param drops the pending copy even if Stripe is still catching up — that is why disable/on can look inconsistent.

### 1.4 Auto-renew on

- Green callout: prevailing rate **USD 195** (or **150** if `isCertHolder`). Amounts are **hardcoded in the client**, not Apex.
- Footer **Disable Auto Renew** → `POST membershipAutoRenewOff`.

Turn off 401s if the contract is not `Activated ( Auto-Renew )` or there is no Recurring Opportunity. After a successful Stripe setup, standing can lag; Disable can fail until the contract status flips. Relogin showing auto-renew **on** again usually means turn-off did not stick (Apex 401 or Stripe still recurring) — not a missing GET.

### 1.5 Renew Now / Upgrade

**Static site URL** (UtilitiesService, not backend):

`/sfdcApp?track_cta=PortalMyAccountPage#!/registration/membership`

Example: `https://garp--devjuly25a.sandbox.my.site.com/sfdcApp?track_cta=PortalMyAccountPage#!/registration/membership`

Adds another year of membership via the **legacy registration** app (`sfdcApp`). Same CTA for Affiliate **Upgrade**. `track_cta` is a query string; the hash is Angular routing.

### 1.6 Pending unpaid membership order

Standing `pendingOrderId` set (Apex skips Stripe `Create` mid-checkout). Status line **Payment Pending**. Footer **View Order** (legacy `/order-details/:id`; rewrite uses Order History tab). Auto-renew callouts hidden.

### 1.7 Expired

Intro: “Renew your Individual Membership…”. Status Lapsed / expired date. No Turn On callout (`memberStatus === "Expired"`). Renew Now still shown if Individual and no pending order.

---

## 2. APIs (already in this repo)

| Action | Method | Notes |
|--------|--------|--------|
| `GET /memberportal/account` | standing on `AccountView` | Contract wins over Contact identity. `null` if no Membership contract. |
| `POST /memberportal/membershipAutoRenewOn` | `{ needPaymentInfo, orderId?, statusCode }` | Delegates to `GARP_BC_Membership.enableAutoRenew`. `needPaymentInfo` = order staged, **no** subscription until a payment method exists. |
| `POST /memberportal/membershipAutoRenewOff` | no body | Stops Recurring Opportunities, contract → `Activated`. 401 if not currently auto-renew. |

**Not used on this tab:** `GET /memberportal/membership`.

**Not in new REST:** `setAutorenewMembershipOnCreateOrder` / `PayOrder` / `VoidOrder` (garpApp2 card dialog). Current MyGarp does not use that path for Turn On.

---

## 3. Standing fields (`GARP_Portal_Core.Standing`)

`garpId`, `memberType`, `memberStatus` (verbatim, e.g. `Activated ( Auto-Renew )`), `statusLabel` (Active / Lapsed), `dateJoined`, `expirationDate`, `isAutoRenewEnabled`, `isCertHolder`, `pendingOrderId` / `Number` / `Amount`.

`isAutoRenewPending` is **not** an Apex field — it is `status=autorenewsetupcomplete` **and** `!isAutoRenewEnabled`.

---

## 4. Questions for backend (if disable/on still flaps)

1. Confirm `returnEnableAutoRenew` includes **`orderId`** (Opportunity Id) when `needPaymentInfo` is true.
2. After setup-mode Checkout, when does Contract become `Activated ( Auto-Renew )`? Is `autorenewsetupcomplete` the intended client pending signal?
3. Turn-off 401 “Opportunity not found” while Stripe still bills — expected race?
4. Should renewal USD amounts come from pricebook (MEMI/MEMC) instead of 195/150?

**This app will not collect card numbers.** Payment method collection stays on `/stripe_checkout?mode=setup`.
