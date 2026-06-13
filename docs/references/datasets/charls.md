---
kind: dataset-reference
dataset: charls
status: active
deidentified: true
source: CHARLS public questionnaire & wave documentation
---

# CHARLS — Engineering Reference

> De-identified engineering facts for the China Health and Retirement Longitudinal
> Study (CHARLS). All facts below are public questionnaire / wave-documentation
> knowledge. No achieved result numbers; no private paths.

## 1. File naming across waves
- 2011: module filenames all **lowercase** (e.g. `family_transfer.dta`, `demographic_background.dta`).
- 2013+: **CamelCase** (e.g. `Family_Transfer.dta`, `Demographic_Background.dta`).
- 2018: some modules renamed (e.g. `Work_Retirement.dta`, not `Work_Retirement_and_Pension.dta`).
- Module availability varies by wave (e.g. no `Health_Care_and_Insurance.dta` in 2020).
- Always resolve with `find_file(wave_dir, *candidates)`; never hardcode one filename.

## 2. Key columns & ID format
- Merge keys: `ID`, `householdID`, `communityID`, plus `WAVE`.
- **ID length differs by wave** (2011 = 11 chars, 2013+ = 12 chars). Cross-wave
  baseline filling by raw ID fails without an official crosswalk file. Document this
  limitation; never silently assume the fill succeeded.

## 3. Wave-specific demographic variable routing
Variable names and "preloaded" (Z-prefix in 2013) conventions change across waves:

| Concept | 2011 | 2013 | 2018 |
|---|---|---|---|
| Birth year | `BA002_1` | `ZBA002_1` (preloaded) then `BA002_1` | `BA004_W3_1` |
| Gender | `RGENDER` | not in demo file — fill from 2011 baseline | `XRGENDER` |
| Hukou | `BC001` | `ZBC001` (preloaded) | not in demo file — fill from baseline |
| Marital | `BE001` | `BE001` | `BE001` |
| Education | `BD001` | `ZBD001` (preloaded; `BD001` = sparse update) | `BD001_W2_4` |

When a variable is "preloaded" (Z-prefix in 2013), use it when the direct variable is
sparse (update-only): always coalesce `series.fillna(other_series)`.

## 4. Variable encoding gotchas
These follow from the public questionnaire structure and value codings:

**Education (`BD001`):** value 4 = primary-school graduate (小学毕业, "primary or
less"); value 5 = middle school (初中毕业). "Middle school and above" threshold is
`BD001 >= 5` (not `>= 4`).

**Health insurance (`EA001S` / `EA001_W4_S`):**
- 2011/2013: multi-select, each variable is **NULL when not selected** → detect with
  `.notna().any()`.
- 2018: multi-select, each variable is **0 when not selected** → detect with
  `(df[ins_cols] != 0).any(axis=1)`.
- "No insurance" sentinel: `EA001S10` (2011/2013) / `EA001_W4_S12` (2018).

**Marital status (`BE001`):** value 1 = married living together; value 2 = married
living apart. For "Married vs Others", values 1 AND 2 are both married → `BE001 > 2`
selects "others".

**Non-agricultural employment (2011/2013):** `FA001=1` (agricultural) respondents are
routed **away** from `FA002` and never answer it. Construct as
`FA002==1 OR FC014==1 OR FA003==1 OR FC015==1`; do NOT use `FA002` alone (it misses the
agri+non-agri group).

**Agricultural employment:** use `FC001` ("worked for OTHER farmers for wage"), not
`FA001` ("any agricultural work ≥10 days", which includes own-farm).

**City identification (for policy-pilot subsamples):** PSU.dta (2011/2013) has a `CITY`
string field (Chinese city name) — match by partial string. 2018 has no PSU file; use
`Sample_Infor.dta` + community-ID mapping from 2011/2013 PSU.
