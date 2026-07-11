#!/bin/bash

# Unduh Flutter SDK versi stable
echo "Cloning Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

# Tambahkan Flutter ke PATH environment Vercel
export PATH="$PATH:`pwd`/flutter/bin"

# Jalankan perintah Flutter
echo "Running flutter pub get..."
flutter pub get

echo "Building Flutter Web..."
flutter build web