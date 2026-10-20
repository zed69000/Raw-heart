#!/usr/bin/env bash
# Generates the Android project around the web game, with the game's own Android settings.
# Shared by Codemagic and the local release build; run from android-app/ after npm install.
set -euo pipefail
cd "$(dirname "$0")"

# web files, with Three.js bundled so the app works offline
rm -rf www android
cp -R ../public www
mkdir -p www/vendor
curl -fsSL https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js -o www/vendor/three.module.js
perl -pi -e 's#https://cdn\.jsdelivr\.net/npm/three\@0\.160\.0/build/three\.module\.js#./vendor/three.module.js#' www/index.html
grep -q "./vendor/three.module.js" www/index.html
# the fonts too: the app makes no request to any other server
node -e '
const fs = require("fs");
(async () => {
  const html = fs.readFileSync("www/index.html", "utf8");
  const href = html.match(/<link rel="stylesheet" href="(https:\/\/fonts\.googleapis\.com\/css2[^"]+)">/)[1].replace(/&amp;/g, "&");
  let css = await (await fetch(href, { headers: { "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36" } })).text();
  fs.mkdirSync("www/vendor/fonts", { recursive: true });
  let i = 0;
  for (const url of [...new Set(css.match(/https:\/\/fonts\.gstatic\.com\/[^)]+/g))]) {
    const name = `f${i++}.woff2`;
    fs.writeFileSync(`www/vendor/fonts/${name}`, Buffer.from(await (await fetch(url)).arrayBuffer()));
    css = css.split(url).join(name);
  }
  fs.writeFileSync("www/vendor/fonts/fonts.css", css);
  const out = html.replace(/<link rel="preconnect" href="https:\/\/fonts\.(googleapis|gstatic)\.com"( crossorigin)?>\n/g, "")
    .replace(/<link rel="stylesheet" href="https:\/\/fonts\.googleapis\.com\/css2[^"]+">/, "<link rel=\"stylesheet\" href=\"./vendor/fonts/fonts.css\">");
  fs.writeFileSync("www/index.html", out);
})();'
grep -q "./vendor/fonts/fonts.css" www/index.html
! grep -q "fonts.googleapis.com\|cdn.jsdelivr.net" www/index.html

npx cap add android
RES=android/app/src/main/res
# landscape only
perl -0pi -e 's/<activity\b/<activity android:screenOrientation="sensorLandscape"/' android/app/src/main/AndroidManifest.xml
grep -q 'sensorLandscape' android/app/src/main/AndroidManifest.xml
# full screen activity, dark launch screen, game icon
cp native/java/MainActivity.java android/app/src/main/java/com/zed69000/rawheart/MainActivity.java
find $RES -name 'splash.png' -delete
cp native/splash.xml $RES/drawable/splash.xml
rm -rf $RES/mipmap-anydpi-v26
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do cp native/res/mipmap-$d/*.png $RES/mipmap-$d/; done
perl -0pi -e 's#(<style name="AppTheme.NoActionBarLaunch"[^>]*>)#$1\n        <item name="windowSplashScreenBackground">\#050606</item>#' $RES/values/styles.xml
perl -0pi -e 's#(<style name="AppTheme.NoActionBar"[^>]*>)#$1\n        <item name="android:windowBackground">\#050606</item>\n        <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>#' $RES/values/styles.xml
npx cap sync android
