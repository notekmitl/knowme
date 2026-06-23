# KnowMe Public Deployment

Public beta is served as a **Flutter Web** build on **Firebase Hosting** against the production Firebase project **`knowme-app-694e1`**.

---

## Public URLs

| URL | Purpose |
|-----|---------|
| https://knowme-app-694e1.web.app | **Primary** public beta URL |
| https://knowme-app-694e1.firebaseapp.com | Alternate Firebase Hosting URL (same deployment) |

Firebase Console: https://console.firebase.google.com/project/knowme-app-694e1/overview

---

## Hosting Provider

**Firebase Hosting** (Option A — lowest risk; same project as Auth + Firestore)

---

## Firebase Project

| Setting | Value |
|---------|--------|
| Project ID | `knowme-app-694e1` |
| Web App ID | `1:239840538753:web:5edbf627980612ae9c9d80` |
| Auth domain | `knowme-app-694e1.firebaseapp.com` |
| Firestore | Enabled (production rules in Firebase Console) |
| Flutter config | `lib/firebase_options.dart` |

---

## Prerequisites

- Flutter SDK (stable 3.41+ tested)
- Firebase CLI (`npm install -g firebase-tools` or standalone installer)
- Logged in: `firebase login`
- Access to Firebase project `knowme-app-694e1`

---

## Build & Deploy

### Full production deploy (astrology API + web)

```powershell
.\scripts\deploy_astrology_api.ps1
.\scripts\deploy_web.ps1
```

`deploy_web.ps1` reads `config/astrology_api_base_url.txt` (written by API deploy) and injects:

`--dart-define=ASTROLOGY_API_BASE_URL=<Cloud Run URL>`

### Web only (after API URL is configured)

```powershell
.\scripts\deploy_web.ps1
```

### One command (Windows) — legacy alias

```powershell
.\scripts\deploy_web.ps1
```

### Manual steps

```powershell
# Read URL from config/astrology_api_base_url.txt
flutter build web --release --no-wasm-dry-run --dart-define=ASTROLOGY_API_BASE_URL=<cloud-run-url>
firebase deploy --only hosting --project knowme-app-694e1
```

Build output: `build/web/` (gitignored; generated on each deploy)

---

## Configuration Files

| File | Role |
|------|------|
| `config/astrology_api_base_url.txt` | Production Cloud Run API base URL (no trailing slash) |
| `scripts/deploy_astrology_api.ps1` | Build + deploy FastAPI backend to Cloud Run |
| `scripts/verify_astrology_api.ps1` | Health + generate endpoint smoke check |
| `.firebaserc` | Default Firebase project |
| `firebase.json` | Hosting `public`, SPA rewrites, cache headers |
| `web/index.html` | Web shell (viewport, PWA meta) |
| `lib/firebase_options.dart` | FlutterFire platform keys (web included) |

### SPA routing

All paths rewrite to `/index.html` so browser refresh on deep links does not 404.

### Authentication (Web)

- Email/password: Firebase Auth (standard)
- Google: `FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider())` in `AuthProvider`
- Facebook: `signInWithPopup(FacebookAuthProvider())`

**Firebase Console checks (if OAuth fails on web):**

1. Authentication → Sign-in method → enable Email, Google, Facebook as needed
2. Authentication → Settings → Authorized domains must include:
   - `knowme-app-694e1.web.app`
   - `knowme-app-694e1.firebaseapp.com`
   - `localhost` (local dev)

Google OAuth redirect URIs are managed by Firebase for the web app; no extra redirect URI is required for Hosting domains when using `signInWithPopup`.

---

## Required Secrets (do not commit)

| Secret | Location | Used for |
|--------|----------|----------|
| Firebase service account JSON | `backend/firebase/serviceAccountKey.json` (gitignored) | Admin scripts, Firestore export only — **not** web deploy |
| Google Places API key | `lib/presentation/widgets/location_picker.dart` | Birth-place autocomplete (web + mobile) |

Web deploy uses **public** Firebase web API keys in `firebase_options.dart` (expected for client apps). Restrict keys in Google Cloud Console by HTTP referrer:

- `https://knowme-app-694e1.web.app/*`
- `https://knowme-app-694e1.firebaseapp.com/*`
- `http://localhost:*` (dev)

---

## Rollback

### Option 1 — Firebase Console

Hosting → Manage → Release history → Roll back to previous version

### Option 2 — CLI

```powershell
firebase hosting:clone knowme-app-694e1:PREVIOUS_VERSION_ID knowme-app-694e1:live
```

List versions:

```powershell
firebase hosting:releases:list --site knowme-app-694e1
```

### Option 3 — Redeploy from git

```powershell
git checkout <known-good-commit>
flutter build web --release --no-wasm-dry-run
firebase deploy --only hosting --project knowme-app-694e1
```

---

## Custom Domain (optional)

1. Firebase Console → Hosting → Add custom domain
2. Add DNS records at registrar (Firebase provides A/TXT)
3. Wait for SSL provisioning
4. Add custom domain to Auth → Authorized domains
5. Add domain to Google Cloud API key HTTP referrer restrictions

---

## Local Web Development

```powershell
flutter run -d chrome
# or
flutter build web --release
cd build/web
python -m http.server 8080
```

Use `http://localhost` for Firebase Auth local testing (authorized by default).

---

## Validation Checklist (post-deploy)

- [ ] https://knowme-app-694e1.web.app loads login screen
- [ ] Email/password login with existing Firestore user
- [ ] Google sign-in popup (if enabled in console)
- [ ] Profile setup / Home V3 loads after auth
- [ ] Astrology + MBTI flows reachable
- [ ] Funnel telemetry writes under `users/{uid}/funnel_telemetry/`
- [ ] Mobile browser (responsive viewport)
- [ ] Hard refresh on `/` does not 404

---

## Known Web Limitations

- **Wasm build:** Not used; deploy with `--no-wasm-dry-run` (Places/Geolocator use dart:html).
- **Facebook login:** Requires Facebook app configured in Firebase Console; may be blocked by browser privacy settings.
- **Firestore rules:** Not in repo; managed in Firebase Console. Web clients need authenticated-user rules for production data.

---

## Deploy History

| Date | Version | Notes |
|------|---------|-------|
| 2026-06-22 | Public Deployment V1 | Initial Firebase Hosting beta; UX Conversion Sprint V1 Home |
