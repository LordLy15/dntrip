# Task B7: Run Code Generation

**Files Generated:**
- `frontend/lib/features/auth/data/models/user_model.freezed.dart`
- `frontend/lib/features/auth/data/models/user_model.g.dart`
- `frontend/lib/features/auth/domain/auth_providers.g.dart`
- `frontend/lib/core/router/app_router.g.dart`

**Note:** Tasks B1-B6 must be complete before this task.

---

**Step 1: Run build_runner**

Run in PowerShell:
```powershell
cd frontend && flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: Generated files created successfully

---

**Step 2: Verify generated files exist**

Check:
- `frontend/lib/features/auth/data/models/user_model.freezed.dart`
- `frontend/lib/features/auth/data/models/user_model.g.dart`
- `frontend/lib/features/auth/domain/auth_providers.g.dart`
- `frontend/lib/core/router/app_router.g.dart`

---

**Step 3: Analyze entire project**

Run:
```powershell
cd frontend && flutter analyze
```

Expected: No errors (warnings OK)

---

**Step 4: Build debug APK to verify**

Run:
```powershell
cd frontend && flutter build apk --debug
```

Expected: Build succeeds
