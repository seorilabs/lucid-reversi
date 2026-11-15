# Android54 데이터 보안 선언 정정

**데이터 보안 선언의 실제 Console 검수를 마치고 같은54를 재심사 제출했다. 새 제출82는 2026-11-15 15:02KST 접수, 현재 검토 중이다.** 관리형 게시는 꺼져 있어 승인 후 자동 공개된다. 15:05KST 한국·미국 공개 페이지는 아직2.2.8이며 승인·공개 완료로 판정하지 않는다.

고정 후보는 `v2.2.12(54)`, source `5b8268b10ea925bad0aa80bdd5a25ebed24d08e2`다. 제품 코드·SDK·서명·릴리스 노트·기존 무료 배포·국가 코드172개와 `restOfWorld=true`를 유지했다. 게임 코드나 SDK를 바꾸지 않는 정책 정정이므로 같은54를 쓴다. 기기를 다시 조회하거나 조작하지 않았으며 같은 후보의 중앙 Google Play before-release L3도 이번 작업에서 다시 통과했다.

## 실제 처리와 저장한 선언

기계 입력은 [data-safety.csv](../../play-store/policy/data-safety.csv), 판단 근거와 원격 상태는 [data-safety.json](../../play-store/policy/data-safety.json)이다.

| 데이터 유형 | 수집 | 공유 | 선택 여부 | 용도·근거 |
|---|---|---|---|---|
| 이름 | 예 | 아니오 | 선택 | 지원 메일에 이용자가 포함한 발신자 표시 이름, 문의 응답 |
| 이메일 주소 | 예 | 아니오 | 선택 | 지원 문의의 회신용 주소, 문의 응답 |
| 이메일 | 예 | 아니오 | 선택 | 이용자가 직접 보낸 문의 제목·본문, 고객지원 |
| 대략적인 위치 | 예 | 예 | 필수 | AdMob IP 기반 위치 추정, 광고·분석·부정행위 방지 |
| 앱 상호작용 | 예 | 예 | 필수 | AdMob 앱 실행·광고 상호작용 및 GA4 이벤트 |
| 진단 | 예 | 예 | 필수 | AdMob 앱·SDK 성능·진단, 광고·분석·부정행위 방지 |
| 기기 또는 기타 ID | 예 | 예 | 필수 | AdMob AAID·app set ID와 GA4 무작위 설치·세션 식별자 |
| 기타 작업 | 예 | 아니오 | 필수 | GA4의 대국 시작·종료·난이도·승패·수·돌 개수 등 게임 통계, 분석 |

임시 처리는 모두 아니오다. 지원 정보는 이용자가 메일을 보낼 때만 받으며 대국에 이름·이메일 입력은 필요하지 않다. 문의 정보를 광고·분석 식별자와 연결하거나 광고에 쓰는 동작도 없다. 사용자 주도 전달과 개발자를 대신하는 서비스 제공자 처리를 별도 제3자 공유로 선언하지 않는 Google 기준을 적용했다. 받은편지함 전체·연락처·통화·SMS를 읽는 것으로 선언한 것이 아니다.

`godot/scripts/bootstrap/main.gd:2395`의 지원 버튼은 외부 메일 앱으로 `mailto:cs@seorilabs.com`을 연다. `analytics.gd`와 `ga4_mp_sender.gd`는 게임 이벤트·무작위 client/session ID만 보내며 이메일 필드는 없다. Platform addon은 동봉된 라이브러리이고 현재 시작 경로에서 계정·로그인을 초기화하지 않는다. Android AdMob 의존성은24.9.0이다. 현재 공식 SDK 공개 안내는 최신25.5.0의 처리 설명이므로 버전별 설명을 혼동하지 않고 실제54 구성·광고 초기화/로드와 함께 대조했다. Google이 이메일을 관측한 정확한 네트워크 요청의 원인까지 규명한 것은 아니다.

암호화와 삭제 요청은 기존 설정을 유지했다. 실제 앱의 GA4는 HTTPS, AdMob은 TLS이며 지원 문의에는 별도 메일 앱·서비스의 보안도 적용된다. 기존 삭제 요청 연락처는 cs@seorilabs.com이고 제품 방침 URL에 요청 방법이 있다. 무작위 분석 식별자를 지원 이메일과 자동 연결할 수 있다고 주장하지 않는다. 계정 생성·외부 계정 로그인은 없음, 독립 MASA 보안 심사·UPI 배지는 아니오이며 계정 삭제 URL은 대상이 아니다.

## API·웹·심사 상태의 구분

