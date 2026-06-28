# Web Team Sync — WorldTree Portal / Game MVP

## Current publication target

Today we are pushing the public portal and playable web-game MVP forward.

## Current files

- `index.html` — public portal / launcher.
- `game.html` — playable local-save game MVP.
- `README.md` — repository summary and publish target.
- `PUBLISH_CHECKLIST.md` — manual publication checklist.

## Current game MVP state

`game.html` includes:

- Explore map with clickable nodes.
- AP cost and movement.
- Wood, Gold, Power, RP, TreeLv, Best distance.
- Return / Rebirth result modal.
- Browser localStorage save.
- Sera local lobby response.
- Inventory modal and item-detail panel.
- Mobile responsive fallback.

## Web design team handoff

Please verify:

1. GitHub Pages is enabled for `main` / root.
2. `index.html` opens from the Pages URL.
3. The start button opens `game.html`.
4. `game.html` works on desktop and mobile.
5. The current emoji placeholders should be replaced with pixel-art assets in this order:
   - WorldTree logo / emblem
   - player portrait
   - Sera portrait
   - forest / cave / camp / chest / snow / ruin map nodes
   - wood inventory icon
   - sword inventory icon

## Art team handoff

Use the already approved WorldTree visual direction:

- crisp pixel art
- strong square pixels
- ornate fantasy UI
- dark navy / forest green / gold palette
- clear asset boundaries
- web-safe public assets only

## Server handoff

Do not block current web UI on server API. Keep placeholder / localStorage flow until API contracts are ready.

Future API replacement areas:

- save/load account state
- public ranking
- account hub data
- Sera chat bridge
- inventory/resource sync

## Next low-risk commits

1. Replace emoji nodes with CSS pixel placeholders or static SVG placeholders.
2. Add i18n text map for KO / EN / JA / PT / ZH.
3. Add a visible build version to portal footer.
4. Add asset manifest document.
5. Add lightweight smoke-test checklist for browser publication.
