# PopoverPro - Advanced Overlay and Popover Management System

A comprehensive Flutter application demonstrating advanced overlay and popover management techniques. This project implements various popover types (tooltips, menus, modals) using Flutter's Overlay widget with custom state management, gesture handling, and animations.

## Table of Contents

- [Features](#features)
- [Demo](#demo)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
  - [Local Development](#local-development)
  - [Running on Different Platforms](#running-on-different-platforms)
  - [Docker Deployment](#docker-deployment)
- [Running Tests](#running-tests)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Building for Production](#building-for-production)
- [License](#license)

## Features

- **Tooltip Popovers**: Display contextual information with arrow pointers pointing towards trigger elements
- **Dropdown Popovers**: Scrollable lists of selectable items with hover states
- **Context Menu Popovers**: Appear at gesture location (long-press) with keyboard shortcut display
- **Modal Popovers**: Full-screen overlays with semi-transparent backdrops and close buttons
- **Nested Popovers**: Support for triggering secondary popovers from within primary popovers
- **JSON Configuration**: Dynamic popover configuration loaded from external JSON file
- **Custom Animations**: Configurable fade, slide, and scale animations with custom curves
- **Cross-Platform**: Supports Web, Android, iOS, Windows, macOS, and Linux
- **Dockerized Deployment**: Production-ready Docker setup with Nginx for web deployment

## Demo

The application showcases four types of popovers:

| Type | Trigger | Description |
|------|---------|-------------|
| Tooltip | Tap/Hover | Shows contextual help with arrow pointer |
| Dropdown | Tap | Displays scrollable selection list |
| Context Menu | Long Press | Shows options at press location |
| Modal | Tap | Full-screen overlay with backdrop |

## Project Structure

```
.
├── assets/
│   └── popover_config.json           # Popover configuration file
├── lib/
│   ├── controllers/
│   │   └── popover_controller.dart   # Popover state and lifecycle management
│   ├── state/
│   │   └── popover_state.dart        # State tracking for active popovers
│   ├── utils/
│   │   ├── gesture_handler.dart      # Gesture detection utilities
│   │   └── popover_animations.dart   # Animation curves and builders333
│   ├── widgets/
│   │   ├── tooltip_popover.dart      # Tooltip popover widget
│   │   ├── dropdown_popover.dart     # Dropdown popover widget
│   │   ├── context_menu_popover.dart # Context menu popover widget
│   │   └── modal_popover.dart        # Modal popover widget
│   └── main.dart                     # Application entry point
├── test/
│   └── popover_widget_test.dart      # Widget unit tests
├── integration_test/
│   └── popover_flow_test.dart        # Integration tests
├── Dockerfile                        # Multi-stage Docker build (Flutter + Nginx)
├── docker-compose.yml                # Docker Compose services configuration
├── nginx.conf                        # Nginx configuration for web serving
├── .dockerignore                     # Docker build exclusions
└── README.md                         # This file
```

## Requirements

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android SDK (for Android builds)
- Xcode (for iOS/macOS builds)
- Docker & Docker Compose (for containerized deployment)
- Chrome browser (for web development)

## Getting Started

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rakesh-kopisetti/Popover-Overlay.git
   cd Popover-and-Overlay-Management-System
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup**
   ```bash
   flutter doctor
   ```

### Running on Different Platforms

#### Web (Chrome)
```bash
flutter run -d chrome
```
The app will launch in Chrome browser with hot reload enabled.

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Linux
```bash
flutter run -d linux
```

#### Android
```bash
# Run on connected device or emulator
flutter run -d android

# List available devices
flutter devices
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

### Docker Deployment

The project includes a production-ready Docker setup for deploying the Flutter web application.

#### Docker Architecture

The Dockerfile uses a **multi-stage build**:
1. **Build Stage**: Uses Flutter image to compile the web application
2. **Production Stage**: Uses Nginx Alpine to serve the static files

#### Quick Start with Docker

1. **Build and run the container**
   ```bash
   docker-compose up --build
   ```

2. **Access the application**
   
   Open your browser and navigate to: **http://localhost:8080**

3. **Run in detached mode (background)**
   ```bash
   docker-compose up -d --build
   ```

4. **Stop the container**
   ```bash
   docker-compose down
   ```

#### Docker Commands Reference

| Command | Description |
|---------|-------------|
| `docker-compose up --build` | Build and start the container |
| `docker-compose up -d` | Run in background (detached) |
| `docker-compose down` | Stop and remove containers |
| `docker-compose logs -f` | View container logs |
| `docker-compose ps` | List running containers |
| `docker-compose build --no-cache` | Rebuild without cache |

#### Docker Configuration Files

- **Dockerfile**: Multi-stage build configuration
  - Stage 1: Flutter build environment
  - Stage 2: Nginx production server
  
- **docker-compose.yml**: Service definitions
  - `popover-web`: Production web server on port 8080
  - `flutter-dev`: Development environment (optional)
  
- **nginx.conf**: Web server configuration
  - SPA routing support
  - Gzip compression
  - Static asset caching
  - Security headers

#### Building Docker Image Only
```bash
docker build -t popover-pro .
```

#### Running Without Docker Compose
```bash
docker run -p 8080:80 popover-pro
```

## Running Tests

### Widget Tests
```bash
flutter test test/popover_widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/popover_flow_test.dart
```

### Run All Tests
```bash
flutter test
```

### Test with Coverage
```bash
flutter test --coverage
```

## Configuration

The application loads popover configurations from `assets/popover_config.json`. The configuration schema:

```json
{
  "popovers": [
    {
      "id": "string",
      "type": "tooltip|dropdown|context|modal",
      "position": "top|bottom|left|right|center",
      "content": "string",
      "backgroundColor": "#RRGGBB",
      "animationDuration": 200
    }
  ]
}
```

### Supported Popover Types

| Type | Description | Position Options |
|------|-------------|------------------|
| `tooltip` | Contextual help text | top, bottom, left, right |
| `dropdown` | Selection list | bottom (default) |
| `context` | Right-click style menu | At cursor position |
| `modal` | Full-screen overlay | center |

## Widget Keys for Testing

The following keys are used for identifying widgets in tests:

| Widget | Key |
|--------|-----|
| Tooltip Popover | `Key('tooltip-popover')` |
| Dropdown Popover | `Key('dropdown-popover')` |
| Context Menu Popover | `Key('context-menu-popover')` |
| Modal Popover | `Key('modal-popover')` |
| Modal Close Button | `Key('modal-close-button')` |

## Architecture

### PopoverController

The `PopoverController` class manages popover logic with the following methods:

- `show(...)` - Display a popover with configuration
- `hide()` - Hide the current or specified popover
- `toggle(...)` - Toggle popover visibility
- `isShowing()` - Check if any/specific popover is active
- `updatePosition()` - Update popover position

### PopoverState

The `PopoverState` class tracks active popover state:

- `activePopoverIds` - List of currently active popover IDs
- `popoverPositions` - Map of popover IDs to their positions

### Animations

Animation curves defined in `popover_animations.dart`:

- `fadeInCurve` - Curve for fade-in animations
- `slideInCurve` - Curve for slide-in animations
- `scaleInCurve` - Curve for scale-in animations
- `popoverAnimationDuration` - Default animation duration

## Building for Production

### Web Build
```bash
flutter build web --release
```
Output: `build/web/`

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### macOS
```bash
flutter build macos --release
```

### Docker Production Build
```bash
# Build and deploy web app with Nginx
docker-compose up --build -d

# Access at http://localhost:8080
```

## Environment Variables

For Docker deployment, you can customize the following:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 8080 | Host port for web server |

Example:
```bash
# Run on custom port
docker run -p 3000:80 popover-pro
```

## Troubleshooting

### Common Issues

1. **Flutter not found in Docker**
   ```bash
   docker-compose build --no-cache
   ```

2. **Port already in use**
   ```bash
   # Find process using port 8080
   netstat -ano | findstr :8080
   
   # Use different port
   docker run -p 3000:80 popover-pro
   ```

3. **Web build fails**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

4. **Hot reload not working on web**
   - Ensure you're using `flutter run -d chrome` (not the built version)
   - Press `r` in terminal for hot reload, `R` for hot restart

## License

This project is created for educational purposes and demonstrates Flutter overlay management techniques.

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting a pull request:

```bash
flutter test
flutter analyze
```

## Author

PopoverPro - Flutter Overlay and Popover Management System
#
