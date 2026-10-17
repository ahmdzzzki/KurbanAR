# Privacy · Prototype 0.3

KurbanAR has no accounts, analytics, advertising, backend, or tracking SDKs.

- Learning completion identifiers, the SD/SMP content preference, and earned activity badges are stored using UserDefaults on the device. Deleting the app removes this local app data, subject to normal operating-system backup and restore behavior.
- Camera permission is requested only when the user chooses camera AR. ARKit processes camera frames for the AR session. KurbanAR does not record, save, or transmit camera images.
- Camera AR stops when the studio disappears or the app leaves the active state.
- Following a reference link opens an external website governed by that site's privacy practices.

Before App Store submission, publish a stable privacy policy URL, add a support contact, and review this statement and the App Privacy answers against the final binary.


Version 0.3 does not request names, dates of birth, school names, or account information. SD/SMP is a local content preference. Narration uses AVSpeechSynthesizer and does not record microphone audio or upload story text to an app-operated service. Narration stops on leaving the story or when the app becomes inactive. The app information screen contains no clickable external reference links. The camera-denied flow can still open iOS Settings; review this and the camera permission path before any Kids Category submission.
