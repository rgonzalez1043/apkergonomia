# Interactive body map

This directory contains the local Three.js runtime and the pain-region body
map. The viewer loads `male_anatomy_figure.glb`, adds 27 invisible anatomical
hit volumes, and uses `THREE.Raycaster` to map taps to Flutter `BodyRegion`
values.

## Interaction contract

- A short tap selects a region; a drag rotates the model.
- Front-only torso regions are ignored from the back and vice versa.
- Anatomical left is positive X when the person faces the camera.
- The selected hit volume becomes visible as a translucent red highlight.
- The parent Flutter widget can set `selectedRegion`, `view`, and `theme`.
- The category selector remains available as an accessible fallback.

## Vendored dependency

Three.js `0.185.1` is vendored from the official npm package so the body map
does not depend on a CDN. Its MIT license is preserved in
`THREE_LICENSE.txt`.
