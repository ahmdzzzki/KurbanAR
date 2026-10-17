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
