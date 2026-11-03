# HireLoop — Flutter App (Provider)

Flutter frontend for the AI CV Generator flow, using the **Provider** package
for state management and talking to the `resume_api` FastAPI backend.

## Structure

```
lib/
├── main.dart                          MultiProvider setup + MaterialApp
├── models/cv_form_data.dart           Mirrors the backend's Pydantic models
├── services/api_service.dart          HTTP calls to FastAPI (/generate, /pdf, /docx...)
├── providers/
│   ├── auth_provider.dart             Session + saved resume (ChangeNotifier)
│   └── resume_form_provider.dart      Multi-step form state + generate()
├── theme/app_theme.dart               Colors + ThemeData (blue/white)
├── widgets/app_widgets.dart           GlassCard, AppPrimaryButton, RemovableChip
└── screens/
    ├── login_screen.dart              Email/password + upload/generate CTAs
    ├── choice_screen.dart             Upload vs AI generate
    ├── upload_cv_screen.dart          Pick PDF/DOCX, replace/delete
    ├── ai_cv_generator_screen.dart    12-step form (Personal → References)
    ├── generating_screen.dart         Progress + skeleton loading animation
    ├── resume_preview_screen.dart     A4 preview, ATS score, PDF/DOCX/Save
    ├── dashboard_screen.dart          "My Resume" — view/download/edit/replace
    └── apply_flow_screen.dart         Uses saved resume or prompts to add one
```

## Setup

```bash
flutter pub get
flutter run
```

### Point the app at your API

Edit `lib/main.dart`:

```dart
ChangeNotifierProvider(
  create: (_) => ResumeFormProvider(ApiService(baseUrl: "http://10.0.2.2:8000")),
),
```

- `10.0.2.2:8000` → Android emulator talking to `resume_api` running on your
  machine (`uvicorn main:app --reload --port 8000`).
- iOS simulator → use `http://localhost:8000`.
- Physical device → use your machine's LAN IP, e.g. `http://192.168.1.5:8000`.
- Production → your deployed API URL, e.g. `https://api.hireloop.app`.

## How state flows

1. `AICVGeneratorScreen` reads/writes `ResumeFormProvider.data` (a `CVFormData`)
   across all 12 steps.
2. On the final step, `ResumeFormProvider.generate()` POSTs that data to
   `/api/resume/generate` and stores the response in `ResumeFormProvider.result`.
3. `ResumePreviewScreen` renders that result as an A4 card plus ATS/score panel,
   and calls `/api/resume/pdf` / `/api/resume/docx` for downloads.
4. On "Save", `AuthProvider.setGeneratedResume()` stores a `SavedResumeMeta` so
   `DashboardScreen` can show the "My Resume" card on next login.

## Notes / things to wire up for production

- **Auth**: `AuthProvider.login()` is a mock (400ms delay, always succeeds).
  Replace with real Supabase Auth (`supabase_flutter` package) when ready.
- **Persistence**: `AuthProvider` state is in-memory only — it resets when the
  app restarts. For real persistence, save `savedResume` to Supabase
  (`resume` table) via `/api/resume/save`, and re-fetch it on login.
- **File upload**: `UploadCVScreen` currently keeps the picked file in memory
  (`AuthProvider.uploadedFileBytes`) — wire it to Supabase Storage or your own
  upload endpoint to persist it server-side.
- Add `android/ios` permission entries for file picking if you see runtime
  errors on physical devices (usually none needed for `file_picker` on modern
  Android/iOS, but check `file_picker`'s own README for edge cases).