# Backend request — study material details on `examreg/info`

Raised from the portal rewrite (`garp_portal`), verified against **devjuly25a** on
26 Aug 2026. Nothing in this document has been changed — it is a request, and
the Apex it concerns is not in the portal repo.

## What the portal wants to build

An info control on each item in the registration form's *Add to your
registration* rail, opening a short description of the product — the same copy
already published on garp.org (intro, the bulleted list of themes, and the
`Note:` paragraph).

## What blocks it

`examreg/info` returns **`description: null` for every study material.**

Verified by executing the load service directly rather than by reading the
client:

```apex
GARP_ExamReg_Dto.LoadResult vm = new GARP_ExamReg_LoadService().load('frm', null, null);
for (GARP_ExamReg_Dto.StudyMaterialVM m : vm.studyMaterials) {
    System.debug(LoggingLevel.ERROR, m.productCode + ' descNull=' + (m.description == null));
}
```

```
FRM1BPPE  descNull=true
FRM1H     descNull=true
FRM2H     descNull=true
FRMBP     descNull=true
FRMBP2    descNull=true
FRMC2     descNull=true
```

**Cause.** `GARP_ExamReg_LoadService` maps:

```apex
m.description = pbe.Product2.Customer_Description__c;
```

`Product2.Customer_Description__c` is **empty on all 14** study-material
products. It looks like the wrong source field rather than missing data.

## The data does exist — on the linked `Content__c`

Checked across every `Content__c` whose `Content_Name__c` starts with `2026`
(22 records, covering FRM, SCR, RAI and RAIJ including the Japanese records).
**All 22 have both fields populated**, so this is a plumbing gap, not a content
gap.

| Field | Length (FRM1H) | Content |
|---|---|---|
| `Content__c.Description__c` | 114 | *"Get print copies of our complimentary eBooks, including all the readings and themes that comprise the Part I Exam."* |
| `Content__c.Story__c` | 584 | The full published copy — intro paragraph, `<ul>` of the four Part I themes, and the `Note:` paragraph. HTML. |

## The change we are asking for

**Option A — one line, restores `description`.**
`GARP_ExamReg_Selector` **already queries** `Product2.Content__r.Description__c`
(it is in the SOQL string today) and the value is then discarded. So only the
mapping needs to change:

```apex
m.description = pbe.Product2.Content__r != null && pbe.Product2.Content__r.Description__c != null
    ? pbe.Product2.Content__r.Description__c
    : pbe.Product2.Customer_Description__c;
```

No SOQL change, no DTO change, no new field on the wire.

**Option B — the full published copy.** Requires all three:

1. add `Product2.Content__r.Story__c` to the selector's SOQL,
2. add a field to `GARP_ExamReg_Dto.StudyMaterialVM` (suggest `story`),
3. populate it alongside `description`.

### One request about Option B

`Story__c` is raw HTML. If it is returned as-is the portal has to sanitise it
before rendering — we do not use `dangerouslySetInnerHTML` anywhere today and
have no sanitiser dependency, so this would be the first. **Plain text, or a
whitelisted/structured shape, would be preferred** if that is cheap on your
side. If HTML is the only practical answer that is workable, we will add
DOMPurify — we would just rather know it is deliberate.

## Impact if nothing changes

The info control is not built. `description` stays on the contract as a field
that is always null, which is worth knowing in its own right: any other client
reading it is getting nothing.

## Not urgent

No portal work is blocked behind this — the registration form ships without it.
Whichever option suits, tell us which field will carry the copy and we will
build against it.
