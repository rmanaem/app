## FlutterFire Configure on Locked-Down Environments

While wiring Firebase, we hit repeated failures running

```
flutterfire configure \
  --project=placeholder-76937 \
  --out=lib/firebase_options.dart \
  --platforms=android,ios \
  --android-package-name=com.temp.placeholder.dev \
  --ios-bundle-id=com.temp.placeholder.dev
```

### Symptoms

- `UnsupportedError not found in iOS` or `Permission denied` emitted early in the command.
- `flutterfire` could not write to `/home/arman/flutter/bin/cache/engine.stamp` or the FVM cache because the Codex sandbox/host policy blocked writes outside the repo.
- Running `sudo flutterfire …` failed with `dart: not found` because sudo dropped the PATH entry pointing at the FVM SDK.
- Once PATH was fixed, `firebase projects:list` failed with `Failed to authenticate` because the root user had never run `firebase login`.

### Resolution

1. **Authenticate Firebase CLI for the sudo user**
   ```bash
   sudo env "PATH=/home/arman/fvm/versions/3.38.1/bin:/home/arman/.pub-cache/bin:$PATH" firebase login
   ```
2. **Run FlutterFire with elevated PATH so it can write to the global Flutter caches**
   ```bash
   sudo env "PATH=/home/arman/fvm/versions/3.38.1/bin:/home/arman/.pub-cache/bin:$PATH" \
     flutterfire configure \
       --project=placeholder-76937 \
       --out=/home/arman/Desktop/app/lib/firebase_options.dart \
       --platforms=android,ios \
       --android-package-name=com.temp.placeholder.dev \
       --ios-bundle-id=com.temp.placeholder.dev
   ```
3. Answer `y` when prompted to overwrite `lib/firebase_options.dart`.

This generated the real `FirebaseOptions` for both Android and iOS and unblocked `fvm flutter run --flavor dev --target lib/main_dev.dart`.

### Lessons / Reminders

- The FlutterFire CLI shells out to the Flutter SDK; if Flutter lives outside the workspace, sandboxed shells must run with elevated permissions.
- `sudo` changes PATH and user state. Preserve PATH explicitly and run `firebase login` for the sudo user before invoking `flutterfire`.
- Once the environment is configured, future `flutterfire configure` runs can be done from a normal terminal with the same `sudo env …` wrapper whenever the sandbox is active.
