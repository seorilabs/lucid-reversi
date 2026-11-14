# 실행 기능 목록과 E2E

정본은 [feature-inventory.json](feature-inventory.json)이다. `npm run test:e2e`는 실제 시작 장면에서 좌표 입력으로 15개 기능 그룹을 검수한다. `npm run test:e2e:render`는 같은 여정을 렌더링해 PNG를 남긴다. 시작 장면·규칙·AI·화면을 대체하지 않으며 저장 경로, 분석 전송, 광고 요청, 공유, 외부 링크만 격리한다.

| 시나리오 | 실제 실행 범위 |
|---|---|
| first-run-and-icons | 첫 안내의 다음·이전·완료·저장, 실제 시작 scene, Android 아이콘 리소스 크기 |
| ai-play-undo-hint-and-cancel | AI 응수, 합법수 힌트, 기보, 무르기, 새 게임 취소·확정, 분석 전송의 headless 비활성/렌더 대역 |
| ai-difficulties-colors-and-finished-stats | 난이도 4개 선택, HARD 별도 스레드 응수, 흑·백 선택, 실제 한 판 종료와 전적 1회 집계 |
| settings-localization-accessibility | 콘텐츠 위 드래그 스크롤, 소리·음악·진동·표시·모션·고대비, 글자 크기, 독립 보드·돌 테마, 언어 3개, 지원 링크 경계·안내 다시 열기 |
| local-anti-game-results-replay | 로컬 2인, 역 규칙, 보드 크기 3개, 실제 종국, 하이라이트, 공유, 긴 기보, 복기 이전·다음·자동·정지, 재실행 후 결과 복원·중복 광고 방지 |
| puzzle-and-save-isolation | 퍼즐 목록 3개, 첫 퍼즐 착수·결과, 종료·재실행 시 정상 대국 복원 |
| save-restart-corruption-recovery | 착수·보드·기보·설정 복원, 잘못된 저장의 안전 복구와 환경설정 보존 |

`native-admob`과 `native-shell`의 E2E는 플랫폼 경계 요청만 확인한다. 실제 Android SDK·진동·클립보드·링크·안전 영역의 검수는 별도이며, 대역을 네이티브 통과로 기록하지 않는다. 세부 규칙·모든 테마·각 퍼즐 목표·전적·저장 형식·레이아웃의 독립 단위/통합 검사는 기존 `npm test`에 유지한다.

결과는 `build/e2e*/journey.json`, `execution.json`, `godot.log`에 기록하며 시간 초과·Godot 오류·기능 누락은 exit 1이다. 실행마다 `sandbox`의 두 테스트 파일만 새로 만들고 사용자 `user://save_v1.json`과 환경설정은 사용하지 않는다. 실제 후보 근거는 소스 SHA를 고정한 후 다시 실행해 Release 자산으로 보관한다.
