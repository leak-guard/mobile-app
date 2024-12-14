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

<img src="/docs/images/screenshots/first_open.jpg" width="300"/>

Adding your first Central Unit requires:
1. Connecting to the Central Unit's "LeakGuardConfig" hotspot
2. Enabling location for WiFi name retrieval
3. Pressing "Add your first device"


<img src="/docs/images/screenshots/central_unit_create_connect_to_LeakGuardConfig.jpg" width="300"/>


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

<p float="left">
  <img src="/docs/images/screenshots/central_unit_create_default_input.jpg" width="300"/>
  <img src="/docs/images/screenshots/create_customization.jpg" width="300"/>
</p>

After successful unit addition:
1. A default group named "Default" is created
2. User is redirected to the main screen
3. App automatically scans local network for the configured unit's new IP address

<img src="/docs/images/screenshots/main_screen_default.jpg" width="300"/>

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


<img src="/docs/images/screenshots/water_usage_details.jpg" width="300"/>
<img src="/docs/images/screenshots/main_screen_block_panel.jpg" width="300"/>

#### Blocking Schedule
The "Block time" panel enables:
- Basic blocking schedule configuration
- Advanced settings with day-by-day configuration

<p float="left">
  <img src="/docs/images/screenshots/block_schedule_details.jpg" width="300"/>
  <img src="/docs/images/screenshots/block_schedule_details_all.jpg" width="300"/>
</p>

<img src="/docs/images/screenshots/main_screen_leak_probes_and_central_unit_panels.jpg" width="300"/>


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

<img src="/docs/images/screenshots/drawer.jpg" width="300"/>

### Group Management
The group management screen enables organizing Central Units into logical groups.

<p float="left">
  <img src="/docs/images/screenshots/manage_groups.jpg" width="300"/>
  <img src="/docs/images/screenshots/groups_moving.jpg" width="300"/>
</p>

Features include:
- Creating new groups
- Displaying groups as tiles with basic information
- Reordering groups

<p float="left">
  <img src="/docs/images/screenshots/create_group.jpg" width="300"/>
  <img src="/docs/images/screenshots/create_group_centrals.jpg" width="300"/>
</p>

#### Creating a New Group
To create a group, you need to:
- Assign a unique name
- Select at least one Central Unit
- Optionally add an image and description

<p float="left">
  <img src="/docs/images/screenshots/create_group_3.jpg" width="300"/>
  <img src="/docs/images/screenshots/group_created.jpg" width="300"/>
</p>

#### Group Editing
The group editing screen allows:
- Editing name, description, and group image
- Modifying the set of Central Units in the group
- Deleting the group

<p float="left">
  <img src="/docs/images/screenshots/edit_group.jpg" width="300"/>
  <img src="/docs/images/screenshots/delete_group.jpg" width="300"/>
</p>

### Central Unit Management
The Central Unit management screen enables:
- Adding new units
- Managing existing units
- Refreshing connection status and scanning network with mDNS protocol to update IP addresses of units that received new addresses from DHCP server

<img src="/docs/images/screenshots/manage_central_units.jpg" width="300"/>

#### Adding New Central Unit
You can add a Central Unit in two ways:
- Manual search by providing IP address and all required fields
- Selecting a unit from those found in the network via mDNS protocol

<img src="/docs/images/screenshots/find_central_unit.jpg" width="300"/>

#### Central Unit Editing
The editing screen allows:
- Editing unit parameters
- Displaying detailed information like MAC address
- Enabling pairing mode
- Deleting the unit

<p float="left">
  <img src="/docs/images/screenshots/edit_central_unit.jpg" width="300"/>
  <img src="/docs/images/screenshots/edit_paring_and_leak_probes.jpg" width="300"/>
</p>

### Leak Module Management
The leak module management screen provides:
- Overview of all system modules presented as list tiles with brief information including: name, address, battery level, and signal strength
- Access to detailed information and editing of each module through tile selection

Leak modules are automatically removed when their associated Central Unit is deleted.

<img src="/docs/images/screenshots/manage_leak_probes.jpg" width="300"/>