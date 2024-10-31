# LeakGuard

LeakGuard is a Flutter-based mobile application that serves as an interface for a hydraulic installation control system. The app communicates with Central Units equipped with flow meters and shut-off valves. These Central Units interact with Leak Probes strategically placed at potential leak points throughout the installation.

## System Overview

The system consists of three main components:
- **Mobile Application**: User interface for monitoring and controlling the system
- **Central Units**: Hardware devices with flow meters and shut-off valves
- **Leak Probes**: Sensors placed at strategic points to detect potential leaks

## Getting Started

### Prerequisites

Before running the application, make sure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [VS Code](https://code.visualstudio.com/)
- [Android Studio](https://developer.android.com/studio) (for Android emulator)
- [Git](https://git-scm.com/downloads)

### VS Code Extensions

Install the following VS Code extensions:
1. Flutter
2. Dart
3. Flutter Widget Snippets (optional but recommended)

### Setting Up the Project

1. Clone the repository:
```bash
git clone https://github.com/yourusername/leak_guard.git
```

2. Navigate to the project directory:
```bash
cd leak_guard
```

3. Install dependencies:
```bash
flutter pub get
```

### Running the Application

1. Open VS Code:
```bash
code .
```

2. Start an Android emulator through Android Studio or connect a physical device

3. Open the command palette in VS Code (Ctrl+Shift+P / Cmd+Shift+P) and select:
   - "Flutter: Select Device" to choose your emulator/device
   - "Flutter: Launch Emulator" to start an emulator

4. Run the application:
   - Press F5 or
   - Open the command palette and select "Flutter: Run" or
   - Type in terminal:
     ```bash
     flutter run
     ```