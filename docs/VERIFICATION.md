# Verification

Automated domain tests verify integer-gram distribution invariants, input bounds, and correct-answer-only learning persistence. Simulator build and manual smoke results are recorded below during initial setup.

## Initial verification · 17 October 2026

- Xcode 27.0 simulator build: passed for arm64 and x86_64.
- Swift Testing: 3 domain tests passed.
- XCUITest: 2 UI tests passed on iPhone 17 Pro, iOS 26.5 simulator.
- UI coverage: navigate to a lesson, answer correctly, persist completion across relaunch, open the 3D studio, and validate default distribution output (25 kg / 20 = 1,250 g, zero remainder).
- Home and distribution screenshots inspected. Numeric UI assertions accommodate localized thousands separators.
- Project and privacy manifest validated with `plutil`.
- Physical camera AR has not been tested. iPad and accessibility device testing are still pending.

## Physical-device checks still required

- Grant camera permission, detect a horizontal plane, and place a single sheep.
- Rotate and resize, then reset and place again. Ensure only one sheep remains.
- Deny permission: keep preview accessible and offer Settings.
- Background the app or switch tabs: ensure the AR session stops.
- Interrupt the session: confirm useful feedback and recovery through preview.
- Check low-light and feature-poor surfaces without a successful raycast.
- Validate VoiceOver and large text on both iPhone and iPad.


## Version 0.2 verification · 17 October 2026

- Five Swift Testing domain tests passed, including catalog integrity and camera activation eligibility during the permission-dialog lifecycle.
- Two final XCUITests passed. Screenshot checks confirmed visible foreground geometry for both animal models. UI coverage includes both animal choices, an observation card, simulator camera guidance, learning persistence, and distribution arithmetic.
- The original Blender renders and in-app home/studio screenshots were inspected. Source geometry is included and does not require a third-party model license.
- iOS simulator and signed iPhone 13 builds succeeded. Deployment target is now iOS 18 for native RealityKit geometry and asynchronous entity loading.
- Camera startup now explicitly uses the live feed and waits for a mounted view; errors, surface discovery, and no-frame timeout are surfaced in the UI.
- The signed prototype was installed on the connected iPhone 13. A physical-camera launch was initially blocked by the locked device; the user then chose to continue without physical-camera testing. No successful frame delivery or placement is claimed.
- Remaining checks: physical AR frames, plane placement, gestures, camera denial/interruption, iPad, and large Dynamic Type.


## Version 0.3 · SD/SMP learning adventure

- Nine domain tests pass: existing distribution/camera checks plus catalog consistency, legacy progress migration, unique star counts, process ordering (invalid/duplicate/wrong/partial/correct), and package conservation/equality in both SD and SMP modes.
- Simulator build succeeded with the six-mission learning path, system speech synthesis UI, optional process explanation, station-order game, sharing game, companion guide, and five-tab navigation.
- Four simulator UI scenarios passed. The story, ordering, and sharing scenarios passed again after adding automatic feedback scrolling. Final screenshots were inspected. UI scenarios cover story paging and completion across relaunch, skipping the optional slaughter explanation before earning the ordering badge, fair package delivery, switching to SMP, studio rendering, and the optional gram calculator.
- The signed 0.3 app was installed on the connected iPhone 13 without launching its camera. No physical-camera testing was performed. The outstanding physical AR checks from 0.2 remain open.
- Remaining manual work: installed Indonesian speech voice and interruptions on devices, VoiceOver/large text and iPad layouts, educator and religious/animal-health content review, and supervised child usability testing.
