#!/bin/bash -eu

setup () {
  # check commands existance that will be used during project setup
  check_flutter_command_exists
  check_bundler_gem_exists

  # waiting user input
  org_name=`wait_org_name_input`
  app_name=`wait_app_name_input`
  apple_id=`wait_apple_id_input`
  team_id=`wait_team_id_input`
  match_repo_url=`wait_match_repo_url_input`
  minimum_ios_version=`wait_ios_version_input`
  android_min_sdk_version=`wait_android_min_sdk_version_input`

  bundle_identifier="$org_name.$app_name"

  echo 'Creating Flutter project...🚀'

  # Creating Flutter project
  flutter create --org $org_name --platforms=ios,android $app_name

  echo 'Flutter project created❗❗'

  echo 'Setup git files...'

  echo 'Copying files...'

  cp -f ./git/.gitignore $app_name
  rm -rf $app_name/.idea/runConfigurations
  cp -r ./idea/runConfigurations $app_name/.idea/
  cp -r ./scripts $app_name/
  # replacing placeholder in .gitignore(which related to iml file)
  sed -i "" "s/<APP_NAME>/$app_name/g" $app_name/.gitignore

  echo 'Git file setup is Finished❗❗'

  echo 'Setup android project...'

  android_dir_path="$app_name/android"

  echo 'Copying files...'

  cp -r ./flavored_files/android/* "$android_dir_path/app/src/"

  # Setup Android minSdkVersion
  sed -i "" "s/minSdkVersion\ [0-9]\{2\}/minSdkVersion $android_min_sdk_version/g" "$android_dir_path/app/build.gradle"

  # replacing placeholder in Android related files
  echo 'Replacing placeholder text in android/ ...'
  find "$android_dir_path/app/src" -name *.xml | xargs sed -i "" "s/<BUNDLE_IDENTIFIER>/$bundle_identifier/g"
  find "$android_dir_path/app/src" -name *.xml | xargs sed -i "" "s/<APP_NAME>/$app_name/g"

  echo 'Android project setup is finished❗❗'

  echo 'Setup iOS project...'

  ios_dir_path="$app_name/ios"

  echo 'Copying files...'

  # Copying xcconfig files
  cp ./flavored_files/ios/* "$ios_dir_path/Flutter"
  # Copying Gemfile and fastlane related files
  cp Gemfile $ios_dir_path
  cp -r fastlane/ "$ios_dir_path/fastlane"
  cp project.yml $ios_dir_path
  cp Mintfile $ios_dir_path
  cp Podfile $ios_dir_path

  echo 'Replacing placeholder text in ios/ ...'
  sed -i "" "s/<APPLE_ID>/$apple_id/g" "$ios_dir_path/fastlane/Appfile"
  sed -i "" "s/<TEAM_ID>/$team_id/g" "$ios_dir_path/fastlane/Appfile"
  sed -i "" "s/<BUNDLE_IDENTIFIER>/$bundle_identifier/g" "$ios_dir_path/fastlane/Appfile"
  sed -i "" "s/<APP_NAME>/$app_name/g" "$ios_dir_path/fastlane/Fastfile"
  sed -i "" "s|<MATCH_URL>|$match_repo_url|g" "$ios_dir_path/fastlane/Matchfile"
  sed -i "" "s/<IOS_VERSION>/$minimum_ios_version/g" "$ios_dir_path/Podfile"
  sed -i "" "s/<IOS_VERSION>/$minimum_ios_version/g" "$ios_dir_path/project.yml"
  find "$ios_dir_path/Flutter" -name *.xcconfig | xargs sed -i "" "s/<BUNDLE_IDENTIFIER>/$bundle_identifier/g"
  find "$ios_dir_path/Flutter" -name *.xcconfig | xargs sed -i "" "s/<APP_NAME>/$app_name/g"

  echo 'Setup fastlane...'

  cd $ios_dir_path
  bundle install

  echo 'Updating Apple Developer site...'
  echo 'Register bundle_identifiers...'

  # Register bundle_identifier to Apple Developer Site
  bundle exec fastlane produce --app_identifier "$bundle_identifier.development" --app_name "$app_name Dev" --skip_itc
  bundle exec fastlane produce --app_identifier "$bundle_identifier.staging" --app_name "$app_name Stg" --skip_itc
  bundle exec fastlane produce --app_identifier "$bundle_identifier" --app_name "$app_name" --skip_itc

  echo 'Generating Provisioning Profiles...'
  bundle exec fastlane match_development
  bundle exec fastlane match_staging
  bundle exec fastlane match_production

  # Make Matchfile readonly
  echo "readonly true" >> "./fastlane/Matchfile"
}

check_flutter_command_exists () {
  check_command_exists flutter
}

check_bundler_gem_exists () {
  check_command_exists bundler
}

check_command_exists () {
  if ! command -v $1 &> /dev/null; then
    echo "$1 command does not found."
    exit -1
  fi
}

wait_org_name_input () {
  read -p "Please input your org name: " org_name

  if [ -z $org_name ]; then
    wait_org_name_input
  else
    echo $org_name
  fi
}

wait_app_name_input () {
  read -p "Please input your app name: " app_name

  if [ -z $app_name ]; then
    wait_app_name_input
  else
    echo $app_name
  fi
}

wait_apple_id_input () {
  read -p "Please input your apple id: " apple_id

  if [ -z $apple_id ]; then
    wait_apple_id_input
  else
    echo $apple_id
  fi
}

wait_team_id_input () {
  read -p "Please input your team id: " team_id

  if [ -z $team_id ]; then
    wait_team_id_input
  else
    echo $team_id
  fi
}

wait_match_repo_url_input () {
  read -p "Please paste your match repo URL: " match_repo_url

  if [ -z $match_repo_url ]; then
    wait_match_repo_url_input
  else
    echo $match_repo_url
  fi
}

wait_ios_version_input () {
  read -p "Please input minimum iOS version: " minimum_ios_version

  if [ -z $minimum_ios_version ]; then
    wait_ios_version_input
  else
    echo $minimum_ios_version
  fi
}

wait_android_min_sdk_version_input () {
  read -p "Please input Android min_sdk_version: " min_sdk_version

  if [ -z $min_sdk_version ]; then
    wait_android_min_sdk_version_input
  else
    echo $min_sdk_version
  fi
}

setup
