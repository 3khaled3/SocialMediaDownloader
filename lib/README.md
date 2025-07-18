# Instagram Reels Downloader - Project Structure

This Flutter project has been refactored to follow a clean architecture pattern with better separation of concerns.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
│   └── download_screen.dart  # Main download screen
├── services/                 # Business logic services
│   ├── instagram_service.dart    # Instagram API integration
│   ├── download_service.dart     # File download handling
│   └── permission_service.dart   # Permission management
├── models/                   # Data models
│   └── media_info.dart       # Media information model
├── widgets/                  # Reusable UI components
│   └── custom_button.dart    # Custom button widget
└── utils/                    # Utility classes and constants
    └── constants.dart        # App-wide constants
```

## Key Improvements

### 1. **Separation of Concerns**
- **Services**: Handle business logic and external API calls
- **Screens**: Focus only on UI and user interactions
- **Models**: Define data structures
- **Widgets**: Reusable UI components
- **Utils**: Constants and helper functions

### 2. **Service Layer**
- `InstagramService`: Handles all Instagram API interactions
- `DownloadService`: Manages file downloads and storage
- `PermissionService`: Handles permission requests

### 3. **Constants Management**
- All hardcoded strings and values moved to `AppConstants`
- Easy to maintain and update

### 4. **Custom Widgets**
- `CustomButton`: Reusable button component with loading states
- Consistent styling across the app

## Usage

1. **Install Dependencies**: Run `flutter pub get` to install all required packages
2. **Run the App**: Use `flutter run` to start the application
3. **Enter Instagram URL**: Paste an Instagram post/reel URL
4. **Fetch Media**: Click "Fetch Media URL" to get download link
5. **Download**: Click "Download Media" to save the file

## Dependencies

- `flutter`: Core Flutter framework
- `dio`: HTTP client for downloads
- `http`: HTTP requests for API calls
- `path_provider`: File system access
- `permission_handler`: Permission management

## API Configuration

The app uses RapidAPI for Instagram media extraction. Update the API key in `lib/utils/constants.dart` if needed.

## File Storage

- **Android**: Files are saved to `/storage/emulated/0/Download/`
- **iOS**: Files are saved to the app's documents directory

## Permissions

The app requests storage permissions to save downloaded files. Make sure to grant the necessary permissions when prompted.
