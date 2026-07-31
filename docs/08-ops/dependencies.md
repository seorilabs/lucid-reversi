# Dependencies

## Shared Versions

- Godot: `4.6.3.stable`
- Node in CI: major `24`
- Seorilabs ARC shared source: `/Users/syous/Workspace/kubectl/github-actions-runners/global-versions.yaml`

## GitHub Actions

2026-06-18 확인 기준:

- `actions/checkout@v6`
- `actions/setup-node@v6`
- `actions/upload-artifact@v7`
- `actions/configure-pages@v6`
- `actions/upload-pages-artifact@v5`
- `actions/deploy-pages@v5`

## Bundled Fonts

- Do Hyeon Regular: Korean/Latin UI primary font, SIL Open Font License 1.1.
- M PLUS Rounded 1c Regular: Japanese UI fallback font, SIL Open Font License 1.1.
- Font binaries and license texts are kept together under `godot/assets/fonts/`.

## Policy

- 템플릿에는 검증하지 않은 SDK 버전을 고정하지 않는다.
- AppsInToss wrapper, Firebase SDK, store SDK는 실제 프로젝트 생성 시 공식 문서와 repo-local lockfile로 확정한다.
- Dependabot은 GitHub Actions와 npm ecosystem을 감시한다.
