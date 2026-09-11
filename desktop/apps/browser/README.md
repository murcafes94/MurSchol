# MurSchol Browser

MurSchol Browser is the desktop browser for MurSchol OS. Its desktop source strategy is:

`Firefox/Gecko -> Zen Browser -> MurSchol Browser`

The repository does not vendor the entire Firefox/Zen tree. Instead it keeps a reproducible preparation layer so upstream security and engine updates remain manageable.

## Current architecture

- Upstream desktop UI/base: `zen-browser/desktop`
- Engine: Firefox/Gecko
- Build tooling: `@zen-browser/surfer`
- Product name: MurSchol Browser
- Binary: `murschol-browser`
- App ID: `org.murschol.browser`
- License for covered upstream/modified source: MPL-2.0
- Zen trademarks/branding assets are not reused in MurSchol releases.

## Prepare the source tree

```bash
chmod +x desktop/apps/browser/prepare-zen.sh
desktop/apps/browser/prepare-zen.sh
```

To pin another upstream ref:

```bash
ZEN_REF=stable desktop/apps/browser/prepare-zen.sh
```

The script clones Zen into `desktop/apps/browser/.work/zen`, replaces its Surfer product configuration with the MurSchol configuration, and rewrites package metadata for the MurSchol project.

## Build locally

After preparing the source tree:

```bash
cd desktop/apps/browser/.work/zen
npm ci
npm run init
npm run build
npm run package
```

Firefox/Zen builds are large and need substantially more disk, RAM and build time than the Qt applications in MurSchol OS. For that reason the browser is intentionally kept out of the ordinary lightweight desktop build until its dedicated CI image is stable.

## Live ISO integration

The Live ISO exposes `/usr/local/bin/murschol-browser` and `murschol-browser.desktop` as the default HTTP/HTTPS handler.

Resolution order during the alpha is:

1. packaged MurSchol Browser under `/opt/murschol-browser`;
2. an installed MurSchol/Zen-compatible binary;
3. Firefox ESR as a recovery fallback.

Firefox ESR is not presented as the MurSchol browser; it exists temporarily to guarantee emergency web access while the branded browser package is being completed.

Microsoft Edge is deliberately not included or offered by MurSchol OS.

## Planned MurSchol-specific layer

- MurSchol visual identity and light/dark integration;
- study-oriented workspaces;
- Study Mode integration with MurSchol Desktop;
- split browsing for web + notes/PDF workflows;
- `murschol://` deep links for NotCan, Library, Ministerium and Settings;
- shared workspace metadata between the browser and MurSchol Desktop;
- mobile companion on GeckoView/Firefox Android architecture rather than attempting to run desktop Zen on Android.
