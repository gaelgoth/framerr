<p align="center">
  <img src="design/app-icon/framerr.svg" width="160" alt="framerr icon">
</p>

<h1 align="center">framerr</h1>

<h4 align="center">Frame, order and export your photos for social posts in seconds.</h4>

<p align="center">
  <a href="https://github.com/gaelgoth/framerr/actions/workflows/ci.yml"><img src="https://github.com/gaelgoth/framerr/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#install">Install</a> •
  <a href="#contribute">Contribute</a> •
  <a href="#release">Release</a> •
  <a href="#license">License</a>
</p>

## Features

- Post ratios 1:1, 4:5, 1.91:1, 5:4 and 9:16 at their exact pixel sizes
- Border width and color
- Compression-friendly JPEG export

## Install

Download the latest `.dmg` from [Releases](https://github.com/gaelgoth/framerr/releases) and drag framerr to Applications. Requires macOS 27.

framerr is not signed with an Apple Developer ID or notarized, so macOS blocks it on first launch. Open **System Settings → Privacy & Security** and click **Open Anyway**, or run:

```bash
xattr -cr /Applications/framerr.app
```

## Contribute

Requires Xcode 27.

```bash
git clone git@github.com:gaelgoth/framerr.git
cd framerr/framerr
open framerr.xcodeproj
```

Install the formatter and linter:

```bash
brew install swiftformat swiftlint
```

Auto-fix formatting and lint issues (from `framerr/`, where the configs live):

```bash
swiftformat .
swiftlint --fix
```

Before opening a pull request, run the same checks as CI:

```bash
swiftformat --lint .
swiftlint lint --strict
xcodebuild test -project framerr.xcodeproj -scheme framerr -destination 'platform=macOS'
```

## Release

Releases are automated with [release-please](https://github.com/googleapis/release-please).

1. Write commits as [Conventional Commits](https://www.conventionalcommits.org): `fix:` bumps the patch, `feat:` the minor (while < 1.0), `feat!:` the major. Other types don't appear in the changelog.
2. On every push to `main`, CI opens or updates a `chore(main): release x.y.z` pull request with the new version and `CHANGELOG.md`.
3. Merge that pull request. CI tags `vx.y.z`, publishes the GitHub Release with the changelog as notes, and attaches the DMG.

The version lives in `.release-please-manifest.json`; CI passes it to the build as `MARKETING_VERSION`. Only release-please edits that file — don't change it by hand.

To force a specific version, push a commit to `main` with a `Release-As` footer. It applies to the next release only:

```bash
git commit --allow-empty -m "chore: release 1.0.0" -m "Release-As: 1.0.0"
```

## License

[MIT](LICENSE)
