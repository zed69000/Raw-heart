#!/usr/bin/env bash
# Builds the signed Android App Bundle to upload to Google Play.
#
#   ./build_aab.sh <versionCode> [versionName]
#
# versionCode must grow with every upload to Play. The upload key is read from the properties file named by
# RAW_HEART_SIGNING (default ~/.raw-heart/upload-keystore.properties: storeFile, storePassword, keyAlias, keyPassword);
# it stays outside the repository. Needs Node, JDK 21 (JAVA_HOME) and the Android SDK (ANDROID_HOME).
set -euo pipefail
cd "$(dirname "$0")"
CODE="${1:?usage: ./build_aab.sh <versionCode> [versionName]}"
NAME="${2:-$(node -p "require('./package.json').version")}"
SIGNING="${RAW_HEART_SIGNING:-$HOME/.raw-heart/upload-keystore.properties}"
[ -f "$SIGNING" ] || { echo "no signing properties at $SIGNING"; exit 1; }

npm install --no-audit --no-fund
bash prepare.sh

# version and release signing, read from the properties file at build time
SIGNING_GRADLE=$(if command -v cygpath >/dev/null; then cygpath -m "$SIGNING"; else printf '%s' "$SIGNING"; fi)
perl -0pi -e "s/versionCode \d+/versionCode $CODE/; s/versionName \"[^\"]*\"/versionName \"$NAME\"/" android/app/build.gradle
perl -0pi -e "s#    buildTypes \{\n        release \{#    signingConfigs {\n        release {\n            def p = new Properties()\n            file('$SIGNING_GRADLE').withInputStream { p.load(it) }\n            storeFile file(p.storeFile)\n            storePassword p.storePassword\n            keyAlias p.keyAlias\n            keyPassword p.keyPassword\n        }\n    }\n    buildTypes {\n        release {\n            signingConfig signingConfigs.release#" android/app/build.gradle
grep -q 'signingConfig signingConfigs.release' android/app/build.gradle

(cd android && chmod +x gradlew && ./gradlew --no-daemon bundleRelease)
mkdir -p dist
OUT="dist/raw-heart-$NAME-$CODE.aab"
cp android/app/build/outputs/bundle/release/app-release.aab "$OUT"
echo "$OUT"
