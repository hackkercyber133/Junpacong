#!/usr/bin/env bash
# Jalankan SEKALI dari dalam folder junpacong (butuh Flutter SDK terpasang).
#   bash setup.sh
# Lalu build APK:
#   flutter build apk --release
set -e

tmp="$(mktemp -d)"
cp -r lib assets pubspec.yaml android_patch "$tmp"/

# bikin kerangka android (package: com.junpacong.junpacong)
flutter create --org com.junpacong --project-name junpacong --platforms android .

# kembalikan source kita (flutter create bisa menimpa lib/main.dart & pubspec)
cp -r "$tmp"/lib/. lib/
cp "$tmp"/pubspec.yaml pubspec.yaml
mkdir -p assets/images && cp -r "$tmp"/assets/. assets/
rm -f test/widget_test.dart

# patch android untuk background play + izin
cp android_patch/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
mkdir -p android/app/src/main/kotlin/com/junpacong/junpacong
cp android_patch/MainActivity.kt android/app/src/main/kotlin/com/junpacong/junpacong/MainActivity.kt
# hapus MainActivity bawaan (java/kotlin) kalau ada di lokasi lain
find android/app/src/main -name MainActivity.kt -not -path "*/com/junpacong/junpacong/*" -delete 2>/dev/null || true

flutter pub get
echo
echo "Selesai. Jalankan: flutter run   |   build: flutter build apk --release"
echo "APK ada di build/app/outputs/flutter-apk/app-release.apk (rename jadi junpacong.apk)"
