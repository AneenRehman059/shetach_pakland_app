# Clean Architecture Restructuring — Full App

## Scope of this pass

This is a **different, and earlier-stage, snapshot of the codebase** than the one
I worked on previously in this conversation (that one was already organized into
`lib/features/...`; this one is the original flat layout — `lib/controllers/`,
`lib/repo/`, `lib/models/`, `lib/dashboard/`, screens loose at the root, etc.).

For this pass I did two things:

1. **Restructured the entire app (190 files) into a feature-first folder layout.**
2. **Added the full clean-architecture domain layer (interfaces + use cases) to
   the `auth` feature**, exactly matching the pattern from before, as a
   reference implementation for the rest.

## New top-level layout

```
lib/
  core/            shared, cross-cutting code used by many features
    constants/
    connectivity/
    permissions/
    services/
    theme/
    utils/
    widgets/
  features/
    auth/            ← folder structure + full domain layer (see below)
    billing/
    booking/
    company/
    customer_portal/
    dashboard/        (app shell, admin/CMS screens, static pages)
    events/
    feedback/         (+ FAQs, help & support)
    onboarding/       (splash, welcome)
    profile/
    recent_activity/
    social/
    sos/
    tickets/
  legacy/            dead/scratch code (rough.dart, an unused emp_screen.dart)
  main.dart
```

Each feature follows the same internal shape:
```
features/<name>/
  data/
    models/
    repositories/
  presentation/
    controllers/
    screens/
```
(`auth` additionally has a `domain/` folder — see below.)

## How the move was done safely

With 190 files and no compiler available in this environment (only `lib/` was
uploaded — no `pubspec.yaml` or platform folders, so `flutter analyze` isn't
runnable here), a manual file-by-file move would have been too error-prone.
Instead I:

1. Built an explicit **old-path → new-path map for every single file** and
   verified programmatically that all 190 files were accounted for (no file
   silently skipped, no typo'd destination).
2. Copied every file to its new location.
3. **Rewrote every `import`/`export` statement** (both `package:pakland/...`
   and relative `../../foo.dart` style) by resolving each one against the
   *old* location, looking it up in the map, and replacing it with the new
   absolute `package:pakland/...` path. This eliminates relative imports
   entirely, so nothing depends on directory depth anymore.
4. Verified **zero unresolved imports** and **balanced braces** across all
   190 files afterward.

### One thing this surfaced: 13 pre-existing broken imports

Four files (`change_password_screen.dart`, `user_files_screen.dart`,
`development_progress.dart`, `dashboard/develope_progress_det_screen.dart`)
had relative imports with **one extra `../` than their location supported**
(e.g. a root-level file importing `../controllers/x.dart`, which — since the
file has no parent within `lib/` — pointed outside the project entirely).
This was already broken before I touched anything; it's the kind of thing
that only breaks if that exact code path is exercised. I resolved these to
their obvious intended targets (the sibling file with the same name elsewhere
in the map) rather than leave them dangling, since leaving them broken would
be strictly worse post-move. Flagging it here in case it's worth understanding
why it happened (my guess: copy-pasted import lines from a component that used
to live one directory deeper).

## Full clean architecture on `auth` (folder structure + domain layer)

Same pattern as the earlier `auth` pass:

- `domain/repositories/` — 5 abstract interfaces (`ILoginRepository`,
  `ISignUpRepository`, `IVerifyOtpRepository`, `IForgotPasswordRepository`,
  `IUpdatePasswordRepository`), each matching an existing repository's
  methods exactly.
- `domain/usecases/` — 7 use cases (Login, Logout, SignUp, VerifyOtp,
  ForgotPassword, SendOtpAuthDevice, UpdatePassword), thin wrappers over
  the interfaces.
- `data/repositories/*.dart` — unchanged logic, now `implements` the
  matching interface.
- `presentation/controllers/*.dart` — call use cases instead of
  instantiating repositories directly; **every public method name,
  parameter, and return type is unchanged**, so no screen was touched.

## What's *not* done yet

The other 13 features got the **folder-structure** treatment only (data vs.
presentation separated into models/repositories/controllers/screens), not
the domain-layer (interfaces + use cases) treatment yet. That's a deliberate
choice: `auth` was the proven pattern; doing interfaces + use cases for the
other ~15 repositories and ~25 controllers in the same pass, with no
compiler to catch mistakes, is exactly the kind of blind, high-volume change
that's most likely to introduce a subtle bug. I'd rather do it feature by
feature with a checkpoint, the same way we did `auth` — happy to keep going
on whichever feature you want next (`billing` is the biggest and most
representative, `tickets` is mid-sized).

## Before you merge

```bash
flutter pub get
flutter analyze
flutter test
```

Then smoke-test at least: login/logout, signup, both OTP flows, forgot
password, and change password (the `auth` feature is the one with the
deepest structural change).
