# Task B1: Setup Flutter Project Structure

**Files:**
- Create: `frontend/lib/main.dart`
- Create: `frontend/lib/app.dart`
- Modify: `frontend/pubspec.yaml`

**Interfaces:**
- Produces: Flutter project scaffold with dependencies

---

**Step 1: Create Flutter project**

Run in PowerShell (from `c:\xampp\htdocs\DNTrip`):
```powershell
flutter create --org com.dntrip frontend
```

Expected: Flutter project created in `frontend/` directory

---

**Step 2: Configure pubspec.yaml**

Edit `frontend/pubspec.yaml`:
```yaml
name: dntrip
description: Trip sharing and expense tracking app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  dio: ^5.4.0
  go_router: ^13.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
```

Run:
```powershell
cd frontend && flutter pub get
```

Expected: Dependencies installed

---

**Step 3: Create folder structure**

Create these directories:
```
frontend/lib/
├── core/
│   ├── api/
│   ├── router/
│   ├── storage/
│   ├── theme/
│   └── constants/
└── features/
    └── auth/
        ├── data/
        │   ├── models/
        │   └── datasources/
        ├── domain/
        └── presentation/
            ├── screens/
            └── widgets/
```

---

**Step 4: Create basic main.dart placeholder**

Create `frontend/lib/main.dart`:
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DNTrip',
      home: const Scaffold(
        body: Center(child: Text('DNTrip App')),
      ),
    );
  }
}
```

---

**Step 5: Verify Flutter project builds**

Run:
```powershell
cd frontend && flutter build web --debug
```

Expected: Build succeeds
