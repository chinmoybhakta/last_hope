# llama.cpp Setup for Android

## What was done

1. **Cloned llama.cpp repository** from GitHub
2. **Built native libraries** using CMake and make
3. **Copied libraries** to Android jniLibs directory

## Libraries placed in android/app/src/main/jniLibs/arm64-v8a/

- `libmtmd.so` (8.9MB) - Main llama.cpp library (ARM64 aarch64)
- `libllama.so` (34.5MB) - Core llama.cpp library (ARM64 aarch64) 
- `libggml.so` (1.8MB) - GGML base library (ARM64 aarch64)
- `libggml-cpu.so` (4.4MB) - CPU backend (ARM64 aarch64)
- `libggml-base.so` (7.1MB) - Base GGML library (ARM64 aarch64)

## Next Steps

1. **Clean and rebuild** the Flutter app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **If still having issues**, try building for release:
   ```bash
   flutter build apk --release
   ```

## Build Process

The libraries were successfully built for ARM64 using:

```bash
export ANDROID_NDK_HOME=/home/chini007/Android/Sdk/ndk/28.2.13676358
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=arm64-v8a \
      -DANDROID_PLATFORM=android-28 \
      -DCMAKE_C_FLAGS="-march=armv8-a" \
      -DCMAKE_CXX_FLAGS="-march=armv8-a" \
      -DGGML_OPENMP=OFF \
      -DGGML_LLAMAFILE=OFF \
      -B build-android
cmake --build build-android --config Release -j$(nproc)
```

## Architecture Support

Successfully built for `arm64-v8a` (64-bit ARM) architecture. The libraries are now compiled with compatible `-march=armv8-a` flags for broader device compatibility, resolving the SIGILL crash on older ARM processors.

## Troubleshooting

If you still get library loading errors:

1. Check that the device architecture matches `arm64-v8a`
2. Verify the libraries are in the correct jniLibs directory
3. Try running with `--verbose` to see detailed error messages

## Source

The libraries were built from llama.cpp commit: 4efd326e7
Build date: Mar 18, 2026 (ARM64 aarch64 using Android NDK 28.2.13676358)
