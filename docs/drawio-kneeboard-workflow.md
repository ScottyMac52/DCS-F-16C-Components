# draw.io kneeboard workflow proposal

## Summary

This document captures the proposed approach for moving the F-16C kneeboard connector layout from hand-edited SVG coordinates to a visual source workflow based on draw.io.

## Goals

- Allow connector labels and callouts to be adjusted visually.
- Keep the current build pipeline and deterministic output behavior intact.
- Make future maintenance easier for contributors.

## Proposed implementation stages

1. Define the source-of-truth diagram format for the kneeboard pages that need connector placement.
2. Add a build step that converts the source diagrams into the generated SVG/PNG outputs used by the package.
3. Preserve the current validation and packaging contract so the repository build remains stable.
4. Document the contributor workflow for editing and rebuilding the assets.

## Acceptance criteria

- Diagram source files exist for the kneeboard pages that need visual connector placement.
- The existing build and validation scripts still run successfully.
- Documentation explains how to edit the diagrams and regenerate the outputs.

## Definition of done

- The diagram source files are checked into the repository.
- The build script can regenerate the shipped outputs from those sources.
- The validation suite passes without regressions.
- A maintainer can edit the diagram layout without hand-editing generated SVG coordinates.
