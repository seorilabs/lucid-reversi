# Android 아이콘 릴리스 v2.2.12(54)

Google Play **내부 테스트 배포까지 완료**했다. 공개 버전은 `v2.2.8(50)`이며, 새 후보의 Android 실행 검수 승인과 프로덕션 제출·공개 확인은 남아 있다. [실행 원장](2026-11-15-android-icon-state.json)의 `public_live` 완료 판정은 false다.

## 고정 후보와 실제 도달 상태

| 항목 | 확인 결과와 근거 |
|---|---|
| 앱 | Lucid Reversi / `com.etlegame.reversi`, Seori Apps 개인 계정 `5547060480954653351`, Console 앱 `4973741703890923260` |
| 후보 | `v2.2.12`, `2.2.12(54)`, source `5b8268b10ea925bad0aa80bdd5a25ebed24d08e2` |
| 개발 검수 | [정확한 소스의 CI](https://github.com/seorilabs/lucid-reversi/actions/runs/43617316407), Godot 4.6.3 smoke 484개와 실제 입력 E2E 7개 시나리오·439단계, 실제 화면 렌더링 통과 |
| 서명 빌드 | [43617754494](https://github.com/seorilabs/lucid-reversi/actions/runs/43617754494), upload=false로 만든 파일을 검사 후 그대로 업로드 |
| AAB | SHA256 `e8177619f6f64b76efa5b9c8949aac275ec2d3a519fd83bc403b5221e7029bea`, minSDK24 / targetSDK36 / debug=false |
| 내부 업로드 | 중앙 업로더로 2026-11-14 17:01:53 UTC commit 완료. 17:02:32 UTC Publisher readback의 internal `completed(54)` 및 번들 SHA가 일치했고 조회 편집은 204로 종료 |
| Console | `lucid-reversi 2.2.12 (54)`가 “내부 테스터에게 제공됨”, 게시일 11월 15일 오전 2:01로 표시됨 |
| 테스트 진입 | [내부 테스트 참여](https://play.google.com/apps/internaltest/4697313818927309750) |
| 운영 안내 | 출시관리 Slack 안내가 `delivered=true`, `SENT`로 확인됨. 발송 ID `lucid-reversi-v2.2.12-build54-internal`, 이벤트 `cmwgnnq9pcpv7x801ug7sid3a` |

기존 무료 배포와 production의 명시 국가 코드 172개 및 `restOfWorld=true`를 유지한다. Console의 국가 집계 표시와 API 코드 수를 같은 수치로 해석하지 않는다. 관리형 게시는 사용 중지 상태다. iOS와 AppsInToss는 공용 서리 앱 아이콘이 아니어서 이번 변경·배포 범위에서 제외했다.

## 변경과 검증

- [PR #163](https://github.com/seorilabs/lucid-reversi/pull/163): 서리 로고였던 Android 일반·적응형 전경을 기존 Play 등록용 Moonlit Lacquer 흑백 돌로 교체했다.
- [PR #164](https://github.com/seorilabs/lucid-reversi/pull/164): 실제 시작 장면·좌표 입력·격리 저장·고정 시드를 쓰는 E2E와 기능 목록 v2를 도입했다. 검수에서 드러난 설정 목록의 버튼 위 스크롤을 수정하고 종료 시 BGM을 정리했다. 네이티브 SDK는 플랫폼 경계 대역으로 격리했으므로 이 실행을 실제 SDK 검수로 기록하지 않는다.
- [PR #165](https://github.com/seorilabs/lucid-reversi/pull/165): 배포 caller에서 CI 근거를 읽는 `actions: read` 권한을 추가했다.
- [PR #166](https://github.com/seorilabs/lucid-reversi/pull/166): 기존 두 돌 배치에 맞는 투명 SVG 단색 아이콘을 명시했다. 이전 AAB의 기본 Godot 단색 리소스는 존재했지만 활성 XML에서는 참조하지 않았으며, 실제 런처에 Godot 로고가 표시됐다고 판정한 것은 아니다.

완성된 AAB 원본을 구현자와 독립 검수자가 각각 읽었다. 활성 `@mipmap/icon`의 XML이 배경·전경·새 단색 drawable을 참조하며 총24개 밀도별 이미지가 있다. 대표 일반·배경은 제품 PNG와 RGBA 전체가 일치했다. 전경은 alpha 전체와 alpha>=20 영역의 RGB가 같았고, 매우 투명한 경계의 RGB 처리 차이는 원본 보고서에 구분했다. 단색 마스크는 두 돌이며 alpha>=128 영역의 최대 반경119.553px가 안전 반경132px 안에 들어간다.

AAB 서명은 `jarsigner`로 검증했다. 현재 Console에서 내려받은 업로드 인증서와 AAB PKCS7 인증서의 SHA256은 `59966e5a8de8b9c67c71faa7cedf7ee2cf492a116fd98b971cad802fe7c00077`로 같다. Play가 생성한 universal APK도 오프라인으로 검사했다. `2.2.12(54)`, arm64-v8a, 실제 게임 assets와 `project.binary`가 있으며 서명은 Play 앱 서명 키 `b067f7f6d426d114e963a782fd4075c643785798833fdb53dde4846b3309fc01`와 같다. APK SHA256은 `149e7b7b7b986b13e568f3d6e08311c8ee5b94af31b2ff5fbadbb3823fd7361d`다. 설치·실행 근거는 아니다.

중앙 `5d7f6d3116521a776e7fc94631b7507ccfcb4274`에서 이 후보의 before-build와 before-deploy L3가 통과했다. before-release는 `native-admob`와 `native-shell`의 `platform-first` Android 실행 근거가 없어 실패한다. 실행 원장 구조 오류는 없지만 QA와 실제 실행·운영 신호, 제출 이후 단계가 남아 공개 완료 검사도 실패하는 것이 현재 사실이다.

## 남은 작업과 승인 경계

기기 접근은 0회다. Android 런처의 실제 아이콘 마스킹·캐시와 Play 서명 설치본의 시작을 개발 환경에서 확인할 수 없어, 최종54 대상으로 별도 승인을 요청하고 기다리고 있다. 범위는 연결 Android1대의 adb 최소 조회·동일 서명 업데이트·현재 런처 아이콘·cold start·자동 AdMob 초기화/로드 콜백이며, 약10분과 필요한 경우5분 재시도1회다. 앱 업데이트로 프로세스가 종료될 수 있고 기존 AI 차례가 자동 진행·저장·종료되거나 자연스러운 광고가 표시될 수 있으며 익명 분석 세션 파일도 생성될 수 있다. 앱 삭제·초기화·새 대국·수동 대국 조작·앱/OS 설정 변경·광고 클릭은 하지 않는다. 서명 불일치 시 중단한다. 무응답은 승인이 아니다.

승인 뒤 같은 후보의 필수 항목만 독립 검수하고 실제 실행 기록을 Release의 before-release 근거로 추가한다. Android release configuration fingerprint는 `364f0f8d882f8d61c6bc86cf8583c1e11bddf42255e10bfccb7c551df29e8cd7`이며 실제 AAB·Play APK·서명·SDK 설정으로 계산한 preimage를 원본 증적에 남겼다. 중앙 before-release를 다시 통과한 뒤 `promote-google-play.yml`에 `release_tag=v2.2.12`, internal → production, completed, 기존 국가·100%를 명시해 **같은54**를 승격한다. 재빌드하거나 트랙의 최신 번호를 임의 선택하지 않는다.

2026-11-14 17:12:31 UTC Console readback에서 앱 수준 판매자 선언은 검토 중이었다. 내부 commit이 기존 미전송 선언을 함께 전송한 상태이며 프로덕션54 제출과는 구분한다. 한국어 전체 설명의 “모서리와 가장자리는 뒤집히지 않아”는 “모서리는 뒤집히지 않아”로 고쳐 저장·재조회했고, 검토 전송 가능하지만 미전송 상태다. 나머지 두 언어와 앱 이름·간단한 설명은 저장소와 일치한다. 진행 중 검토를 취소하지 말고 제출 직전 상태를 다시 읽는다. 프로덕션 제출·심사 승인·공개·실제 운영 확인은 각각 남겨 둔다. 모니터를 새로 설정하지 않았다.

## 실패 이력과 보관

예비 `v2.2.11(53)`은 서명 빌드 뒤 병행한 같은 계정 조회 편집이 업로드 편집을 무효화해 HTTP400으로 실패했다. 당시 Play 트랙·번들 목록에53이 없었고 현재 내부는54, production은50이다. 이후 업로드·승격 중 같은 앱의 API 편집이나 Console 변경을 병행하지 않는다. 53의 태그·원본·실패 로그는 보존한다.

PR166의 MiniMax 검토는 최초 실행과 허용된 재시도에서 `headless-permission-required`로 완료하지 못했다. 재시도는 동일 호스트 기능 실패4회를 확인한 뒤 종료했다. 검토 성공으로 표시하지 않았으며, 공식 Godot4.6.3 export 구현과 CI·독립 에셋 검수에 근거한 자체 점검으로 병합했다.

원본 로그·CI 산출물·실패와 최종 AAB·Play APK·독립 보고서·provider readback·로컬 검토 진단의 보관 위치:

`smb://nas1dual/Data/Backup/agent-artifacts/lucid-reversi/2026-11-15/5b8268b10ea925bad0aa80bdd5a25ebed24d08e2/icon-release`

`verification-manifest.json`이 모든 원본의 크기·SHA256 대조와 NAS 사본 직접 읽기 검증 결과를 담는다. 보관 기간을 임의로 만료 삭제하지 않는다. 작은 필수 중앙 근거는 [GitHub Release](https://github.com/seorilabs/lucid-reversi/releases/tag/v2.2.12)에도 보존한다. 추적 이슈 [#162](https://github.com/seorilabs/lucid-reversi/issues/162)는 공개 미완료로 열어 둔다.

NAS 이관 검증은 456개 원본, 201,794,364bytes에 대해 완료했다. 검증 목록 SHA256은 `536a94ce0be69237675ed652a73cd6b17fd1acb3a038cbd600f0e31429688657`이다. 최초 복사 직후 불일치가 난 지점은 원본을 보존한 채 재조회했고, 완료 목록이 없는 같은 작업의 이관 폴더에서 기존 파일을 덮어쓰지 않고 내용을 대조한 뒤 나머지를 스트림 복사했다. 최종 전체 원본과 NAS 사본을 다시 직접 읽고 일치한 뒤 목록을 작성·재조회했다.
