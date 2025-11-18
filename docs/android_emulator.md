## Android Emulator Setup

These commands assume the Android SDK command-line tools are installed and `sdkmanager`, `avdmanager`, and `emulator` are on your `PATH`.

### 1. Install a system image (example: API 34, Google APIs)

```bash
sdkmanager "system-images;android-34;google_apis;x86_64"
# Apple Silicon example:
# sdkmanager "system-images;android-34;google_apis;arm64-v8a"
```

### 2. Create an Android Virtual Device (AVD)

```bash
echo "no" | avdmanager create avd \
  --name MyTestDevice \
  --device "pixel_7" \  # or any device from `avdmanager list devices`
  --package "system-images;android-34;google_apis;x86_64" \
  --abi x86_64
# Apple Silicon -> use the arm64-v8a package/abi.
```

### 3. Delete an AVD (when you need to recreate it)

```bash
avdmanager delete avd -n MyTestDevice
```

### 4. Launch the emulator

```bash
emulator -list-avds            # verify the AVD exists
emulator -avd MyTestDevice     # starts the emulator normally
```

To run it detached from the current shell (useful in CI):

```bash
nohup emulator -avd MyTestDevice >/tmp/MyTestDevice.log 2>&1 &
# or use `emulator -avd MyTestDevice -no-window &` if you only need a headless VM.
```

### 5. Run integration tests against the emulator

After the emulator boots (check `flutter devices` for its ID, e.g., `emulator-5554`):

```bash
fvm flutter test integration_test/dev_smoke_test.dart --flavor dev -d <DEVICE_ID>
fvm flutter test integration_test/prod_smoke_test.dart --flavor prod -d <DEVICE_ID>
```

Replace `<DEVICE_ID>` with the actual device ID returned by `flutter devices`.
