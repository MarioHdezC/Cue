# Contributing to Cue

Hey! Thanks for wanting to help out with Cue. This is a small personal project, so don't worry too much about formalities — just follow these basics and we'll figure out the rest together.

## How It Works

All contributions go to the **`develop`** branch. When things are stable there, I merge into `main`. So please **open your PRs against `develop`**, not `main`.

## Getting Started

1. Fork the repo and clone it
2. Create a branch from `develop`:
   ```bash
   git checkout develop
   git checkout -b your-branch-name
   ```
3. Make your changes
4. Make sure it builds:
   ```bash
   xcodebuild -project Cue.xcodeproj -scheme Cue -destination 'platform=macOS' build
   ```
5. Open a PR to `develop` and describe what you did

## A Few Things to Keep in Mind

- The project uses only native Apple frameworks — no external dependencies
- SwiftUI + SwiftData, MVVM with `@Observable`, targeting macOS 26+
- If you change any user-facing text, the app has English and Spanish localizations (String Catalogs)
- If your change touches the UI, a screenshot in the PR is always appreciated

## Found a Bug?

Open an [issue](https://github.com/MarioHdezC/Cue/issues) — just tell me what happened, what you expected, and how to reproduce it.

## Not Sure About Something?

Open an issue and let's talk about it before you start coding. That way we avoid surprises on both sides.
