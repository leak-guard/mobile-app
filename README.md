# LeakGuard
LeakGuard is a Flutter-based mobile application that serves as an interface for a hydraulic installation control system. The app communicates with Central Units equipped with flow meters and shut-off valves. These Central Units interact with Leak Probes strategically placed at potential leak points throughout the installation.

## System Overview

The system consists of three main components:
- **Mobile Application**: User interface for monitoring and controlling the system
- **Central Units**: Hardware devices with flow meters and shut-off valves
- **Leak Probes**: Sensors placed at strategic points to detect potential leaks

### Technologies
The app is using these key libraries:
- `sqflite` for local storage
- `http` for REST API communication with Central Unit and AWS cloud services
- `firebase_messaging` for push notification handling
- `nsd` for local network scanning using mDNS protocol

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

## Demo Version

If you want to try out the application without actual hardware devices, you can use our mocked version:

1. Switch to the `/mocked-application` branch which contains a version using simulated data
2. Clone and run the mock API server:
```bash
git clone https://github.com/leak-guard/mock-api.git
cd mock-api
# Follow setup instructions in the mock-api repository
```

## User interface overview

Here is a quick presentation over basic flow.

### Initial Setup
When first launching the app, users need to grant permissions for:
- Location access (required for WiFi scanning)
- Internal storage access (for gallery image selection)
- Camera access (for taking photos)

![Initial Screen](/docs/images/screenshots/first_open.jpg)

Adding your first Central Unit requires:
1. Connecting to the Central Unit's "LeakGuardConfig" hotspot
2. Enabling location for WiFi name retrieval
3. Pressing "Add your first device"

![Configuration Connection](/docs/images/screenshots/central_unit_create_connect_to_LeakGuardConfig.jpg)


Central Unit configuration requires:
- Unit name
- WiFi parameters:
  - Target local network SSID
  - Network password
- Time zone
- Technical parameters:
  - Impulses per liter
  - Leak detection criteria:
    - Minimum flow level indicating leak
    - Duration of minimum flow level
  - Valve type (NO/NC)


![Default Configuration](/docs/images/screenshots/central_unit_create_default_input.jpg) ![Unit Parameters](/docs/images/screenshots/create_customization.jpg)

After successful unit addition:
1. A default group named "Default" is created
2. User is redirected to the main screen
3. App automatically scans local network for the configured unit's new IP address

![Main Screen](/docs/images/screenshots/main_screen_default.jpg)

### Main Screen Features
The main interface provides comprehensive system overview with several key functionalities:

#### Flow Management
- Water flow blocking/unblocking for group units
- Current flow display
- Daily water usage monitoring

#### Water Usage Analytics
The "Water usage" panel shows:
- Recent hours water usage graph
- Detailed analysis divided into:
  - Current hour
  - Current day
  - Recent days
  - Recent months

![Water Usage Details](/docs/images/screenshots/water_usage_details.jpg)

![Block Panel](/docs/images/screenshots/main_screen_block_panel.jpg)

#### Blocking Schedule
The "Block time" panel enables:
- Basic blocking schedule configuration
- Advanced settings with day-by-day configuration

![Block Schedule](/docs/images/screenshots/block_schedule_details.jpg) ![All Days Schedule](/docs/images/screenshots/block_schedule_details_all.jpg)

![Device Monitoring](/docs/images/screenshots/main_screen_leak_probes_and_central_unit_panels.jpg)

#### Device Monitoring
Leak Probes panel shows:
- Total number of leak modules
- Number of low battery modules
- Number of modules reporting leaks

Central Units panel displays:
- Total number of central units
- Number of units with active connection
- Number of blocked units

#### Access to other screens
Open group management screen, central unit management screen or leak probe screen via application drawer.

![Application drawer](/docs/images/screenshots/drawer.jpg)

### Group Management
The group management screen enables organizing Central Units into logical groups.

![Group Management](/docs/images/screenshots/manage_groups.jpg) ![Group Reordering](/docs/images/screenshots/groups_moving.jpg)

Features include:
- Creating new groups
- Displaying groups as tiles with basic information
- Reordering groups

![Group Creation](/docs/images/screenshots/create_group.jpg) ![Unit Selection](/docs/images/screenshots/create_group_centrals.jpg)

#### Creating a New Group
To create a group, you need to:
- Assign a unique name
- Select at least one Central Unit
- Optionally add an image and description

![Group 3 Creation](/docs/images/screenshots/create_group_3.jpg) ![Group 3 Created](/docs/images/screenshots/group_created.jpg)

#### Group Editing
The group editing screen allows:
- Editing name, description, and group image
- Modifying the set of Central Units in the group
- Deleting the group

![Group Editing](/docs/images/screenshots/edit_group.jpg) ![Group Deletion](/docs/images/screenshots/delete_group.jpg)

### Central Unit Management
The Central Unit management screen enables:
- Adding new units
- Managing existing units
- Refreshing connection status and scanning network with mDNS protocol to update IP addresses of units that received new addresses from DHCP server

![Central Unit Management](/docs/images/screenshots/manage_central_units.jpg)

#### Adding New Central Unit
You can add a Central Unit in two ways:
- Manual search by providing IP address and all required fields
- Selecting a unit from those found in the network via mDNS protocol

![Unit Search](/docs/images/screenshots/find_central_unit.jpg)

#### Central Unit Editing
The editing screen allows:
- Editing unit parameters
- Displaying detailed information like MAC address
- Enabling pairing mode
- Deleting the unit

![Unit Editing](/docs/images/screenshots/edit_central_unit.jpg) ![Unit Pairing](/docs/images/screenshots/edit_paring_and_leak_probes.jpg)

### Leak Module Management
The leak module management screen provides:
- Overview of all system modules presented as list tiles with brief information including: name, address, battery level, and signal strength
- Access to detailed information and editing of each module through tile selection

Leak modules are automatically removed when their associated Central Unit is deleted.

![Leak Module Management](/docs/images/screenshots/manage_leak_probes.jpg)


