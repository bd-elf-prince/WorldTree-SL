# WorldTree SL Web Art Asset Spec

이 문서는 현재 포털 시안을 실제 이미지 리소스로 교체하기 위한 공개 웹 리소스 기준입니다.

## 목표

현재 `index.html`은 외부 이미지 없이 CSS 기반으로 승인된 픽셀 RPG 홈페이지 방향을 재현합니다. 최종 품질은 아래 리소스를 개별 PNG/WebP 레이어로 분리해 적용합니다.

## 필수 리소스

| Key | File name | Size | Background | Notes |
| --- | --- | --- | --- | --- |
| Logo | `wt_logo_worldtree_sl.png` | 640x260 | Transparent | 금색 로고, 검/나무 장식 포함 |
| Hero sky | `wt_hero_sky.webp` | 2560x1440 | Opaque | 하늘, 구름, 달/별 |
| Floating islands back | `wt_hero_islands_back.webp` | 2560x1440 | Transparent | 먼 섬, 느린 패럴랙스 |
| Floating islands front | `wt_hero_islands_front.webp` | 2560x1440 | Transparent | 앞쪽 섬, 빠른 패럴랙스 |
| WorldTree | `wt_hero_worldtree.png` | 1400x1400 | Transparent | 중앙 거대 월드트리, 문/룬 발광 포함 |
| Hero party | `wt_hero_party.png` | 640x220 | Transparent | 4~5명 모험가 뒷모습 |
| Panel frame | `wt_ui_panel_9slice.png` | 96x96 | Transparent | 9-slice 패널 테두리 |
| Gold button | `wt_ui_button_gold_9slice.png` | 96x48 | Transparent | 주요 CTA 버튼 |
| Dark button | `wt_ui_button_dark_9slice.png` | 96x48 | Transparent | 보조 버튼 |
| Rank avatars | `wt_rank_avatar_sheet.png` | 8x8 cells, 64px each | Transparent | 랭킹 캐릭터 얼굴 |
| Sword sheet | `wt_sword_tiers_001_020.png` | 20 cells, 96px each | Transparent | 검 20단계 |
| Footer icons | `wt_footer_icon_sheet.png` | 12 cells, 64px each | Transparent | 가이드/랭킹/커뮤니티/계정/소셜 |

## 권장 레이어 순서

1. Opaque background: sky
2. Back parallax: distant islands and clouds
3. Mid layer: WorldTree
4. Front layer: platform, party, plants
5. UI layer: nav, ranking, cards, footer dock
6. FX layer: floating particles, tree glow, scanline overlay

## 애니메이션 기준

- `wt_hero_islands_back`: scroll/parallax 0.15x
- `wt_hero_islands_front`: scroll/parallax 0.35x
- `wt_hero_worldtree`: glow pulse 3~5s, leaf sway 6~8s
- Particles: small blue/gold sprites, opacity 0.25~0.8
- UI hover: 1~2px pixel offset, shadow contraction

## 공개 범위

홈페이지 저장소에는 공개 가능한 표시 리소스만 둡니다. 운영용 UUID, 서버 주소, 비공개 시트 구조, 인증키는 포함하지 않습니다.

## 현재 적용 상태

- CSS 기반 고정 시안: 적용 완료
- 5개국어 UI: 적용 완료
- 실제 이미지 레이어: 대기
- 서버 API 데이터 연동: 서버 계약 확정 후 진행
