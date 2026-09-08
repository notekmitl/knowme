# PR115 machine-local path sanitation ledger

This ledger records the authorized evidence/status sanitation applied after Owner Product Acceptance. It is bound to base `cd2718f6cfb6aff66ca46ebe6811e2a56379a8d7` and accepted evidence HEAD `44949815a08139b25b376d473b9495372197d17a`.

The initial PR-diff scan found exactly **98** machine-local occurrences across the ten authorized files. Because several authorized status/evidence files also retained older paths already present at the base, the controlled rewrite sanitized **286** file occurrences in total. No original absolute path value is reproduced in this ledger.

| File | Before SHA-256 | After SHA-256 | PR-diff occurrences | File occurrences | Replacement |
| --- | --- | --- | ---: | ---: | --- |
| `TASK_RESULT.md` | `366E9943E74AB1F6205E13E4BD2D491B6D030D014B9DA67C322B7669028650B7` | `866007346045A630953DCA57EDCB7E6A3DB809BEED58E7E0FFE2AA15DF30AF04` | 6 | 28 | artifact name only |
| `task.md` | `B1EB5CF6C73486D4EAB348104517EA2EE2857574E28A7DC1752B1976A1E8163D` | `00142E625429A4C5D57EE551CC1D335BA7BDE1B57381D4E37BA77A23AD978A2C` | 6 | 24 | artifact name only |
| `docs/CURRENT_STATUS.md` | `F65628835429A85412E53591C119D2901992DD9D31FD81F56A7853E67F19D4C3` | `8BBCB5F1BDD0CA579B914734C33668B89027FFC3CCC6538BE5B8961FC5F74D1A` | 6 | 23 | artifact name only |
| `docs/HANDOFF.md` | `720669C506884AA589CA6CA5EDAD42D3E18FB44FEE9AF214905ADFE7CCEF202A` | `E42EB8C168AE3F0E81A9AFF9184549DFF64EB9B8995986E13B9E22DD22B46D5F` | 6 | 33 | artifact name only |
| `docs/ROADMAP.md` | `323A23FE74DAD792475C8087C540FA6BFB4FA732F5918A36C310A759C74F5A6C` | `1E8E6689297DEA27200025FCFBB2508BF40E08EE2F79727C7A69E164D1EEA1EB` | 6 | 16 | artifact name only |
| `docs/THAI_REPORT_READER_EXPERIENCE_V2.md` | `6F5896F9292C657D2CDE4C9D610D6FD90D9A36EF985987E8627FAFF4D205E208` | `5FA229990DFA94882B5A38AB9EA4A27FECC237B93527DE32380A6219C5274A7F` | 6 | 21 | artifact name only |
| `docs/OR4_CLOSEOUT.md` | `2BEF7BAB152786A103207C82B0A42CDA589A7B2CCE6A71ADC8375270938147CE` | `98A91A36FE7015C88359A1EEE2186906F26E8E08EBEDE2DD6208EE11111DDA10` | 1 | 1 | artifact name only |
| `docs/OR5R_FAILURE_CLASSIFICATION.json` | `F7565D7841D63F81E73EDB53C21D3264B2978A6ACAA79F176EB67B7787F1AAF8` | `EAF55E16216376D3C0ED3D5AADF90036346F3D5DC92D6ED64CF2298E1C74F0B3` | 3 | 6 | `<REPO_ROOT>/` |
| `docs/OR5R_FULL_SUITE_FIRST_RUN_FAILURES.json` | `B01D00A7358FB951A339527FF453D69BB3DD68D34C0376D10747736A02AE28D3` | `850BB36D29C961A360EFB1DB38E100F2D65BA8601D3285DBB98E0F85C67ED3C5` | 29 | 67 | `<REPO_ROOT>/` |
| `docs/OR5R_FULL_SUITE_GATE_FAILURES.json` | `49EFADB846FEC0BE35A18ABBF6269158BB6A250BA61D3764CE5E0066ED4B3CD9` | `9C5F4B5ED70851DCDD1150882267DEB7FE14270E1CF783B47623168E5DD1FA79` | 29 | 67 | `<REPO_ROOT>/` |

JSON parsing passes for all three JSON evidence files. Their top-level schemas and record counts remain 76, 78 and 76 respectively before and after sanitation. Original failure totals remain 1,568/76 for the classified gate evidence, 1,566/78 for the first run, and 1,568/76 with gate exit 22 and Flutter exit 1 for the gate run. Failure records removed, historical outcomes changed, schema mismatches and record-count mismatches are all **0**.

Validation compares each resulting file with the exact authorized transformation of its accepted-HEAD blob. Exact-transform mismatches, JSON parse errors and remaining machine-local paths are all **0**. The transformation changes location prefixes only; filenames, line numbers, failure messages, diagnostic details, test counts, root-cause descriptions and existing artifact hashes are preserved.