1. 04:33 UTC 등록된 동일 Publisher가 개발자 계정 `5547060480954653351`의 `ACCESS_GRANTED`, 전역 앱 콘텐츠 관리 권한을 가진 것을 API로 재확인했다. 이 계정의 이름·유형은 이전 직접 Console 검수에서 Seori Apps 개인 계정으로 확인했다. 04:34 UTC 조회에서 기존 production/internal54, 정확한 번들 SHA와 국가·노트를 대조하고 조회 편집은204로 종료했다.
2. 공식 `applications.tracks.releases.list`에서 04:35:43 UTC에54의 `NOT_APPROVED`와50의 `PUBLISHED`를 읽어 사용자 제공 거절 통보와 대조했다. 트랙의 `status=completed`와 달리 이 lifecycle 값은 검토·공개 상태다.
3. Google Help의763행 CSV 샘플은 API400으로 계정 생성 질문 누락과 구형 용도 필드 이름을 지적받았다. 해당 실패와 입력은 보존했다. 최근 사내 Google Play CSV의782행 질문 형식만 재사용하고 모든 기존 답을 지운 뒤 이 앱의 사실로 다시 작성했다. 다른 앱의 정책 답안은 복사하지 않았다.
4. 04:37:52 UTC `applications.dataSafety`가 정정안을 **HTTP204**로 접수했다. 저장 파일 SHA256은 `abc25400f48361fee133bd89671dacd2b29227185aff95eff2a04b9ae83a0f89`, 요청 본문의 줄바꿈 정규화 후 SHA256은 `a82013a07809162139ddc0036b4cdaaf13724a6a674a5028b7846df9853a7528`이다. 빈 성공 응답은 입력 저장 근거이며 Console의 실제 폼 재조회나 Google의 정책 승인은 아니다.
5. 같은54를 재심사로 보내려는 검증에서 Google이 `Changes cannot be sent for review automatically. Please set ... changesNotSentForReview to true ... sent for review from the Google Play Console UI`라고 HTTP400으로 응답했다. 실패한 조회·검증용 편집은 각각204로 정리했다. 이 검증을 통과나 제출로 기록하지 않았다.
6. 04:40:28 UTC Google이 안내한 `changesNotSentForReview=true`로 같은54를 저장했다. `changesInReviewBehavior=ERROR_IF_IN_REVIEW`를 명시해 진행 중인 검토를 취소하지 않았다. commit은HTTP200, 편집 ID는 `07627815509965188082`다. **미전송 저장이며 새 심사 제출이 아니다.** 04:40:57 UTC lifecycle도 여전히54 `NOT_APPROVED`,50 `PUBLISHED`였다. 새 Console 제출 ID는 없다.

