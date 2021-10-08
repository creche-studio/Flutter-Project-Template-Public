#!/bin/bash -eu

setup_android_environment () {
  # update android/app/build.gradle for setup product flavor
  replacement=`cat << EOS
    signingConfigs {
        release {
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }

    flavorDimensions "environment"
    productFlavors {
        development {
            applicationIdSuffix ".development"
        }
        staging {
            applicationIdSuffix ".staging"
        }
        production {
        }
    }
EOS
`

  perl -0pi -e "s/^ {4}buildTypes[\s\S]*^ {4}}/$replacement/m" android/app/build.gradle
}

setup_ios_environment () {
  cd ios
  # delete Runner.xcodeproj for installing XcodeGen
  git rm -rf --ignore-unmatch Runner.xcodeproj
  # update Info.plist to update screen name according to Build Scheme
  /usr/libexec/PlistBuddy -c "set CFBundleName \$\(DISPLAY_NAME\)" Runner/Info.plist
  # install Mint and setup XcodeGen
  mint bootstrap
  mint run xcodegen generate
  echo 'mint' >> .gitignore
  echo 'Runner.xcodeproj' >> .gitignore
  pod install
  cd ../
}

setup_android_environment
setup_ios_environment
# This script file is only used during project setup, so this delete itself when project setup is finished.
rm scripts/setup_each_environment.sh
