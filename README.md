<!--

This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2025 Stanford University

SPDX-License-Identifier: MIT

-->

# Stanford 360

[![Beta Deployment](https://github.com/CS342/2025-Stanford-360/actions/workflows/beta-deployment.yml/badge.svg)](https://github.com/CS342/2025-Stanford-360/actions/workflows/beta-deployment.yml)
[![codecov](https://codecov.io/gh/CS342/2025-Stanford-360/graph/badge.svg?token=N9i5EIPEgj)](https://codecov.io/gh/CS342/2025-Stanford-360)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14740611.svg)](https://doi.org/10.5281/zenodo.14740611)


This repository contains the Stanford 360 application. 

Stanford 360 is an app that helps children undergoing bariatric surgery follow the 60/60/60 rule to adopt new lifestyle habits. It helps the patients keep track of their physical activity, protein and hydration intake. It is gamified, helps children keep track of their streaks and look at weekly and monthly overviews. It also provides recommendations for activities and meals.

Stanford 360 is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication).

<!-- 
 -->

## Overview

The application has 4 main views: a dashboard, activity tracking, hydration tracking, and meals tracking. It is fully integrated with Firebase and connected to HealthKit. It also sends reminders and notifications.

> [!TIP]
> Want to test Stanford 360 on your device? [Download it on TestFlight](https://testflight.apple.com/join/s8p84whp).

## Modules Documentation

<details open>
<summary><b>Activity Module</b></summary>

The Activity module in Stanford 360 provides comprehensive physical activity tracking with HealthKit integration. Here is how it works:
1. First tab: Activity Logging:
    (a) The app first shows a ring with their current progress for the day. The goal is to reach 60 minutes of activity.
    (b) It enables the user to input activities: Walking, Running, Dancing, Sports, PE, other. Then, the user needs to select a date and a number of active minutes. Then, the activity gets saved into the history and get stored on Firestore, HealthKit, and locally. 
    (c) The app also uses HealthKit step counter to update the activity on the app, converting steps into active minutes.
    (d) The app ensures that the date is in the past.
    (e) Every 20min of activity, the user gets a motivation message.
    (f) Once the user reaches 60 min, a congratulatory message appears.
    (g) The user receives a notification in the morning at 7am and in the afternoon (after class) at 5pm that reflects their progress and motivated them.
    (h) If the user's app is not connected to HealthKit, we show a warning message to let them know that no activity from HealthKit will be imported.
    (i) Whenever the user reached 60min, their streak is updated on the dashboard. The streak reflects the number of consecutive days they reached their goal of 60 min of activity, starting today and going backwards.
2. History:
    (a) Here, we keep track of the history of logged activity, from latest to oldest. We show the activity type and number of minutes. We categorize them per date.
    (b) We enable editing and deleting of activities with swiping right and left, respectively. 
    (c) If the activity is deleted, it gets deleted from Firestore.
    (d) If the activity gets edited, an "editing" sheet pops up to edit the activity.
3. Recommendation:
    (a) We provide a table with activity recommendations and a link to Youtube videos for other activities ideas.

<!-- ![Activity Module Screenshot](https://raw.githubusercontent.com/CS342/2025-Stanford-360/main/Documentation/Images/ActivityModule.png#gh-light-mode-only)
![Activity Module Screenshot](https://raw.githubusercontent.com/CS342/2025-Stanford-360/main/Documentation/Images/ActivityModule~dark.png#gh-dark-mode-only) -->

<details>
<summary>Technical Notes</summary>

- Uses Swift concurrency (async/await) for asynchronous operations
- HealthKit integration is optional; the app functions fully without it
- Activities use a consistent formula of 100 steps per minute for estimation
- User-facing dates use relative formatting for improved readability
- Uses environment objects for dependency injection

</details>

</details>

<details>
<summary><b>Hydration Module</b></summary>

> [!NOTE]
> Documentation for the Hydration module is under development and will be added in a future update.

</details>

<details>
<summary><b>Protein Module</b></summary>

> [!NOTE]
> Documentation for the Protein module is under development and will be added in a future update.

</details>

<details>
<summary><b>Dashboard</b></summary>

> [!NOTE]
> Documentation for the Dashboard module is under development and will be added in a future update.

</details>

<details>
<summary><b>Profile Management</b></summary>

> [!NOTE]
> Documentation for the Profile Management module is under development and will be added in a future update.

</details>

## Common Components

<details>
<summary><b>UI Components</b></summary>

> [!NOTE]
> Documentation for UI Components is under development and will be added in a future update.

</details>

<details>
<summary><b>Notification System</b></summary>

> [!NOTE]
> Documentation for the Notification System is under development and will be added in a future update.

</details>

<details>
<summary><b>HealthKit Integration</b></summary>

> [!NOTE]
> Documentation for HealthKit Integration is under development and will be added in a future update.

</details>

<details>
<summary><b>Firebase Integration</b></summary>

> [!NOTE]
> Documentation for Firebase Integration is under development and will be added in a future update.

</details>

## Getting Started

<details>
<summary>Installation and Setup</summary>

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- macOS 14.0 or later (for development)
- [CocoaPods](https://cocoapods.org/) for dependency management

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/CS342/2025-Stanford-360.git
   cd 2025-Stanford-360
   ```

2. Install dependencies:
   ```bash
   pod install
   ```

3. Open the workspace:
   ```bash
   open Stanford360.xcworkspace
   ```

4. Configure Firebase:
   - Add your `GoogleService-Info.plist` to the project
   - Update Firebase configuration in `Stanford360App.swift`

5. Build and run the application in Xcode

</details>

## Contributing

We collaborated equitably throughout the 10 weeks, working closely together and supporting each other on our respective tasks. While each team member had their own responsibilities, most features resulted from our collective efforts, making it challenging to attribute any specific feature to a single individual. However, here is the breakdown of each of our tasks and responsibilities:

Elsa worked on the Activity module. She worked on connecting the app to HealthKit and Firestore. She also worked on weekly and monthly charts that were later integrated into the dashboard. She also wrote the onboarding page.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
