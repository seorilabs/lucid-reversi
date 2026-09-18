# Moonlit Lacquer UI Style Guide

## 기준

- 승인 방향: B — Moonlit Lacquer
- 승인일: 2026-09-18
- 대표 시안: docs/game-design/ui/reference-moonlit-lacquer.png
- 생성 모델: Codex 내장 gpt-image-2
- 원칙: 기능 텍스트, 점수, 아이콘은 이미지에 굽지 않고 Godot 컨트롤로 렌더링한다.

## 재질과 색

- 배경: 저채도 흑연색 탁자, 약한 달빛, 화면 가장자리의 절제된 금속 반사
- 패널: 무광 흑칠, 스모크 글라스 내부면, 얇은 황동 테두리, 하단의 옅은 목재 인레이
- 보드: 짙은 숯색 프레임과 황동 테두리, 채도를 낮춘 클래식 녹색 면
- 주 버튼: 따뜻한 상아색, 짙은 글자
- 보조 버튼: 흑칠 면, 상아색 글자, 약한 황동 테두리
- 장식은 세계 시장에서 특정 문화권으로 오해할 문양 없이 재질과 빛으로만 표현한다.

## 구성요소 계약

| 구성요소 | 파일 | 캔버스 | Godot 사용 |
| --- | --- | --- | --- |
| 배경 | moonlit-lacquer-backdrop.png | 720×1280, 불투명 | TextureRect.STRETCH_KEEP_ASPECT_COVERED |
| 패널 | moonlit-lacquer-panel.png | 370×180, 투명 | StyleBoxTexture, 9-slice 좌우 42px·상하 28px |

패널의 안전한 내용 여백은 기본 좌우 12px·상하 8px다. 작은 상태 밴드와 컨트롤 트레이는 상하 7px을 사용한다. 버튼 상태는 텍스트 없는 StyleBoxFlat으로 관리하며, normal·hover·pressed·disabled가 그림자 깊이와 테두리 대비로도 구분된다.

## 금지

- 기능 텍스트나 숫자를 래스터 이미지에 포함하지 않는다.
- 보드보다 강한 광택, 큰 문양, 반복 장식을 추가하지 않는다.
- 다른 방향의 청색 네온, 유리 카드, 밝은 배경을 혼합하지 않는다.
- 별도 화면마다 임의의 재질을 새로 만들지 않는다.
