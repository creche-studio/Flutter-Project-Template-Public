# Flutter Project Template Public
This repo is Flutter project generator.

You can generate a Flutter project by executing two scripts, including ApplicationIds(Android) / Bundle Identifiers(iOS) for the below environment.

- Debug
- Staging
- Production

These scripts also execute fastlane(produce / match), so you can get Provisioning Profile for these Bundle Identifiers.

## How to use
### 1. Generate Flutter Project
```
> ./create_flutter_project.sh

Please input your org name(It will be used to generate ApplicationId(Android) / BundleIdentifier(iOS)):
> studio.creche

Please input your app name(It will be used to generate ApplicationId(Android) / BundleIdentifier(iOS)):
> sample

Please input your apple id(It will be set on Appfile.):
> nerd0geek1@creche.studio

Please input your team id(It will be set on Appfile.):
> FS2Q6749B8

Please paste your match repo URL(It will be set on Matchfile.):
> git@github.com:creche-studio/certificates.git

Please input minimum iOS version:
> 13.0

Please input Android min_sdk_version:
> 23
```

### 2. Update iOS / Android Project
```
> cd <APP_NAME>
> ./scripts/setup_each_environment.sh
```