웹 방침은 [사이트 PR125](https://github.com/seorilabs/seorilabs-official/pull/125)로 수정했다. 후보64f1d58의 L1 실제 브라우저4조건, 대상 Prettier, typecheck, build, 중앙 web before-deploy·before-release가 통과했다. [배포43677219193](https://github.com/seorilabs/seorilabs-official/actions/runs/43677219193)의 main `9884c7db39d711b1ae1bac3b477bc0a5d6e2e1b8`은 후보와 같은 tree이며, 04:34:34 UTC 공개 한국어·영어 URL에서 HTTP200과 수정된 지원·SDK·날짜 본문을 다시 읽었다.

- [한국어 제품 방침](https://www.seorilabs.com/apps/lucid-reversi/privacy/)
- [영어 제품 방침](https://www.seorilabs.com/en/apps/lucid-reversi/privacy/)

## 로그인 완료 뒤 Console 검수와 제출82

사용자가 “로그인 완료”라고 알린 뒤 해당 작업 세션을 자동화 모드로 돌렸다. 05:57:04 UTC 실제 Google 로그인 identity와 Seori Apps 개인 계정5547060480954653351, 루시드 리버시 패키지를 다시 확인했다. 제출 직전 같은 source5b8268b·tagv2.2.12의 중앙 before-release L3도 통과했다.

Console에서 내려받은 CSV는782행이며 기존 정정안과 질문·응답 ID가 모두 같았다. 불리언 대소문자와 선택하지 않은 빈 값/false를 정규화해 대조한 결과 차이는0개다. 실제 export SHA256은 eda89c104b51a2811e9823cec1f613bd6d14e864135a0afe93f6901673b3b642다. 실제 화면에서도8개 데이터 유형의 취급·처리가 모두 완료됐고, 미리보기의 수집8유형·공유4유형과 암호화·삭제 URL을 읽었다. 답을 바꾸지 않아 저장 버튼은 비활성인 상태였다. 저장 완료를 API 응답만으로 추정한 것이 아니라 실제 Console 값과 대조했다.

06:01:28 UTC 게시 개요에 전송 가능한 변경3개가 있었다. 프로덕션 v2.2.12 전체 출시, ko-KR 전체 설명, 데이터 보안 설문지다. 06:02:24.646883 UTC 전송 확인 버튼을 누른 뒤, 제출 활동과 세부 화면을 별도로 읽었다. 새 [제출82](https://play.google.com/console/u/0/developers/5547060480954653351/app/4973741703890923260/publishing/submission-activity/82/details)는 소스Play Console, 제출 시각15:02KST(분 단위 표시), 변경3개, 검토 중이었다. 기존81은 거부됨으로 표시돼 새82와 구분된다. 새 제출 후 실제 API lifecycle 조회는403 Listing releases quota exceeded였으므로 반복하거나 자격증명을 바꾸지 않고 Console 상태를 근거로 사용했다.

06:06:56 UTC 게시 개요의 사전 검사 안내가 사라지고 “변경사항을 검토 중입니다”로 바뀌었다. 관리형 게시는 여전히 사용 중지였다. 실제 공개 페이지는06:05:34 UTC 한국·미국 모두HTTP200, 버전2.2.8이었다. [제출·대조 요약](https://github.com/seorilabs/lucid-reversi/releases/download/v2.2.12/data-safety-resubmission82.json)도 태그 Release에 보존했다.

## 남은 실행

필요한 수동 로그인과 Console 재심사 전송은 해소했다. 작업용 브라우저를 반납하고 로그인 프로필은 보존했다. 남은 단계는 Google 심사 승인과 자동 공개, 실제 공개54 확인이다. 새 빌드·출시 재승인·추가 기기 사용은 필요하지 않다. 자동 감시 작업은 설정하지 않았다. 아직 심사 승인·공개를 완료로 표시하지 않는다.

근거: [Google Play 데이터 보안 안내](https://support.google.com/googleplay/android-developer/answer/10787469), [Google Mobile Ads Android 데이터 공개 안내](https://developers.google.com/admob/android/privacy/play-data-disclosure), [공식 release lifecycle API](https://developers.google.com/android-publisher/api-ref/rest/v3/applications.tracks.releases), [심사 전송 제한을 설명하는 commit API](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit).

## 증적 보관과 정리

원본44개, 2,496,648bytes를 NAS에 스트림 복사하고 직접 읽은 크기·SHA256을 대조했다. 보관 기간 만료 삭제는 승인되지 않았다.

`smb://nas1dual/Data/Backup/agent-artifacts/lucid-reversi/2026-11-15/5b8268b10ea925bad0aa80bdd5a25ebed24d08e2/data-safety54-20261115T044717Z`

검증 목록 SHA256: `746f27fc0fac071b0b751a6a32f5941c3aabe9e29828c77bd6871f49a838948f`. 성공한 CSV·정책 JSON은 Git 정본이고, 웹 실행 근거의 작은 JSON은 사이트 development-evidence Release에도 있다. 재다운로드 가능한 샘플·참고 근거·이미 PR에 있는 본문 입력은 중복 백업하지 않았다. 검증된 로컬 원본·빌드·격리 checkout은 정리하고, 당시 사용자 로그인 인계용 Edge 세션과 최소 파일만 유지했다. 이번 로그인 완료·제출82 확인 뒤 기존 임시 인계 파일3개도 정리하고 세션을 반납했다. 이전 NAS의 인계 원본은 보존한다.

출시관리 안내는 Backoffice에서 접수됐다. ID `lucid-reversi-v2.2.12-build54-data-safety-manual-review`, 이벤트 `cmwhcp974wgxbx801ifp8unrh`이며 확인 시한에는 `accepted=true`, `delivered=false`, `PENDING`이었다. 실제 Slack 전달을 완료로 기록하지 않았다.

제출82 운영 안내는 Backoffice에 접수됐다. ID lucid-reversi-v2.2.12-build54-resubmission82, 이벤트 cmwhfm2743d1vx801i2qesuqd이며 확인 시한에는 accepted=true, delivered=false, PENDING이었다. 이전 미전송 안내와 새82 접수를 구분하고 실제 Slack 전달을 완료로 기록하지 않았다.

이번 Console 선언 재조회와 제출82 원본44개, 312,849bytes도 별도 NAS 폴더에 스트림 복사한 뒤 모든 bytes·SHA256을 직접 읽어 대조했다.

smb://nas1dual/Data/Backup/agent-artifacts/lucid-reversi/2026-11-15/5b8268b10ea925bad0aa80bdd5a25ebed24d08e2/resubmission82-20261115T061136Z

검증 목록 SHA256: 8673b2b791c155e67eb35878cbc02aa31c1dd5931798fb64d082f7ad19d515f2. 같은 후보의 중앙 검사 로그, 실제 Console export·782응답 비교, 단계별 화면 텍스트, 전송 동작과 제출82 상세, 공개 버전 조회 및 API quota 응답을 포함한다. 검증한 로컬 원본과 브라우저 다운로드 사본을 정리하고 로그인 프로필은 유지한다.
