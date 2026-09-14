# MurSchol Browser

MurSchol Browser is the desktop browser for MurSchol OS. Its desktop source strategy is:

`Firefox/Gecko -> Zen Browser -> MurSchol Browser`

The repository does not vendor the entire Firefox/Zen tree. Instead it keeps a reproducible preparation layer so upstream security and engine updates remain manageable.

## Current architecture

- Upstream desktop UI/base: `zen-browser/desktop`, branch `stable`
- Engine: Firefox/Gecko
- Build tooling: `@zen-browser/surfer`
- Product name: MurSchol Browser
- Binary: `murschol-browser`
- App ID: `org.murschol.browser`
- License for covered upstream/modified source: MPL-2.0
- Zen trademarks/branding assets are not reused in MurSchol releases.

## Upstream-safe branding layer

`murschol-surfer.json` is intentionally a MurSchol branding overlay, not a frozen copy of Zen's complete `surfer.json`.

During preparation, MurSchol keeps the current Zen `stable` engine and build metadata, including the Firefox version required by that exact upstream revision, then overlays the MurSchol product identity. This prevents a Zen/Firefox update from leaving MurSchol pinned to an obsolete engine version.

The preparation step also:

- keeps only the `release` brand and drops Zen-specific secondary brands;
- removes Zen's `updateHostname`, so MurSchol does not contact or advertise Zen's update infrastructure as its own;
- rewrites the package metadata and lockfile root name to `murschol-browser`;
- records the exact Zen commit and Firefox engine version in `MURSCHOL_UPSTREAM.md` inside the prepared working tree.

## Prepare the source tree

```bash
chmod +x desktop/apps/browser/prepare-zen.sh
desktop/apps/browser/prepare-zen.sh
```

The script can also be invoked without relying on the executable bit:

```bash
bash desktop/apps/browser/prepare-zen.sh
```

To pin another upstream ref for testing:

```bash
ZEN_REF=stable bash desktop/apps/browser/prepare-zen.sh
```

The script clones Zen into `desktop/apps/browser/.work/zen`, merges the MurSchol branding layer into the current upstream Surfer configuration, and rewrites package metadata for the MurSchol project.

## Build locally

After preparing the source tree:

```bash
cd desktop/apps/browser/.work/zen
npm ci
npm run init
npm run build
npm run package
```

Firefox/Zen builds are large and need substantially more disk, RAM and build time than the Qt applications in MurSchol OS. For that reason the full browser binary remains outside the ordinary lightweight desktop build until its dedicated build pipeline is stable.

## Continuous compatibility check

`.github/workflows/validate-browser.yml` prepares a fresh copy of Zen `stable`, validates the resulting MurSchol Surfer configuration, verifies the npm lockfile with `npm ci --ignore-scripts`, checks desktop/MIME integration and confirms that Microsoft Edge integration remains absent.

The workflow runs on browser integration changes, manually, and once per day so an incompatible upstream Zen change can be detected before an ISO release.

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
