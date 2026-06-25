# Firebase

## Decision

- Firebase usage: Phase 2 기준 사용하지 않음
- Firebase project ID: not applicable until Firebase is approved
- Environments: not applicable until Firebase is approved

## Candidate Capabilities

- Analytics: future optional
- Crashlytics: future optional
- Remote Config: future optional
- Cloud save: MVP 제외
- Leaderboard: MVP 제외
- Entitlement validation: MVP 제외

## Guardrails

- service account JSON, private key, Admin SDK credential은 client export에 포함하지 않는다.
- Firebase를 추가하는 경우 Security Rules, indexes, functions는 version control에 포함한다.
- MVP는 local-only이므로 Firebase SDK를 추가하지 않는다.
