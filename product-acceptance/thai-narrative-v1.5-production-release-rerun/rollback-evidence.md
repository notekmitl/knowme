# Rollback evidence

Before the functional gate, the current live V1.4 Hosting channel was cloned to Preview channel `v15-rerun-v14-rollback`. Firebase reports that channel referencing exact version `10af10c6d960d590`, release `1787030431383000`, with seven-day expiry.

Had Production changed and a mandatory trigger occurred, the prepared Hosting-only command would have been `firebase hosting:clone knowme-app-694e1:v15-rerun-v14-rollback knowme-app-694e1:live --project knowme-app-694e1 --non-interactive`.

The command was not executed because Production was never deployed. Live remains release `1786872330369000` / version `10af10c6d960d590`.
