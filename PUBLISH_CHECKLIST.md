# WorldTree Web MVP Publish Checklist

## Goal

Publish the official WorldTree portal and playable web-game MVP today.

## Must pass before sharing URL

- [ ] GitHub Pages enabled for `main` / root.
- [ ] `index.html` opens as the official portal.
- [ ] Start button opens `game.html`.
- [ ] `game.html` runs without console-blocking errors.
- [ ] Mobile viewport shows a usable layout.
- [ ] Explore nodes can be clicked or tapped.
- [ ] AP decreases when moving.
- [ ] Wood / Gold / Power / RP values update.
- [ ] Return / Rebirth opens the run result modal.
- [ ] Refresh keeps progress through localStorage.
- [ ] Portal copy clearly says this is an MVP/local-save build.

## Known MVP limits

- Save data is browser localStorage only.
- Sera chat is local MVP response only.
- Ranking and account data are placeholders until server API contract is connected.
- Pixel-art images are not yet wired into the web build; emoji placeholders are temporary.
- Second Life card HUD work remains paused at the v6.5.7 baseline.

## Next low-risk tasks

1. Add inventory modal.
2. Add item detail panel.
3. Add log/wood resource icons.
4. Replace portal emoji with generated pixel-art assets.
5. Add KO / EN / JA / PT / ZH text map as a separate data object.
6. Add a visible build version label.
