# Android 아이콘 릴리스 v2.2.12(54)

**데이터 보안 정정 뒤 같은54를 재심사 제출했고, 새 제출82가 검토 중이다.** 2026-11-15 15:02KST에 Play Console에서 프로덕션 전체 출시·한국어 설명·데이터 보안을 전송했다. 관리형 게시는 꺼져 있어 승인 후 자동 공개된다. 15:05KST 공개 한국·미국 페이지는 아직2.2.8이다. [정정과 재제출 기록](../05-markets/2026-11-15-data-safety-correction.md), [실행 원장](2026-11-15-android-icon-state.json)의 승인·공개·live 확인은 남아 있다.

아래 최초 제출81 이력과 새82를 구분한다. 81은 데이터 보안 이메일 주소 누락으로 거부됐으며, 수정한 선언의 실제 Console782개 응답은 저장소와 모두 일치했다. 이전 로그인 차단·수동 전송 대기는 사용자의 로그인 완료와 실제 Console 전송으로 해소했다.

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
| Android 실행 | 사용자 명시 승인 후 독립 검수자가 Samsung SM-N960N / Android 10에서 11:01~11:07 KST에 367.202초 실행. 실제 두 돌 런처 아이콘·한 번의 cold start·AdMob 초기화 및 로드 통과. [제한 범위와 파일 해시](https://github.com/seorilabs/lucid-reversi/releases/download/v2.2.12/android-qa-v2.2.12-54.json) |
| 프로덕션 승격 | [43666943973](https://github.com/seorilabs/lucid-reversi/actions/runs/43666943973) 성공. 고정된 같은54를 internal → production, completed, 전체 출시로 승격 |
| 제출 | [제출81](https://play.google.com/console/u/0/developers/5547060480954653351/app/4973741703890923260/publishing/submission-activity/81/details): production v2.2.12 전체 출시와 ko-KR 전체 설명, API 소스, 11:16 KST 제출, 검토 중 |
| 테스트 진입 | [내부 테스트 참여](https://play.google.com/apps/internaltest/4697313818927309750) |
| 운영 안내 | 출시관리 Slack 안내가 `delivered=true`, `SENT`로 확인됨. 발송 ID `lucid-reversi-v2.2.12-build54-internal`, 이벤트 `cmwgnnq9pcpv7x801ug7sid3a` |

기존 무료 배포와 production의 명시 국가 코드 172개 및 `restOfWorld=true`를 유지한다. Console의 국가 집계 표시와 API 코드 수를 같은 수치로 해석하지 않는다. 관리형 게시는 사용 중지 상태다. iOS와 AppsInToss는 공용 서리 앱 아이콘이 아니어서 이번 변경·배포 범위에서 제외했다.

## 변경과 검증

- [PR #163](https://github.com/seorilabs/lucid-reversi/pull/163): 서리 로고였던 Android 일반·적응형 전경을 기존 Play 등록용 Moonlit Lacquer 흑백 돌로 교체했다.
- [PR #164](https://github.com/seorilabs/lucid-reversi/pull/164): 실제 시작 장면·좌표 입력·격리 저장·고정 시드를 쓰는 E2E와 기능 목록 v2를 도입했다. 검수에서 드러난 설정 목록의 버튼 위 스크롤을 수정하고 종료 시 BGM을 정리했다. 네이티브 SDK는 플랫폼 경계 대역으로 격리했으므로 이 실행을 실제 SDK 검수로 기록하지 않는다.
- [PR #165](https://github.com/seorilabs/lucid-reversi/pull/165): 배포 caller에서 CI 근거를 읽는 `actions: read` 권한을 추가했다.
- [PR #166](https://github.com/seorilabs/lucid-reversi/pull/166): 기존 두 돌 배치에 맞는 투명 SVG 단색 아이콘을 명시했다. 이전 AAB의 기본 Godot 단색 리소스는 존재했지만 활성 XML에서는 참조하지 않았으며, 실제 런처에 Godot 로고가 표시됐다고 판정한 것은 아니다.

완성된 AAB 원본을 구현자와 독립 검수자가 각각 읽었다. 활성 `@mipmap/icon`의 XML이 배경·전경·새 단색 drawable을 참조하며 총24개 밀도별 이미지가 있다. 대표 일반·배경은 제품 PNG와 RGBA 전체가 일치했다. 전경은 alpha 전체와 alpha>=20 영역의 RGB가 같았고, 매우 투명한 경계의 RGB 처리 차이는 원본 보고서에 구분했다. 단색 마스크는 두 돌이며 alpha>=128 영역의 최대 반경119.553px가 안전 반경132px 안에 들어간다.

AAB 서명은 `jarsigner`로 검증했다. 현재 Console에서 내려받은 업로드 인증서와 AAB PKCS7 인증서의 SHA256은 `59966e5a8de8b9c67c71faa7cedf7ee2cf492a116fd98b971cad802fe7c00077`로 같다. Play가 생성한 universal APK도 오프라인으로 검사했다. `2.2.12(54)`, arm64-v8a, 실제 게임 assets와 `project.binary`가 있으며 서명은 Play 앱 서명 키 `b067f7f6d426d114e963a782fd4075c643785798833fdb53dde4846b3309fc01`와 같다. APK SHA256은 `149e7b7b7b986b13e568f3d6e08311c8ee5b94af31b2ff5fbadbb3823fd7361d`다. 이 오프라인 검사와 별도로 다음의 실제 설치·실행 근거를 확보했다.

중앙 `5d7f6d3116521a776e7fc94631b7507ccfcb4274`에서 before-build·before-deploy에 이어 **before-release L3도 통과**했다. 기존 `native-admob`와 `native-shell`의 Android 실행 근거 결손은 승인된 실제 검수로 해소했다. 승격 workflow도 같은 SHA·tag·실행 근거를 재검증한 뒤 인증·승격했다. 공개 완료 검사는 구조 오류 없이 `approval`, `release`, `live_smoke`만 미완료다.

## 실제 Android 검수와 프로덕션 제출

사용자의 “허용”을 받은 뒤에만 Android 기기에 접근했다. 검수자는 구현자와 다른 `/root/release_device_qa`다. 대상 패키지는 기기에 없었으므로 검증된 Play 서명 APK를 새로 설치했고, 실제 설치된 APK의 SHA256과 `2.2.12(54)`를 확인했다. 기존 데이터나 대국 기록은 없었다. 앱 서랍에서 두 돌 아이콘을 확인하고 런처로 한 번 시작해 첫 안내와 보드가 정상 표시되는 것을 확인했다. 자동 SDK 로그에서 `initialization_completed`와 `interstitial loaded`가 실제 target PID에서 관찰됐으며, 캡처한 로그에 fatal·ANR·Godot script error 지표는 없었다.

실행은 2026-11-15 02:01:23.993116~02:07:31.195008 UTC, 367.202초였고 재시도는 없었다. 광고 표시·클릭, 새 대국·수동 플레이, 앱/OS 설정 변경, 삭제·초기화는 하지 않았다. 앱만 종료하고 설치·생성 데이터는 보존했다. Android 13 테마 아이콘의 실제 런처나 사용자 데이터 이전을 검증했다고 주장하지 않는다. 단색 아이콘은 앞서 실제 AAB의 활성 XML과 마스크로 검사했다. Android release configuration fingerprint는 `364f0f8d882f8d61c6bc86cf8583c1e11bddf42255e10bfccb7c551df29e8cd7`이다. GA4 설정 존재는 검사했으나 수집 서버의 실제 유입은 확인하지 않았다.

승격은 [43666943973](https://github.com/seorilabs/lucid-reversi/actions/runs/43666943973)에서 02:16:31 UTC에 성공했다. 새로 빌드하거나 다른 번호를 선택하지 않았다. 02:17:23 UTC Publisher readback에서 production은 `v2.2.12 / completed / 54`이고 AAB SHA, 3개 언어 출시 노트, 기존 명시 국가 코드172개와 `restOfWorld=true`가 일치했다. 이 API 상태를 실제 공개로 해석하지 않는다. 조회용 편집은 204로 종료했다.

02:18:39 UTC Console의 제출81 세부 화면은 API 제출, 11월15일 오전11:16, 프로덕션 전체 출시와 한국어 전체 설명 변경, `검토 중`을 표시했다. 이전 판매자 선언 제출80은 `출시됨`이다. 한국어 전체 설명 수정의 API 해시는 `967f4ceabe938460dade33e3d77e194568b467810a151e9885e31773fc761cd8`로 저장소와 같다. 02:19:50 UTC production 화면도 최신 v2.2.12를 `검토 중`으로 표시했다. 화면의 넓은 화면 API와 R8 권장 조치2개는 차단 오류가 아니며, 실제 운영 비정상 종료·ANR 수치는 데이터 없음이다. 이를 0으로 기록하지 않는다.

출시관리 Slack에 제출 상태를 전송하고 `accepted=true`, `delivered=true`, `SENT`를 확인했다. 발송 ID는 `lucid-reversi-v2.2.12-build54-production-submission81`, 이벤트는 `cmwh7gmb5lm8ax801lco2lsx3`이다. 새 버전 공개 완료로 안내하지 않았다.

02:20:46 UTC 공개 Play 페이지도 한국과 미국 모두 HTTP200이며, 포함된 버전은 `2.2.8`, 출시 노트는 이전 내용이다. 새54 공개로 판정하지 않는다.

02:21:13 UTC 게시 개요에서 빠른 사전 검사 안내가 사라지고 “변경사항을 검토 중입니다”로 전환됐다. 미전송 항목이나 새 차단 오류는 표시되지 않았다.

남은 단계는 Google의 심사 승인, 자동 공개 반영과 실제 공개54 확인이다. 승인 후 관리형 게시 해제 조작은 필요하지 않다. 재승인이나 재업로드도 필요하지 않다. 심사 철회·지원팀 연락·새 변경 제출은 하지 않는다. 자동 감시 작업은 새로 설정하지 않았다.

## 실패 이력과 보관

예비 `v2.2.11(53)`은 서명 빌드 뒤 병행한 같은 계정 조회 편집이 업로드 편집을 무효화해 HTTP400으로 실패했다. 당시 Play 트랙·번들 목록에53이 없었다. 현재 내부54와 production 승격54는 확인했지만, 제출81이 검토 중이므로 공개54와 구분한다. 이후 업로드·승격 중 같은 앱의 API 편집이나 Console 변경을 병행하지 않는다. 53의 태그·원본·실패 로그는 보존한다.

PR166의 MiniMax 검토는 최초 실행과 허용된 재시도에서 `headless-permission-required`로 완료하지 못했다. 재시도는 동일 호스트 기능 실패4회를 확인한 뒤 종료했다. 검토 성공으로 표시하지 않았으며, 공식 Godot4.6.3 export 구현과 CI·독립 에셋 검수에 근거한 자체 점검으로 병합했다.

원본 로그·CI 산출물·실패와 최종 AAB·Play APK·독립 보고서·provider readback·로컬 검토 진단의 보관 위치:

`smb://nas1dual/Data/Backup/agent-artifacts/lucid-reversi/2026-11-15/5b8268b10ea925bad0aa80bdd5a25ebed24d08e2/icon-release`

`verification-manifest.json`이 모든 원본의 크기·SHA256 대조와 NAS 사본 직접 읽기 검증 결과를 담는다. 보관 기간을 임의로 만료 삭제하지 않는다. 작은 필수 중앙 근거는 [GitHub Release](https://github.com/seorilabs/lucid-reversi/releases/tag/v2.2.12)에도 보존한다. 추적 이슈 [#162](https://github.com/seorilabs/lucid-reversi/issues/162)는 공개 미완료로 열어 둔다.

NAS 이관 검증은 456개 원본, 201,794,364bytes에 대해 완료했다. 검증 목록 SHA256은 `536a94ce0be69237675ed652a73cd6b17fd1acb3a038cbd600f0e31429688657`이다. 최초 복사 직후 불일치가 난 지점은 원본을 보존한 채 재조회했고, 완료 목록이 없는 같은 작업의 이관 폴더에서 기존 파일을 덮어쓰지 않고 내용을 대조한 뒤 나머지를 스트림 복사했다. 최종 전체 원본과 NAS 사본을 다시 직접 읽고 일치한 뒤 목록을 작성·재조회했다.

승인된 Android 원본과 제출81 증적65개(4,008,299bytes)는 별도 NAS 폴더에 스트림 복사하고 전체 bytes와 SHA256을 직접 읽어 검증했다. 복원해 사용한 APK·계획·설정·기존 개발 근거4개는 기존 보관본과 다시 대조한 뒤 참조로 연결했으며 중복 복사하지 않았다.

`smb://nas1dual/Data/Backup/agent-artifacts/lucid-reversi/2026-11-15/5b8268b10ea925bad0aa80bdd5a25ebed24d08e2/android54-submission81-20261115T022220Z`

검증 목록 SHA256: `efa5cf281c64695b5495ff852eebc0bc8da72525d77e049baf0e2e86647ccf81`. 원시 기기 화면과 로그는 비공개 NAS에만 보관했다. 작업 브라우저는 반납했으며 검증이 끝난 로컬 원본과 이번 작업의 격리 checkout은 정리한다. 설치 앱과 생성 데이터, 사용자 작업과 자격증명 프로필은 보존한다.
