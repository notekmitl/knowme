# Production-date reproduction

The exact application session timestamp is unavailable. The narrowest evidenced Production interval is `2026-08-16T09:15:15.572116Z` to `09:19:44.4545351Z`, equivalent to `16:15:15.572116` to `16:19:44.4545351` Asia/Bangkok.

Explicit VM replays across that interval retain the accepted canonical hash and do not produce either rollback mismatch phrase. Thus Production date alone does not reproduce the defect.

The pre-repair compiled Web application using the same source, assets, fixture and Production-date input does reproduce the rollback Production extracted text byte-for-byte:

- original Production PDF: 39,370 bytes; SHA-256 `5F706E04462DEA15716F09C3B8230C03DA34D2CF02B9C0C3E11BBBFCDC47C49B`
- local pre-repair compiled-Web PDF: 39,370 bytes; binary SHA differs as expected
- extracted canonical text equality: exact
- shared extracted-text SHA-256: `6BAD114543DF6163357F25F51A4594927FC3E6E846571AA6C356A6E6BD2DC800`

After stable hashing, the compiled Web Owner fixture contains the accepted finance and next-transition phrases. The post-repair actual browser PDF is 7 pages and passes visual inspection. The final five-fixture live oracle separately proves same-`asOf` Web/PDF parity and repeat determinism 5/5.
