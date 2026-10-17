# Release preparation

The repository contains an MVP prototype. Publishing this code does not submit or release an App Store app.

## Before TestFlight

- Choose final product name and bundle identifier; set signing team.
- Review all lessons and questions with a qualified religious reviewer and animal-health professional; record review dates and approved content.
- Test AR on a physical ARKit-compatible iPhone and iPad, including camera denial, interruption, low light, resizing, rotation, and repeated placement.
- Review VoiceOver, larger Dynamic Type, contrast, touch targets, iPad rotation, and long-text wrapping.
- Refine the illustrative cattle and sheep and add more interactive teaching scenarios based on user feedback.

## Before App Store submission

- Set up App Store Connect using the owner's developer account.
- Prepare screenshots, description, support URL, stable privacy policy URL, age-rating answers, and privacy disclosures.
- Review current App Review Guidelines, including 1.1.2 on realistic depictions of animals being killed or mutilated. Educational positioning does not guarantee approval.
- Audit privacy manifest and required-reason APIs against the release binary. Current local progress storage uses UserDefaults for this app only (CA92.1).
- Test a signed Release archive and distribute through TestFlight before submission.

## Next product milestones

1. Expert-reviewed content and formative user testing.
2. Interactive AR hotspots and a preparation scenario with meaningful choices.
3. Sound design, and optional English localization.
4. Device verification, accessibility pass, and store preparation.


## Version 0.3 audience decisions before public release

- Test with children across SD and SMP levels, with guardian permission and appropriate supervision. Validate reading comprehension, terminology around death, optional skipping, and emotional comfort with an educator.
- Have the religious and animal-health content reviewed; confirm the station sequence is understood as a high-level overview, not technical training.
- Decide final App Store positioning and age ratings. Apple's Kids Category is for ages 11 and under; the proposed SD/SMP audience spans that boundary. Do not assume a category or rating has been approved.
- If pursuing the Kids Category, implement and review appropriate parental gates for protected actions, including camera permissions and the Settings link. The current AR companion acknowledgement is an explanation, not verified consent or an App Review-approved parental gate.
- Review installed Indonesian system voices, speech interruptions, VoiceOver, and large Dynamic Type on physical devices.
- Further reading: https://developer.apple.com/kids/ and https://developer.apple.com/app-store/categories/.
- Background content: https://dki.kemenag.go.id/berita/khutbah-idul-adha-ajak-umat-teladani-keteguhan-nabi-ibrahim-neNIt and https://sleman.kemenag.go.id/home/2026/05/28/asah-peduli-dan-kebersamaan-mtsn-10-sleman-gelar-latihan-kurban/.
