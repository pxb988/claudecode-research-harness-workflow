# Example: Basic Data Cleaning

This example walks through the audit and cleaning stages of the Research Agent Harness using a single synthetic household survey CSV.

---

## What this example demonstrates

| Stage | Command | Output |
|---|---|---|
| Setup | `/research-harness-setup` | `study_spec.md`, folder structure |
| Audit | `/research-harness-audit` | `4.reports/data_audit_report.md` |
| Clean | `/research-harness-clean` | `3.outdata/data/households_clean.csv`, `4.reports/data_cleaning_report.md` |

---

## File structure

```
basic-data-cleaning/
├── README.md                               ← you are here
├── study_spec.md                           ← pre-filled for this example
├── 1.rawdata/
│   └── households.csv                      ← synthetic data (200 rows)
├── 4.reports/
│   └── data_cleaning_plan.md               ← pre-filled cleaning plan
└── 0.dofiles/
    └── clean_households.R                  ← stub cleaning script
```

After running the harness commands, these will be created:

```
├── 3.outdata/data/households_clean.csv
├── 0.dofiles/logs/audit_YYYYMMDD.log
├── 0.dofiles/logs/clean_YYYYMMDD.log
└── 4.reports/
    ├── data_audit_report.md
    └── data_cleaning_report.md
```

---

## Quickstart

```bash
/research-harness-audit
# Review 4.reports/data_audit_report.md
# Then:
/research-harness-clean
```

---

## What to notice

- The audit report will flag `income_annual` for using `-9` as a missing code
- The audit report will flag `hh_size` for 3 outlier values (> 15)
- The cleaning script drops 8 observations with missing `hhid`
- The cleaning script recodes `-9` to `NA` across income variables
- The final `3.outdata/data/households_clean.csv` has 183 rows (200 − 8 missing ID − 9 out-of-scope region)
- Every dropped observation is documented with reason and count
