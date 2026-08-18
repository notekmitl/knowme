# Pre-production release record

- Project/site: `knowme-app-694e1`
- Source and final main: `642069f0f298bc8a1f86b795f043e02e914aa97d`
- Production live before deploy: release `1786872330369000`, V1.4 version `10af10c6d960d590`
- Rollback channel: `v15-rerun-v14-rollback`
- Rollback release: `1787030431383000`
- Rollback version: `10af10c6d960d590`
- Validated Preview: release `1787036689380000`, version `95bbd383a56dee39`
- Hosting deploy set: 77 files, 44,183,660 bytes
- Hosting manifest SHA-256: `A1A7EAB6260D1168C5229FF3FAAB7324BF0567AF4300DC79D885041D2319091D`
- Hosting `SHA256SUMS.txt` SHA-256: `2AB8447EC1358F739BC7CDFCE8BC6BAE2C297A5400A64E144BD9A57385389B1A`
- Immediate pre-deploy build recheck: 77/77, missing 0, mismatch 0, unexpected 0
- Authorized command: `firebase deploy --only hosting --project knowme-app-694e1 --non-interactive`
- No Firestore, Auth, Functions, Storage, Remote Config, rules, indexes, or other Firebase resource is in scope.
- Rollback command if a post-deploy critical gate fails: `firebase hosting:clone knowme-app-694e1:v15-rerun-v14-rollback knowme-app-694e1:live --project knowme-app-694e1 --non-interactive`

