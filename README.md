# Flutter State Management Samples

Same counter scenario implemented with Provider, Bloc, Riverpod, MobX, and Signals.

Helps compare boilerplate, testability, and rebuild behavior across libraries.

Each variant is a separate entry point so you can run and diff implementations quickly.

Complements documentation with runnable, minimal examples rather than abstract demos.

## Structure

```mermaid
flowchart TB
  SampleApp --> ProviderMain
  SampleApp --> BlocMain
  SampleApp --> RiverpodMain
  SampleApp --> MobXMain
  SampleApp --> SignalsMain
  ProviderMain --> CounterLogic
  BlocMain --> CounterLogic
  RiverpodMain --> CounterLogic
  MobXMain --> CounterLogic
  SignalsMain --> CounterLogic
```

## Stack

| Technology | Version |
|------------|---------|
| Dart SDK | ^3.13.3 |
| cupertino_icons | ^1.0.8 |
| flutter_bloc | ^9.1.1 |
| signals_flutter | ^6.3.0 |
| provider | ^6.1.5+1 |
| mobx | ^2.6.0 |
| flutter_mobx | ^2.3.0 |
| flutter_riverpod | ^3.3.1 |
| flutter_lints | ^6.0.0 |
| build_runner | ^2.15.0 |
| mobx_codegen | ^2.7.7 |
| Android Gradle Plugin | 9.1.0 |
| Kotlin | 2.4.0 |
| compileSdk / targetSdk | 36 |
| minSdk | 29 |
| JVM | 25 |
| iOS Deployment Target | 15.0 |
| Swift | 5.0 |

## Architecture

```
lib/
    ├── main.dart
    ├── main_bloc.dart
    ├── main_mobx.dart
    ├── main_mobx.g.dart
    ├── main_provider.dart
    ├── main_riverpod.dart
    └── main_signals.dart
```

## Coverage

flutter pub run build_runner build --delete-conflicting-outputs

flutter test --coverage

genhtml coverage/lcov.info -o coverage/html

open coverage/html/index.html

## ScreenShots

| Image 1 | Image 2 | Image 3 |
|----------|----------|----------|
| ![App Screenshot](assets/screenshots/screen-1.png) | ![App Screenshot](assets/screenshots/screen-2.png) | ![App Screenshot](assets/screenshots/screen-3.png) |

| Image 4 | Image 5 | Image 6 |
|----------|----------|----------|
| ![App Screenshot](assets/screenshots/screen-4.png) | ![App Screenshot](assets/screenshots/screen-5.png) | ![App Screenshot](assets/screenshots/screen-6.png) |

## Commits

```
git add . && git commit -m ":rocket: Initial commit." && git push
git add . && git commit -m ":building_construction: Added initial project architecture." && git push
git add . && git commit -m ":building_construction: Update project architecture." && git push
git add . && git commit -m ":memo: Updated project documentation." && git push
git add . && git commit -m ":memo: Updated code documentation." && git push
git add . && git commit -m ":white_check_mark: Added feature xyz." && git push
git add . && git commit -m ":wrench: Fixed xyz usage." && git push
git add . && git commit -m ":heavy_minus_sign: Removed xyz." && git push
git add . && git commit -m ":memo: Adjusted project imports." && git push
git add . && git commit -m ":arrow_up: Updated dependencies." && git push
git add . && git commit -m ":arrow_down: Removed dependencies." && git push
git add . && git commit -m ":wastebasket: Removed unused code." && git push
git add . && git commit -m ":test_tube: Added test functionality xyz." && git push
git add . && git commit -m ":construction_worker: Building in progress." && git push
git add . && git commit -m ":construction_worker: Added CI build system." && git push
```

## License

[MIT License](https://opensource.org/licenses/MIT)

Copyright (c) 2026 William Franco.

