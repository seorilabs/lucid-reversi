# GitHub Actions

## Workflows

- `Godot Compile`: Godot import, compile, smoke scene.
- `Repository Checks`: core, architecture, docs checks.
- `Deploy Godot Web Pages`: `main` push 후 Godot Web export를 GitHub Pages로 배포. **현재 저장소에 Pages가 활성화돼 있지 않아 `Configure Pages` 단계에서 실패한다.** Pages를 켜거나 이 workflow를 내리는 결정이 필요하다.
- `Release Inventory`: manual release blocker inventory.

## Runner Routing

- 템플릿 workflow는 public/private 양쪽에서 안전하게 동작하도록 `github.event.repository.private` 조건을 둔다.
- private repo에서는 `seorilabs-rpi-arm64`를 사용한다.
- public repo 또는 public PR path에서는 `ubuntu-latest` fallback을 사용한다.
- Android release build와 App Store build는 RPI ARC로 보내지 않는다.

## Central Source

runner 이름과 scale set 용량의 정본은 Seorilabs ARC 운영 저장소의
`global-versions.yaml`이다. 값은 운영 중 바뀌므로 workflow를 수정하기 전에
`seorilabs-arc-runners` 스킬로 현재 값을 다시 확인한다.
