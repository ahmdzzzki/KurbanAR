# Privacy · Prototype 0.4

Kurbanin has no accounts, advertising, analytics, backend, or tracking SDKs.

- Current stage, reviewed stages, purchase and delivery routes, selected animal, and studio preferences are stored locally using UserDefaults. Previous prototype learning preferences may remain locally but are no longer used by the journey. Deleting the app removes its local data, subject to normal operating-system backup and restore behavior.
- Camera permission is requested when camera AR is selected. ARKit processes camera frames for the session. The app does not record, save, or transmit those images.
- AR pauses on backgrounding or leaving the studio. The permission dialog's temporary inactive phase does not cancel camera startup.
- Optional narration uses AVSpeechSynthesizer. No microphone recording or app-operated speech service is used. Narration stops on leaving a stage or becoming inactive.
- Reference links open external sites governed by those sites' policies.

Before App Store submission, publish a stable privacy-policy URL and support contact, and reconcile App Privacy answers with the final binary.
