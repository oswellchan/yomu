# Yomu
Manga reader written in Flutter

## Installing
1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Install dependencies
    * CLI `flutter pub get`
    * (Automatic) [Editor](https://flutter.dev/docs/get-started/editor?tab=vscode) with plugin

## Building
### iOS
* Follow steps [here](https://flutter.dev/docs/deployment/ios)

#### Known Issues
* Ensure iOS version is >=13.4. See [this](https://github.com/flutter/flutter/issues/49504)
* Ensure `ios/Flutter/App.framework` directory is empty when changing build target (e.g. between Simulator and actual device). See [this](https://github.com/flutter/flutter/issues/50568#issuecomment-609465675)
* While building, sometimes you might get
    ```
    Xcode's output:
    ↳
        note: Using new build system
        note: Building targets in parallel
        note: Planning build
        note: Constructing build description
        error: No profiles for '<profile>' were found: Xcode couldn't find any iOS App Development provisioning profiles matching '<profile>'. Automatic signing is disabled and unable to generate a profile. To enable automatic signing, pass
        -allowProvisioningUpdates to xcodebuild. (in target 'Runner' from project 'Runner')
    ```
    Just open the project in Xcode and it should fix the issue

### Android
🚧 Under construction 🚧

Follow steps [here](https://flutter.dev/docs/deployment/android)?

## Development
* [Setup](https://flutter.dev/docs/get-started/editor?tab=vscode) your editor
* See [Run the app](https://flutter.dev/docs/get-started/test-drive?tab=vscode)

## Disclaimer
The developer of this application does not have any affiliation with the content providers available.
