# Release preparation

Kurbanin 0.5 is a general-audience portfolio prototype. Publishing its source does not submit an App Store app.

## Submission status · 18 October 2026

The owner explicitly authorized App Store upload, publication of the Data Not Collected privacy response, submission for App Review, and automatic release after approval.

Version **0.5.0 (5)** was uploaded and processed, attached to the listing, and submitted. App Store Connect shows **Waiting for Review**. This does not mean Apple has approved or publicly released the app. The configured price is free. Distribution targets iPhone and iPad; untested compatibility distribution on Apple silicon Macs and Vision Pro is disabled.

The earlier owner-review hold has been satisfied and superseded. See [submission record](app-store/SUBMISSION.md).

Remaining product checks:

- Confirm the product name and availability; Kurbanin is the current chosen direction, not a trademark or store-name clearance.
- Have religious and animal-health reviewers validate procurement, delegation, care, processing, and distribution content.
- Verify physical AR frame delivery, surface placement, resize/rotate, reset, denial, interruption, and low-light recovery. The reported blank screen is not yet verified on hardware.
- Check iPad layouts, VoiceOver, large Dynamic Type, contrast, and Indonesian narration on devices.
- Test comprehension with general-audience users; revise steps that still require explanation.

Before App Store submission:

- Prepare a signed Release archive and TestFlight build using the owner's developer account.
- Prepare screenshots, description, support and privacy URLs, and age-rating answers for the final product.
- Review the current App Review Guidelines and privacy disclosures against the final binary. Slaughter is symbolic, with no graphic depictions or technique instruction.
- Audit privacy manifests and required-reason APIs. UserDefaults is used for this app's own local preferences (CA92.1).

Internal project and bundle identifiers remain unchanged to retain installation continuity. The 0.3 child-specific product direction has been superseded; there are no SD/SMP modes, rewards, or companion gate in 0.4.
