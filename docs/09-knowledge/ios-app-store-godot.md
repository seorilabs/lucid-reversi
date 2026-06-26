# Godot iOS App Store 빌드 노트 (Lucid Reversi)

Godot 4.6.3 게임을 Apple App Store에 올리며 실증한 항목.

## iOS export 경로

- `godot --headless --path godot --export-release "iOS" "../release-artifacts/ios/xcode/lucidreversi.xcodeproj"`
  로 Xcode 프로젝트 생성(`application/export_project_only=true`).
- 이후 `xcodebuild archive` → `xcodebuild -exportArchive`(method=app-store-connect, destination=upload)로 업로드.
- 빌드 러너: macOS/Xcode(26.5). RPI ARC runner 대상 아님.

## 막혔던 지점과 원인 (시간순)

1. **`Metal 렌더러는 iOS 14 이상이 필요합니다`** — GL Compatibility 렌더러도 iOS에서 ANGLE-over-Metal을 쓰므로
   `application/min_ios_version`을 **14.0 이상**으로.

2. **설정 오류 메시지가 빈 문자열**(가장 헷갈림) — Godot 4.6 iOS export는
   `ResourceImporterTextureSettings::should_import_etc2_astc()`가 false면 **메시지 없이 export를 막는다**.
   해결: `project.godot`에 `[rendering] textures/vram_compression/import_etc2_astc=true` 추가.

3. **서명 충돌** `conflicting provisioning settings ... Apple Distribution manually specified` —
   Godot pbxproj가 `CODE_SIGN_STYLE=Automatic`인데 `CODE_SIGN_IDENTITY=Apple Distribution`을 못박음.
   해결: archive 시 `CODE_SIGN_STYLE=Automatic CODE_SIGN_IDENTITY="Apple Development"` 오버라이드.
   아카이브는 개발 서명으로 만들고, **배포 재서명은 `-exportArchive`(app-store-connect)에서 수행**된다.
   수동 서명+`-allowProvisioningUpdates`는 사전 생성된 프로파일이 없으면 실패(자동 생성은 자동 서명에서만).

4. **`bundleIdMatchesRemovedApp`** — App Store Connect에서 삭제된 앱의 bundle id는 재사용 불가.
   `com.github.magicsih.MatchPictureUnity`(삭제됨) → `com.github.magicsih.MatchSymbol`(활성)로 교체.

5. **버전/기기 요건**(기존 앱 교체 업로드 시) — Apple 서버가 알려줌:
   - `CFBundleShortVersionString`은 이전 승인 버전(1.0.4)보다 높아야 → **1.0.5**.
   - "이전 버전이 지원하던 기기를 계속 지원해야" → `targeted_device_family`를 **iPhone+iPad(Godot index 2 → Xcode `1,2`)**.

## Godot targeted_device_family 매핑(실측)

| Godot index | Xcode TARGETED_DEVICE_FAMILY |
|---|---|
| 0 | 1 (iPhone) |
| 1 | 2 (iPad) |
| 2 | 1,2 (iPhone & iPad) |

## 아이콘

- App Store 1024는 **알파 없음·RGB** 필수. 소스는 `apps-in-toss/release-assets/lucid-reversi-icon-600.png`(알파 없음)
  → `sips`로 1024 업스케일(`app-store/assets/AppIcon-1024.png`). 마스터 벡터 없어 업스케일이라 추후 고해상도 재생성 권장.
- Godot preset 아이콘은 `res://branding/ios/icon_*.png`로 지정. Godot이 universal AppIcon.appiconset(152/167 iPad 포함) 자동 생성.

## 시뮬레이터 스크린샷 (실증된 방법)

- `simctl list runtimes`가 비어 보이면 런타임이 없는 게 아니라 **CoreSimulator 서비스 버전 불일치**일 수 있다.
  `killall -9 com.apple.CoreSimulator.CoreSimulatorService` 후 재시도하면 런타임이 보인다.
- **Godot 엔진 simulator 라이브러리는 arm64 시뮬레이터 슬라이스가 없다**(x86_64만). Apple Silicon에서
  기본 arm64 시뮬레이터 빌드는 링크 실패(`Undefined symbols for architecture arm64`).
  → **x86_64로 빌드**(`ARCHS=x86_64 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO -sdk iphonesimulator`)하면
  Rosetta로 시뮬레이터에서 실행된다.
- 캡처: `simctl boot` → `bootstatus` → `install` → `launch` → **충분히 대기(Godot 부팅 스플래시 지나도록 ~20s, iPad/구버전 iOS는 더)** → `simctl io <udid> screenshot`.
  너무 일찍 찍으면 GODOT 스플래시가 찍힌다.
- 규격: iPhone 16 Pro Max=1320×2868(6.9"), iPad Pro 13"(M4)=2064×2752(13"). universal 앱은 iPad 샷도 필수.
- device 아카이브/업로드엔 시뮬레이터 불필요.

## v1 광고

- App Store v1은 **ad-free**. 네이티브 AdMob은 Godot iOS 플러그인(.xcframework+.gdip)+SDK+GDScript 브리지가 필요한 후속 작업.
  광고 ID는 `app-store/app-store.config.json`의 `ads.plannedNative`에 보관.
