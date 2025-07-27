# Vehicle Gallery - Flutter Android App

A beautiful Flutter application for managing and viewing vehicle images and videos with an iOS-like interface design. The app provides comprehensive vehicle management features with a modern, intuitive user experience.

## Features

### 🚗 Vehicle Management
- **Complete CRUD Operations**: Create, read, update, and delete vehicles
- **Comprehensive Vehicle Data**: Make, model, year, license plate, VIN, mileage, price, and status
- **Status Tracking**: Available, In Use, Maintenance, Sold

### 📱 iOS-like Interface
- **Cupertino Design Language**: Native iOS-style components and animations
- **Smooth Animations**: Fluid transitions and interactions
- **Material Design 3**: Modern Android design with iOS aesthetics
- **Dark/Light Theme Support**: Automatic system theme detection

### 🖼️ Advanced Media Gallery
- **Multi-Media Support**: Images (JPEG, PNG, GIF) and videos (MP4, WebM)
- **Full-Screen Viewer**: Zoom, pan, and navigate through media
- **Thumbnail Grid**: Masonry layout for optimal space usage
- **Video Playback**: Integrated video player with controls

### 🔍 Smart Search & Filtering
- **Real-time Search**: Instant results as you type
- **Advanced Filters**: Filter by make, year, and status
- **Status Tabs**: Quick access to different vehicle categories
- **Clear Filters**: Easy reset functionality

### 💾 Offline Storage
- **SQLite Database**: Fast, reliable local storage
- **Sample Data**: Pre-loaded with example vehicles
- **Data Persistence**: Maintains data between app sessions

## Screenshots

| Home Screen | Vehicle Detail | Media Gallery | Add Vehicle |
|-------------|----------------|---------------|-------------|
| Grid view with search | Full vehicle info | Zoom & navigate | Form with media upload |

## Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.16+ with Dart
- **State Management**: setState with StatefulWidgets
- **Database**: SQLite with sqflite package
- **Media Handling**: image_picker, file_picker, video_player
- **UI Components**: Custom widgets with Cupertino styling

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  photo_view: ^0.14.0          # Image zoom and gallery
  video_player: ^2.8.1         # Video playback
  flutter_staggered_grid_view: ^0.7.0  # Masonry grid layout
  cached_network_image: ^3.3.0  # Image caching
  sqflite: ^2.3.0             # SQLite database
  image_picker: ^1.0.4        # Camera/gallery access
  file_picker: ^6.1.1         # File selection
  share_plus: ^7.2.1          # Share functionality
```

## Installation

### Prerequisites
- Flutter SDK 3.16.0 or higher
- Android Studio / VS Code
- Android device or emulator (API level 21+)

### Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/vehicle-gallery.git
   cd vehicle-gallery
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons** (optional)
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building APK
```bash
# Debug APK
flutter build apk --debug

# Release APK (split by architecture)
flutter build apk --release --split-per-abi

# App Bundle for Google Play
flutter build appbundle --release
```

## GitHub Actions CI/CD

The project includes automated APK building using GitHub Actions:

### Workflow Features
- **Automatic Builds**: Triggers on push to main/master branches
- **Multi-Architecture APKs**: Separate APKs for arm64-v8a, armeabi-v7a, x86_64
- **App Bundle Generation**: For Google Play Store distribution
- **Artifact Upload**: Download built APKs from Actions tab
- **Release Creation**: Automatic GitHub releases with APK attachments

### Setup GitHub Actions
1. Push code to GitHub repository
2. GitHub Actions will automatically run on push
3. Download APKs from Actions artifacts or Releases section

### Manual Trigger
You can manually trigger the build workflow from the Actions tab in your GitHub repository.

## Database Schema

```sql
CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  license_plate TEXT NOT NULL UNIQUE,
  vin TEXT,
  mileage INTEGER,
  price REAL,
  status TEXT NOT NULL DEFAULT 'available',
  media_files TEXT,  -- Comma-separated file paths
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── vehicle.dart         # Vehicle data model
├── services/
│   └── database_service.dart # SQLite operations
├── screens/
│   ├── home_screen.dart     # Main vehicle grid
│   ├── vehicle_detail_screen.dart # Vehicle details & media
│   ├── add_vehicle_screen.dart    # Add new vehicle
│   └── edit_vehicle_screen.dart   # Edit existing vehicle
├── widgets/
│   ├── vehicle_grid.dart    # Vehicle card grid
│   └── search_bar_widget.dart # Search & filter UI
└── utils/
    └── theme.dart           # iOS-like theme configuration

android/                     # Android-specific configuration
├── app/
│   ├── build.gradle        # Build configuration
│   └── src/main/
│       ├── AndroidManifest.xml # Permissions & app config
│       └── kotlin/         # MainActivity
└── gradle/                 # Gradle wrapper

.github/workflows/
└── build-apk.yml          # GitHub Actions CI/CD
```

## Permissions

The app requires the following Android permissions:
- `INTERNET` - For loading network images
- `READ_EXTERNAL_STORAGE` - For accessing device media
- `WRITE_EXTERNAL_STORAGE` - For saving media files
- `CAMERA` - For taking photos
- `READ_MEDIA_IMAGES` - Android 13+ media access
- `READ_MEDIA_VIDEO` - Android 13+ video access

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- [ ] Cloud storage integration (Firebase, AWS S3)
- [ ] Real-time sync across devices
- [ ] Advanced search with full-text indexing
- [ ] Export/Import functionality
- [ ] Barcode/QR code scanning for VIN
- [ ] Maintenance tracking and reminders
- [ ] Multi-language support
- [ ] Google Maps integration for location tracking

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@vehiclegallery.com or open an issue on GitHub.

---

**Vehicle Gallery** - Professional vehicle management with beautiful media galleries 🚗📱