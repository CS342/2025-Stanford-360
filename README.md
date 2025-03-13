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
Stanford 360 is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication).

> [!TIP]
> Do you want to test the Stanford 360 application on your device? [You can downloard it on TestFlight](https://testflight.apple.com/join/s8p84whp).

## Overview
This app is designed to support pediatric patients undergoing metabolic and bariatric surgery by promoting long-term lifestyle changes through the 60-60-60 rule (60 oz of water, 60 g of protein, and 60 minutes of physical activity daily). The app enables physical activity tracking, hydration and protein intake logging, and data visualization, with motivational feedback and reminders to encourage adherence. Unlike traditional weight-loss apps, this tool focuses on behavioral reinforcement rather than weight tracking, using [FHIR-based](https://github.com/StanfordSpezi/SpeziFHIR) cloud storage ([Firebase](https://github.com/StanfordSpezi/SpeziFirebase)) and integrating [SpeziHealthKit](https://github.com/StanfordSpezi/SpeziHealthKit) for automated data collection. The goal is to improve compliance, enhance patient outcomes, and provide healthcare providers with insightful visualized data.

## Stanford 360 Features

*Provide a comprehensive description of your application, including figures showing the application. You can learn more on how to structure a README in the [Stanford Spezi Documentation Guide](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/documentation-guide)*

The App consists of four main screens.

### Dashboard

### Activity
The Activity module in Stanford 360 features a progress ring that tracks daily physical activity, aiming for 60 minutes. Users can log activities like Walking, Running, and Sports by selecting a date and entering active minutes. Logged activities sync with Firestore, HealthKit, and local storage. HealthKit integration converts steps into active minutes (100 steps/min), with a warning if disconnected.

### Hydration
The central focus is a progress ring that visually represents the user's current water intake. Below, users can quickly log their hydration using preset portion buttons, each featuring clear icons for different drink sizes. A "Log Water Intake" button ensures seamless entry, while a reset button allows users to easily correct accidental logs. Any additions or deletions will be saved to or removed from Firestore, ensuring that hydration data is securely stored and synchronized across devices. Changes will also automatically update the corresponding card in the History View, maintaining real-time accuracy in tracking.

<img src="https://github.com/user-attachments/assets/386052d2-c30d-4c04-a642-8c8dd73ffb24#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/991e1ca4-d702-482f-bf7b-53737a38e857#gh-dark-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/d5f7f580-c4aa-4859-ae89-3756ee9c8799#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/2d1bc9ea-1b64-4107-a858-d22f55784fde#gh-dark-mode-only" width="25%">

### Protein
The protein module designed to help users monitor their daily protein intake through interactive charts, milestone feedback, and AI-powered meal recognition. The app provides a visual representation of daily protein intake, displaying it through a chart and sending milestone notifications every time the intake reaches 20 grams, offering positive reinforcement to encourage healthy eating habits. Users can log their meals using two entry methods: manual entry, where they input food items and specify protein content, and picture-based entry, where they upload meal images. The backend processes these images by concurrently sending requests to two models to identify the meal name, while SpeziLLM analyzes the meal’s protein content and automatically fills in the intake data. Additionally, the app enables users to store and retrieve meal images and intake records, allowing them to track their nutrition history in detail. Future enhancements include integrating additional food databases for improved accuracy and providing personalized nutrition insights based on dietary patterns.


In addition to the specific features of each screen, we also provide essential functionalities that enhance the overall app experience and ensure seamless integration across all features.

### History
The History feature allows users to track their complete past records for Protein, Activity, and Hydration, displayed in a card view organized by date. Users can access History separately from each view screen (Protein, Activity, and Hydration) via the top tab bar.

### Discover
The Discover feature provides suggestions and educational insights for Protein, Activity, and Hydration, helping users make informed choices and build healthier habits.

<img src="https://github.com/user-attachments/assets/878d0105-7219-4129-8392-a4e94034780a#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/70d4ddb9-caf7-4b0c-be64-f6d4c721b55e#gh-dark-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/0fcefe4a-0af9-4d3f-b8aa-dffa73aefc89#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/119fc31b-780c-4529-8b7c-79f4a0a95b7d#gh-dark-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/881d95ef-0e9b-4dc9-b385-9c850dfbac1d#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/79bc6d15-ffb4-4671-913d-0d176dcb428e#gh-dark-mode-only" width="25%">


### Milestone/Goal
The Milestone/Goal feature provides real-time progress updates and encouragement across the Protein, Activity, and Hydration views.
#### Goal Tracking
A goal check text is displayed in the center of each view. Before reaching 60, it will show the remaining amount needed to reach the 60-unit goal. Upon reaching 60, the text updates to display a congratulatory message.
#### Milestone Tracking
Every 20-unit increment triggers a milestone message to encourage progress. Upon reaching 60 units, a special milestone message appears, celebrating the achievement along with the current streak day.

<img src="https://github.com/user-attachments/assets/fba07491-de2f-4417-8944-1c3d4f91bc92#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/17d529d2-be3f-4d0e-a045-4d37b2d96be6#gh-dark-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/3cbe03ce-9485-4e91-8aaa-a26297ee33d2#gh-light-mode-only" width="25%">
<img src="https://github.com/user-attachments/assets/3a9962df-ebe9-40a8-9cf7-99717e870e9d#gh-dark-mode-only" width="25%">

### Notification

> [!NOTE]  
> Do you want to learn more about the Stanford Spezi Template Application and how to use, extend, and modify this application? Check out the [Stanford Spezi Template Application documentation](https://stanfordspezi.github.io/SpeziTemplateApplication)

## Setup instructions

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
