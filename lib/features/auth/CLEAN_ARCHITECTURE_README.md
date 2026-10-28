# Clean Architecture Refactor — `auth` Feature (Pilot)

## What changed

The `auth` feature now has three layers instead of two:

```
lib/features/auth/
  data/
    models/            (unchanged)
    repositories/       ← concrete HTTP implementations, now `implements` a domain interface
  domain/                ← NEW
    repositories/        abstract interfaces (contracts only, no implementation)
    usecases/             one class per business action, depends only on an interface
  presentation/
    controllers/         ← now call use cases instead of instantiating repositories directly
    screens/             (untouched)
```

**Nothing outside `lib/features/auth/` was touched.** Every controller keeps the exact
same public method names, parameters, and return types it had before, so every screen
that calls a controller works exactly as it did — no screen files were modified.

## Why this is "cleaner"

Before:
```dart
class LoginController extends GetxController {
  final _repo = LoginRepository();   // controller knows the concrete HTTP class
  ...
  final response = await _repo.login(model);
}
```

After:
```dart
class LoginController extends GetxController {
  final LoginUseCase _loginUseCase = LoginUseCase(LoginRepository());
  ...
  final response = await _loginUseCase(model);
}
```

`LoginUseCase` only knows about `ILoginRepository` (an abstract class), not the
concrete `LoginRepository`. This means:

- **Testability** — in a unit test you can pass `LoginUseCase(FakeLoginRepository())`
  without touching HTTP, `SharedPreferences`, or `FlutterSecureStorage`.
- **Swappability** — you could point the app at a different backend, a mock server,
  or a cached/offline data source by writing a new class that implements
  `ILoginRepository`, without touching a single controller.
- **A home for business rules** — right now the use cases are thin pass-throughs
  (by design, to guarantee zero behavior change). As real rules show up
  ("don't allow login while offline", "retry OTP send once on timeout", etc.),
  they belong in the use case, not scattered across controllers or repositories.

## What was deliberately left alone (and why)

- **Controllers still own storage, navigation, and snackbars.** These are
  presentation-layer concerns (UI side effects), not business logic, so they
  correctly stay in the controller layer — only the *data-fetching* call was
  routed through a use case.
- **Repository methods still return raw `Map<String, dynamic>`** instead of typed
  domain entities (e.g. a `LoginResult` class). Introducing typed entities is the
  logical next step, but it would require rewriting how every controller parses
  `response["StatusCode"]`, `response["obj"]`, etc. — real work, but higher risk.
  Doing it as a second, deliberate pass (with your review in between) is safer
  than bundling it into this first structural change.
- **Screens still construct `LoginRequestModel` / `SignUpRequestModel` directly.**
  These are simple, framework-free data classes, so keeping them as the shared
  request type across layers is a pragmatic, low-risk choice for now.

## How to verify

This container only had `lib/` (no `pubspec.yaml`, `android/`, `ios/`), so I
couldn't run `flutter analyze` or `flutter test` here. Before you merge:

```bash
flutter pub get
flutter analyze
flutter test
```

and manually smoke-test: login, logout, signup, OTP verify (signup + login-device
flows), resend OTP, forgot password, and change password.

## Rolling this out to the rest of the app

The same 4-step recipe applies to every other feature (`tickets`, `billing`,
`events`, `sos`, etc.):

1. For each existing `data/repositories/xxx_repo.dart`, create a matching
   `domain/repositories/xxx_repository.dart` abstract interface with the same
   method signatures.
2. Make the concrete repository `implements` that interface (one-line change).
3. For each controller method that calls a repository, create a
   `domain/usecases/xxx_usecase.dart` that wraps the interface call.
4. In the controller, replace the direct repository instantiation with a use
   case instantiation, and swap the call site. Leave everything else untouched.

Given `tickets` alone has a 1,149-line repository and a 1,760-line controller,
I'd recommend doing one feature at a time with a review checkpoint in between,
the same way we just did `auth`.
