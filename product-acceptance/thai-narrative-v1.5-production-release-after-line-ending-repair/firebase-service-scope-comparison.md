# Firebase service scope comparison

The only mutating Production command was:

`firebase deploy --only hosting --project knowme-app-694e1 --non-interactive`

The raw deploy log reports only `deploying hosting`, 77 files, version finalization, and Hosting release. No Firestore, Auth, Functions, Storage, Remote Config, rules, indexes, App Distribution, or mobile deployment command was executed. The Preview command also targeted Firebase Hosting only. Therefore the authorized mutation scope is Hosting only; non-Hosting Firebase service mutation count is 0.

Before Production, live was V1.4 release `1786872330369000` / version `10af10c6d960d590`. After Production, live is V1.5 release `1787038542564000` / version `5f98dfffef913e38`. The rollback Preview continues to reference exact V1.4 version `10af10c6d960d590`.

