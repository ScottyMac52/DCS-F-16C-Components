# Kneeboard image sources and redistribution

The generated kneeboard PNGs are built entirely from files committed under
`kneeboard/assets/source`; the build never downloads images. This document records the
provenance and transformations for each hardware image.

## Thrustmaster Viper TQS and Mission Pack

- Files: `viper-tqs-mission-pack-source.png` and `viper-tqs-mission-pack-clean.png`.
- Source: [Thrustmaster Viper TQS Mission Pack product page](https://www.thrustmaster.com/products/viper-tqs-mission-pack/), gallery image
  `ProductpageGallery-ViperTQS_MissionPack-1920x1080-1.png`, retrieved 2026-08-01.
- Copyright: Thrustmaster/Guillemot Corporation. No open-content license was stated on the
  product page. The image is included as manufacturer-supplied product identification artwork
  for this noncommercial compatibility reference; product names and imagery remain the
  property of their owner.
- Transformation: the original 1920 × 1080 PNG is preserved. The clean derivative removes only
  transparent canvas padding; it does not redraw or alter the hardware.

## Thrustmaster AVA/Warthog grip

- Files: `warthog-grip-template.svg`, `warthog-grip-front.png`, and
  `warthog-grip-rear.png`.
- Source: [Joystick Diagrams](https://github.com/Rexeh/joystick-diagrams), commit
  `1e9f5d0b6aeaeabc7da6fcec4122554df9da69a7`, template
  `templates/Thrustmaster/Thrustmaster Warthog - Joystick.svg`.
- License: GNU GPL v2; a copy is stored at
  `kneeboard/assets/source/licenses/joystick-diagrams-GPL-2.0.txt`.
- Transformation: the two embedded hardware views were extracted from the template and their
  white backgrounds made transparent. The original SVG is retained as the preferred source.

## WINCTRL ViperAce ICP

- Files: `viperace-icp-template.svg` and `viperace-icp-clean.png`.
- Source: [Joystick Diagrams](https://github.com/Rexeh/joystick-diagrams), commit
  `1e9f5d0b6aeaeabc7da6fcec4122554df9da69a7`, template
  `templates/WinWing/ICP/ICP.svg`.
- License: GNU GPL v2; a copy is stored at
  `kneeboard/assets/source/licenses/joystick-diagrams-GPL-2.0.txt`.
- Transformation: the transparent hardware image embedded in the upstream template was
  extracted without redrawing it. The physical layout matches the ViperAce ICP profile used by
  this repository.

## WINCTRL CarrierAce PTO2

- Files: `pto2-template.svg` and `pto2-clean.png`.
- Source: [Joystick Diagrams](https://github.com/Rexeh/joystick-diagrams), commit
  `1e9f5d0b6aeaeabc7da6fcec4122554df9da69a7`, template
  `templates/WinWing/PTO 2 Panel of Take Off/PTO 2 Panel of Take Off.svg`.
- License: GNU GPL v2; a copy is stored at
  `kneeboard/assets/source/licenses/joystick-diagrams-GPL-2.0.txt`.
- Transformation: template annotations and the page background were removed, and the result was
  converted to a transparent local derivative. The cleaned derivative remains under the same
  GPL terms.

## Thrustmaster Cougar MFDs

- Files: `cougar-mfd-template.png` and `cougar-mfd-clean.png`.
- Source: [Bindulator](https://github.com/norekdcs2020/Bindulator), commit
  `c7f0cf82432fc3f0752cffe8b9478ea726601891`, template
  `Templates/Bindulator_template_Cougar_MFD_Left_v2.pdf`.
- License: GNU GPL v2 or later; a copy is stored at
  `kneeboard/assets/source/licenses/bindulator-templates-GPL-2.0-or-later.txt`.
- Transformation: the PDF template was rendered, its annotations and page background were
  removed, and a transparent local derivative was produced. The same control image is used for
  the left and right MFD pages.

Product and company names identify compatible hardware. Their owners do not endorse this
project. The preferred form for modifying the kneeboard is the retained source asset together
with `scripts/build-kneeboard.mjs`; release tags preserve the exact sources corresponding to
distributed PNG pages.
