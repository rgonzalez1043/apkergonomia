# Exercise video sources

ErgoWorkCoach uses real-person movement videos. The exercise experience does
not use photographs, generated images, drawings, GIFs, or static fallbacks as
movement demonstrations.

## Playback policy

- Videos are embedded from YouTube with the official iframe player.
- Playback is paused initially and includes native controls and fullscreen.
- Privacy-enhanced mode uses `youtube-nocookie.com` until playback begins.
- No third-party video is downloaded, edited, or distributed with the app.
- The original provider is identified below the player and linked directly.
- A missing video shows an unavailable state, never a substitute image.
- Internet access and continued availability at the provider are required.

## Catalog controls

The single source of truth is
`lib/features/pain/presentation/widgets/exercise_media_catalog.dart`.

Automated tests require all 66 seeded exercises to have:

1. A registered movement assignment.
2. A valid 11-character YouTube video ID.
3. A source label and HTTPS source page.
4. An explicit real-person marker.

The current catalog contains 35 unique movement videos. On 2026-08-30 all 35
returned valid YouTube oEmbed metadata. The catalog also has a regression test
for the easily confused knee-rolling and straight-leg-raise assignments.

## Primary providers

- South Tees Hospitals NHS Foundation Trust: neck, shoulder, spine, wrist,
  hand, knee, and forearm exercises.
- Oxford University Hospitals NHS Foundation Trust: trunk and calf exercises.
- Barts Health NHS Trust: single-leg heel raise.
- NHS Greater Glasgow and Clyde: calf raises.
- NHS Ayrshire and Arran: mini squat.
- University Hospitals Plymouth NHS Trust: ankle pumps.
- South West UK Burn Care Network: ankle circles.
- East Suffolk and North Essex NHS Foundation Trust: piriformis stretch.
- Hospital Universitario de La Princesa: diaphragmatic breathing.
- Cornell Health, Speare Memorial Hospital, Henry Ford Health, Emory
  Healthcare, and National University Hospital Singapore: selected movements.

Exact video identifiers, source labels, and source URLs are intentionally kept
next to each movement in the catalog so changes can be reviewed in one place.

## Clinical release checklist

A qualified local reviewer must confirm each assignment before clinical use:

1. The demonstrated movement matches the Spanish name and instruction.
2. The visible range, posture, and equipment are appropriate for the pain stage.
3. Laterality is correct or the movement is safely bilateral/non-specific.
4. Repetitions, hold time, progression, and contraindications agree.
5. The source video has not changed, been removed, or disabled for embedding.

Publication by a healthcare provider does not make the app's prescription
patient-specific and does not replace an assessment by a qualified clinician.
