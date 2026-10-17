# Release preparation

The repository contains an MVP prototype. Publishing this code does not submit or release an App Store app.

## Before TestFlight

- Choose final product name and bundle identifier; set signing team.
- Review all lessons and questions with a qualified religious reviewer and animal-health professional; record review dates and approved content.
- Test AR on a physical ARKit-compatible iPhone and iPad, including camera denial, interruption, low light, resizing, rotation, and repeated placement.
- Review VoiceOver, larger Dynamic Type, contrast, touch targets, iPad rotation, and long-text wrapping.
- Refine the illustrative sheep and add more interactive teaching scenarios based on user feedback.

## Before App Store submission

- Set up App Store Connect using the owner's developer account.
- Prepare screenshots, description, support URL, stable privacy policy URL, age-rating answers, and privacy disclosures.
- Review current App Review Guidelines, including 1.1.2 on realistic depictions of animals being killed or mutilated. Educational positioning does not guarantee approval.
- Audit privacy manifest and required-reason APIs against the release binary. Current local progress storage uses UserDefaults for this app only (CA92.1).
- Test a signed Release archive and distribute through TestFlight before submission.

## Next product milestones

1. Expert-reviewed content and formative user testing.
2. Interactive AR hotspots and a preparation scenario with meaningful choices.
3. Improved 3D assets, sound design, and optional English localization.
4. Device verification, accessibility pass, and store preparation.
