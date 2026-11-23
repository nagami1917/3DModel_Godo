# Knight Web Preview

A Vite static site for viewing `medieval_knight.glb` in a browser. It uses Google's `<model-viewer>` web component for orbit, zoom, and download controls and is intended for Vercel with this directory as the project root.

## Run locally

```sh
npm ci
npm run dev
```

## Build

```sh
npm run build
```

`public/medieval_knight.glb` is the deployable copy of the Godot asset at `godot_character_generator/assets/characters/medieval_knight/medieval_knight.glb`. Keep the copies in sync when the model changes. The character is static and has no animation clips.
