# Verification · Kurbanin 0.4 · 17 October 2026

## Automated checks

- Seven Swift Testing domain tests pass: distribution conserves integer grams, invalid inputs are rejected, animal catalog content is complete, camera permission activation survives temporary inactivity, the ten-stage journey follows procurement through distribution, progress ignores unknown and repeated IDs, and the buyer changes with the procurement route.
- Three XCUITest scenarios pass on iPhone 17 Pro / iOS 26.5 simulator: direct/delegated purchase and animal choice persist across relaunch; all ten stages lead to the summary and delivery can switch to collection; map jumps, optional detail, calculator, and both studio animal choices remain accessible.
- Simulator Debug build and signed physical-device Release build succeed with Xcode 27.0, targeting iOS 18+.
- Final journey, inspection, distribution, and summary screenshots inspected for layout and readability. The primary next action stays above the tab bar.
- Project property-list validation passes. Pre-existing local signing/project edits are retained locally and excluded from the commit.
- Signed 0.4 Release installed on the connected iPhone 13. Its camera was not launched.

## Physical-device checks still open

The user chose to continue without testing the physical camera. No successful camera frame delivery or surface placement is claimed; the previously reported blank-camera issue remains unverified on hardware.

Verify camera permission/denial, live frames, surface detection, animal placement, resize/rotation, reset, session interruption, backgrounding, and low-light recovery. Check iPad, VoiceOver, large Dynamic Type, and installed Indonesian narration voices. Religious and animal-health review remains pending.

## Earlier iterations

0.2 introduced the cattle/ram USDZ studio and camera startup recovery. Original model renders and visible simulator geometry for both animals were checked. 0.3 explored a child-focused learning path; its missions, age modes, rewards, and games have been superseded by 0.4's general-audience journey. Neither earlier iteration established physical camera success.
