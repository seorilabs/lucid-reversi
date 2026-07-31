# Lucid Reversi

루시드 리버시는 Godot 기반 AI·로컬 2인 리버시 게임이다. 현재 출시 우선순위는 AppsInToss first이며, Google Play와 Apple App Store는 후속 마켓으로 repo-local inventory를 유지한다.

이 repo는 `starter-template-game`을 기반으로 시작했다. 마켓 등록값은 확정되지 않은 항목을 `확정 필요` 또는 후보로 남긴다.

## 구조

```text
docs/                  # 기획, 의사결정, 작업, 마켓, 릴리스 원장
packages/product-core/ # 엔진 독립 도메인/유스케이스/포트
godot/                 # Godot project, Reversi UI, rules engine, smoke tests
apps/ait/              # AppsInToss Web wrapper 자리
firebase/              # Firebase rules/indexes/functions 자리
play-store/            # Google Play registration/release metadata
app-store/             # Apple App Store registration/release metadata
apps-in-toss/          # AppsInToss console/release metadata
scripts/               # local/CI quality gates
```

## 기본 명령

```bash
npm run test:core
npm run check:architecture
npm run test:godot
npm run check:docs
npm run check:release
npm run check:release:ait
npm run build:godot:web
```

`check:release`는 템플릿 placeholder가 남아 있으면 실패한다. 릴리스 직전 blocker inventory 용도다.

`check:release:ait`는 AppsInToss-first 후보 경로만 점검한다. Google Play/App Store 미확정값은 이 경로의 blocker로 취급하지 않는다.

`main`에 push되면 GitHub Actions가 Godot Web export를 만들고 GitHub Pages에 배포한다. private repo의 Pages 사이트는 조직/플랜 설정에 따라 외부 공개될 수 있으므로, 민감한 리소스를 export에 포함하지 않는다.
