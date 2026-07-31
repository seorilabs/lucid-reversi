# Work Log

## 2026-08-01

- Added a localized, vertically scrollable move-list panel with chronological stone/coordinate rows, live move-count and last-move entry text, result-screen access, and new-game reset behavior.
- Added a localized playfield hint action that highlights exactly one legal best move for the current player and disables safely outside actionable player turns.
- Replaced the fixed AI pre-delay with centralized difficulty-based targets, bounded per-turn jitter, elapsed-search subtraction, and stale-turn guards.
- Added theme-derived inset highlights, shadows, and four input-transparent guide points to give every board theme a physical Othello-board surface.

## 2026-07-31

- Expanded the first-run How to Play sheet into a four-step sequence with localized previous/next/skip/done actions, step-specific board-cell highlights, and completion-only preference persistence.
- Extended seeded best-score tie selection to EASY so separate games vary symmetric openings while save/restore reproduces the same move and every difficulty keeps an optimal-scored choice.
- Added muted A-H/1-8 board coordinates outside cell touch targets, aligned to each cell and adapted to 6x6/10x10 boards and all visual themes.
- Added a localized, vertically scrollable How to Play sheet covering placement, flipping, pass, and winner rules; it opens once on the first game and remains available from settings without changing game state.
- Allowed the existing round Undo action after game over so it closes the result overlay and resumes the restored match.
- Added phase-aware AI evaluation that prioritizes mobility over early disc count, with exact root-candidate scoring for reliable seeded tie-breaking.
- Replaced checkerboard cells with a classic green single surface and thin grid lines, retaining theme-derived Arctic/Ember palettes, hints, hover, and last-move emphasis.
- Added conservative MEDIUM/HARD endgame thresholds that replace heuristic cutoff with pass-aware exact terminal disc-difference search.
- Added an in-settings About section with export-matched app version, support mail link, and fail-closed optional privacy-policy link.
- Fixed the status bar to show PASS only for the latest pass transition, then return to the current-turn label after the next normal move.
- Added a complete Japanese locale, Japanese-device first-install selection, persisted language choice, Korean missing-key fallback, and bundled M PLUS Rounded 1c glyph fallback.
- Added a default-on, persisted legal-move marker toggle inside settings, keeping invalid-move feedback and the playfield HUD unchanged.
- Added a once-per-game result-card entrance and winning-stone pulse inside the existing overlay, with static win/draw/loss rendering when reduced motion is enabled.
- Added per-game seeded tie-breaking for MEDIUM/HARD AI, preserving EASY and best-score behavior while making save/restore and Undo reproduce the same choice.
- Added 6x6/8x8/10x10 board-size preferences, size-derived rules/evaluation/UI layout, a tagged variable-length board codec with legacy 18-byte restore compatibility, and automatic new-game rebuilds when the size changes.
- Split theme, stone theme, locale, sound, haptic, and difficulty preferences into `user://prefs_v1.json`, migrated legacy save settings once, and made preferences authoritative when game saves are missing or invalid.
- Added persistent 100/115/130% text scaling and reduced-motion controls, with immediate final-board rendering when move tweens are disabled.
- Added a localized confirmation overlay that guards new-game and stone-color changes while a match is in progress, while keeping pre-move and completed-game restarts immediate.
- Added an observable interstitial request probe and regression smoke covering completed-save restore, result-overlay reopen, and the next-game reset lifecycle.

## 2026-06-19

- Set AppsInToss as the first launch target. Added Korean-default `ko`/`en` UI localization, bundled a Korean font for Godot Web/AIT, and split release checks into full-market and AppsInToss-first paths.
- Replaced the Korean UI font with OFL-licensed Do Hyeon Regular, increased key HUD font sizes, added text outlines, and raised muted text contrast for mobile game readability.
- Simplified the mobile game HUD by moving non-gameplay controls into a top-right settings menu and replacing the bottom control deck with a compact advantage/valid-move strip.
- Moved new game and black/white start controls back into the board-adjacent one-line gameplay strip, removed the redundant manual load button because save restore is automatic, and added synthesized placement/flip/big-flip sounds.
- Split board-adjacent feedback into a full-width advantage strip directly under the board plus a compact new game/black/white row, and removed the unused hint toggle from settings.
- Added a local Android device smoke APK path, locked Godot handheld orientation to portrait, and verified the game launches on connected device `SM02G4061934977` with a portrait screenshot.
- Enlarged mobile button touch targets and replaced settings select boxes with large segmented choice buttons for difficulty, board theme, stone theme, and language.
- Made the settings overlay close when tapping outside the panel, and removed the unsupported vibration setting from defaults, UI, docs, and smoke checks.
- Generated AppsInToss registration image assets: `600x600` logo, `1932x828` thumbnail, and three `636x1048` vertical screenshots, all validated as PNGs with no alpha channel.
- Reworked the AppsInToss logo toward a simpler legacy-Unity-style mark, rebuilt the thumbnail as a board-left/copy-right marketing image, and drafted Korean registration copy/search keywords.
- Verified `npm test`, JSON config syntax, `npm run check:release:ait` blocker inventory, `npm run build:godot:web`, and local Chrome Web smoke locally.

## 2026-06-18

- Planning approval accepted for Phase 0, Phase 1, Phase 2.
- `starter-template-game` copied into `lucid-reversi`.
- Product metadata changed to Lucid Reversi / 루시드 리버시.
- Added pure Reversi engine at `godot/scripts/reversi_engine.gd`.
- Added playable Godot shell at `godot/scripts/bootstrap/main.gd`.
- Expanded Godot smoke test coverage for rules, pass, codec, and save round trip.
- Updated docs/config inventory for Google Play, App Store, AppsInToss, and Firebase.
- Verified `npm test` passes locally.
- Verified `npm run build:godot:web` exports `build/pages` locally.
- Verified `npm run check:release` fails as expected on unresolved store console identifiers, signing, policy answers, and image assets.
- Reworked Godot UI using legacy Unity references: two-tone board surface colors, stone textures, valid move previews, player/computer score panels, turn highlight, and result popup.
- Verified the updated UI in a local Godot desktop window capture.
- Reworked the UI again as a dense mobile game HUD: compact top bar, full-width board, bottom control deck, status/stat panel, score-ratio meter, settings toggles, and no webpage-like vertical centering.
- Added move-result flipped coordinates and TextureRect scale tweens so placed/flipped stones animate instead of swapping instantly.
- Added explicit playable-move markers on valid empty cells so available moves are visible beyond translucent ghost stones.
- Fixed playable-move markers disappearing after the first animated move by unlocking input before the final render, with a UI smoke regression check.
- Replaced rough stone presentation with three SVG theme sets: Classic, Arctic, and Ember. Connected `settings.theme` to board colors, stone textures, theme picker UI, and smoke checks, then removed obsolete PNG board/stone assets from the export surface.
- Split visual customization into independent board and stone theme selectors so players can combine board palettes with Classic, Arctic, or Ember stone colors.

## 2026-06-15

- starter template game 초기 구조 생성.
- docs를 기획/의사결정/작업/마켓정보 원장으로 두는 ADR 추가.
- Godot compile gate와 repository checks workflow 추가.
