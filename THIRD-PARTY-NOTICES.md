# Third-Party Notices

Lucid Reversi bundles or downloads the components below. Each remains under its
own license. This file is informational; the license texts referenced here are
authoritative.

## Bundled in this repository

### Godot AdMob addon — `godot/addons/AdmobPlugin/`, `godot/ios/plugins/AdmobPlugin.gdip`

GDScript addon from [`cengiz-pz/godot-admob-addon`](https://github.com/cengiz-pz/godot-admob-addon), vendored at v6.0.

MIT License — Copyright (c) 2024 Cengiz (<https://github.com/cengiz-pz>)

### Do Hyeon — `godot/assets/fonts/DoHyeon-Regular.ttf`

Copyright 2018 The Do Hyeon Project Authors

SIL Open Font License 1.1 — full text in `godot/assets/fonts/OFL-DoHyeon.txt`

### M PLUS Rounded 1c — `godot/assets/fonts/MPLUSRounded1c-Regular.ttf`

Copyright (c) 2002-2015 Coji Morishita

SIL Open Font License 1.1 — full text in `godot/assets/fonts/OFL-MPLUSRounded1c.txt`

Bundled as the Japanese glyph fallback.

## Downloaded at build time, not in this repository

### AdmobPlugin iOS xcframework

`scripts/install_ios_admob_plugin.sh` downloads the native iOS binaries from
[`godot-sdk-integrations/godot-admob`](https://github.com/godot-sdk-integrations/godot-admob)
releases into `godot/ios/framework/` (git-ignored, ~45MB).

MIT License — Copyright (c) 2025 Cengiz (<https://github.com/cengiz-pz>) and
Godot Engine Community SDK Integrations

That archive embeds Google's **Google Mobile Ads SDK** and **User Messaging
Platform**, which are covered by Google's own terms, not by MIT.

### npm dependencies

`apps/ait/` resolves its dependencies from the public npm registry; see
`apps/ait/package.json` and `apps/ait/package-lock.json`.

## Engine

This repository contains a Godot project, not the engine. Exported builds embed
the Godot Engine runtime, which is MIT licensed — Copyright (c) 2014-present
Godot Engine contributors, Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
See <https://godotengine.org/license>.

## First-party assets

Music and sound effects under `godot/assets/audio/` were generated with
Stability AI's `stable-audio-2.5` model; the generation parameters are recorded
in `godot/assets/audio/sound-manifest.json`. They are first-party assets of
Seori Labs and are covered by `LICENSE-ASSETS`, not by this file.
