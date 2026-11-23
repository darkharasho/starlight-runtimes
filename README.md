# starlight-runtimes

Holds the Cheat Engine runtime tarballs that [Starlight](https://github.com/darkharasho/starlight) downloads on first run.

Cheat Engine is licensed under **GPLv2**. Full sources at [github.com/cheat-engine/cheat-engine](https://github.com/cheat-engine/cheat-engine). The official upstream release page is at [cheatengine.org/downloads.php](https://www.cheatengine.org/downloads.php).

The Cheat Engine binaries are unmodified and redistributed under GPLv2. The one exception is `ceserver`, which is built here from the Cheat Engine source with a small patch ([`ceserver/starlight.patch`](./ceserver/starlight.patch): listen on 127.0.0.1 only, no LAN broadcast, allow spaces in its install path) by [`ceserver/build.sh`](./ceserver/build.sh). Starlight uses it with Windows Cheat Engine 7.5 to cheat native Linux games.

## Releases

| Tag                  | Platform   | File                          | Upstream                                                         |
|----------------------|------------|-------------------------------|------------------------------------------------------------------|
| `ce-7.6.6-4-linux`   | linux-x64  | `CheatEngineLinux766-4.zip`   | https://cheatengine.org/download/CheatEngineLinux766-4.zip       |
| `ce-7.5-windows`     | windows    | `CheatEngineWindows75.zip`    | CheatEngine75.exe, extracted with innoextract                    |
| `ceserver-7.5`       | linux-x64  | `ceserver-7.5-linux-x64.zip`  | built from source by `.github/workflows/ceserver.yml`            |

See [`manifest.json`](./manifest.json) for the machine-readable index Starlight consumes.

## Releasing ceserver

Push a `ceserver-<ce tag>` tag (e.g. `ceserver-7.5`). The `ceserver` workflow builds it on Ubuntu 22.04 and publishes the release; copy the sha256 and size from the release notes into `manifest.json` (`cheatEngine.ceserver`).
