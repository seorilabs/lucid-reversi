# GitHub Actions

이 저장소는 **public**이다. 아래 내용은 모두 그 전제에서 쓴다.

## Workflows

- `Godot Compile`: Godot import, compile, smoke scene.
- `Repository Checks`: core, architecture, docs checks.
- `Deploy Godot Web Pages`: `main` push 후 Godot Web export를 GitHub Pages로 배포. Pages는 활성화돼 있고 사이트는 <https://seorilabs.github.io/lucid-reversi/> 이다.
- `Release Inventory`: manual release blocker inventory.
- `Deploy to App Store`: 중앙 `godot-deploy-app-store.yml` 호출. `macos-26`에서 Godot iOS export → xcodebuild archive → App Store Connect 업로드. 파일 자체는 지우지 않는다(Backoffice의 마켓 타깃 감지가 파일 존재로 "appstore"를 판정한다).

  `CFBundleVersion`은 Xcode Cloud 예외 경로가 아니라 중앙 계약의
  `derivation.appleBuildNumber`(`encoded-version`)를 쓴다. 태그가 곧 build number라
  **같은 태그를 다시 올리면 App Store가 중복으로 거부한다.** 재업로드는 패치 태그로 한다.

## Runner Routing

public repo는 ARC(`seorilabs-rpi-arm64`)에 **접근할 수 없다**. 조직 러너 그룹이 모두
`allows_public_repositories: false`라 job이 러너를 못 잡고 영구 pending 된다. 실패가 아니라
무한 대기라서 알아차리기 어렵다.

중앙 재사용 워크플로우는 셋 중 하나다. 새 caller를 추가할 때 어느 쪽인지 먼저 확인한다.

| 중앙 워크플로우 유형 | 대응 |
|---|---|
| `runs_on` 입력을 노출 (`godot-checks`, `godot-pages`, `cleanup-actions-storage`, `godot-deploy-ait`) | caller가 아래 조건식을 **반드시 전달**한다. 기본값이 ARC라 생략하면 깨진다 |
| `ubuntu-latest` 하드코딩 (`godot-deploy-google-play`) | 전달할 것이 없다. 그대로 둔다 |
| 중앙이 공개 여부로 스스로 결정 (`release-tag`, `init-release-version-ledger`) | caller가 관여하지 않는다. 태그와 원장을 push하는 `contents: write` job이라 러너 선택권을 caller에게 열지 않는 것이 중앙의 결정이다 |

첫 번째 유형에서 caller가 전달하는 조건식은 이렇다.

```yaml
runs_on: ${{ github.event.repository.private && 'seorilabs-rpi-arm64' || 'ubuntu-latest' }}
```

세 번째 유형을 로컬 복사본으로 우회하지 않는다. 중앙 원장을 정본으로 유지하고,
중앙 워크플로우 안에서 해결한다.

## 플랫폼별 빌드 위치

- **Android(AAB)**: `ubuntu-latest`. 중앙 워크플로우가 하드코딩하고 있어 별도 조치가 없다.
- **Web / AIT**: `ubuntu-latest`. public repo는 GitHub-hosted standard runner가 무료·무제한이다.
- **iOS**: `macos-26`. `ubuntu-latest`에서는 **archive·서명·업로드가 성립하지 않는다**(Xcode는 macOS 전용).
  public 저장소는 GitHub-hosted 표준 러너가 무료·무제한이라 macOS도 비용이 들지 않는다.
  Godot export까지만 Linux로 분리하는 2-job 구성도 가능하지만 쓰지 않는다. release binding과
  artifact digest가 job 경계를 넘으면 "검증한 그 artifact만 올린다"는 계약 보장이 artifact 전달
  신뢰로 약해지고, 분리해서 얻는 비용 이점도 없다.

## 시크릿 배치

조직 시크릿의 `visibility: private`는 "조직 내 private 저장소 전체"라는 의도와 맞다.
이 저장소 하나가 public이 됐다고 해서 `selected`로 바꾸지 않는다. 신규 private 저장소마다
수동 등록을 요구하게 되고 빠뜨리면 fail-closed로 조용히 깨진다.

대신 **이 저장소가 필요한 값을 독자적으로 보유**한다. 배치 우선순위는 이렇다.

1. **Environment 시크릿**(권장): 중앙 워크플로우의 job이 `environment:`를 선언하면
   환경 시크릿이 caller가 넘긴 값을 덮어쓴다. `google-play`/`apps-in-toss`/`app-store`
   환경에는 `required_reviewers`가 걸려 있어 **사람이 승인한 job만 값을 읽는다.**
   서명 키처럼 민감한 값은 여기에 둔다.
2. **repo 시크릿**: 환경이 없는 경로에만 쓴다. 저장소의 모든 workflow가 읽는다.

caller job에서는 환경 시크릿을 못 쓴다. reusable workflow를 `uses:`로 호출하는 job에는
`environment` 키워드 자체가 허용되지 않는다.

App Store 배포에 필요한 값은 아래 표가 정본이다. 조직 레벨 Apple 시크릿은 `private`
가시성이라 public인 이 저장소로는 상속되지 않는다. 서명 키와 ASC 키처럼 민감한 값은
`app-store` Environment에 두고, 그 밖의 값은 표에 적힌 위치를 따른다.

| 이름 | 위치 | 상태 |
|---|---|---|
| `APPLE_DISTRIBUTION_CERTIFICATE_BASE64` | `app-store` Environment | 등록됨 |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | `app-store` Environment | 등록됨 |
| `APPLE_KEYCHAIN_PASSWORD` | `app-store` Environment | 등록됨 (러너 임시 keychain 잠금용) |
| `APP_STORE_CONNECT_API_KEY_ID` | `app-store` Environment | 등록됨 |
| `APP_STORE_CONNECT_ISSUER_ID` | `app-store` Environment | 등록됨 |
| `APP_STORE_CONNECT_PRIVATE_KEY_BASE64` | `app-store` Environment | 등록됨 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | repo 시크릿 | 보유 중. **선택값** — `-allowProvisioningUpdates`로 자동 발급하므로 없어도 동작한다 |
| `GODOT_ANALYTICS_CONFIG_JSON_BASE64` | repo 시크릿 | 보유 중 |
| `APPLE_TEAM_ID` | repo 변수 | 등록됨. 비밀값이 아니다(`app-store/exportOptions.plist`에 이미 공개) |

원본은 `~/.config/seorilabs`가 정본이다. 조회·등록 절차는 `seorilabs-credentials` 스킬을 따른다.
macOS Keychain이 내보낸 `.p12`는 RC2-40-CBC를 쓰므로 OpenSSL 3.x로 열 때 `-legacy`가 필요하다.
CI는 `security import`(Apple 자체 crypto)를 쓰므로 이 제약을 받지 않는다.

## Central Source

runner 이름과 scale set 용량의 정본은 Seorilabs ARC 운영 저장소의
`global-versions.yaml`이다. 값은 운영 중 바뀌므로 workflow를 수정하기 전에
`seorilabs-arc-runners` 스킬로 현재 값을 다시 확인한다.
