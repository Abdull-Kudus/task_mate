# Task Mate

Task Mate is a lightweight, offline-first Flutter task management application built to help teams organize, prioritize, and track their workflows efficiently. It features a robust Service-Level Agreement (SLA) tracking system and a beautiful, modern UI.

## Key Features

*   **SLA Tracking System:** Automatically calculates whether a task is *On Track*, *At Risk*, or *Overdue* based on its deadline and assigned priority level.
*   **Offline Data Persistence:** Built using `SharedPreferences` to instantly save all tasks and team member data locally on your device without needing a backend.
*   **Team Management:** Easily add and manage team members. 
*   **Dynamic Avatars:** Integrates with the DiceBear API to automatically generate unique, fun character avatars for every team member based on their name.
*   **Search & Filtering:** Quickly search through your tasks and filter them by their SLA status.
*   **Dashboard & Statistics:** Real-time metrics that automatically aggregate your task data so you know exactly where your project stands.
*   **Premium Custom UI:** 
    *   Clean, flat design aesthetic (no bulky default shadows).
    *   Custom premium typography using the **Mona Sans** font family.
    *   Professional icon suite using **Phosphor Icons**.

## Tech Stack
*   **Framework:** Flutter / Dart
*   **Local Storage:** SharedPreferences
*   **Assets:** Mona Sans (Local Font), Phosphor Icons Flutter, DiceBear API (Network Images)

## Getting Started

### Prerequisites
Make sure you have Flutter installed on your machine. You can verify your installation by running:
```bash
flutter doctor
```

### Installation
1. **Clone the repository:**
```bash
git clone https://github.com/Abdull-Kudus/task-mate.git
```

2. **Navigate into the directory:**
```bash
cd task-mate
```

3. **Install dependencies (and link fonts):**
```bash
flutter pub get
```

4. **Run the app:**
```bash
flutter run
```
*(Note: To see the dynamic DiceBear avatars, ensure your emulator or physical device is connected to the internet).*

## Contributors
*   **Abdul-Kudus** - Lead Developer & Project Manager
*   **Nkingi** - Developer
*   **Methode** - Developer
*   **Chris** - Developer
