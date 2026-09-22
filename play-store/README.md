# Google Play

Google Play 등록/릴리스 파일을 둔다.

- Store listing 결정 원장: `docs/05-markets/google-play.md`
- Store listing 문안: `listing/{ko-KR,en-US,ja-JP}.json` (Play API `edits.listings` 필드와 같은 키)
- 승계 이전 원본 등재정보: `listing/legacy-reversi-online.json` (되돌림 근거로 보존)
- Store 이미지 자산: `assets/`(아이콘 512, 피처그래픽 1024x500 3개 언어), `screenshots/phone`(1080x1920 5장), `screenshots/tablet`(1200x1920 3장, 7인치·10인치 공용)
- Config example: `google-play.config.example.json`
- Release build runner: x64 Linux
- RPI ARC route: 사용하지 않음

## 문안 한도

`title` 30자, `shortDescription` 80자, `fullDescription` 4000자. 반영 전에 확인한다.

```bash
python3 -c "
import json,glob
LIM={'title':30,'shortDescription':80,'fullDescription':4000}
for f in sorted(glob.glob('play-store/listing/*-*.json')):
    d=json.load(open(f))
    if 'language' not in d: continue
    print(d['language'], {k:f\"{len(d[k])}/{v}\" for k,v in LIM.items()})
"
```
