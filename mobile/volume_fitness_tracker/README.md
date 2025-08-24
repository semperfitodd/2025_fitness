# Fitness Tracker iOS App

A modern, well-architected iOS fitness tracking application built with SwiftUI and following MVVM design patterns.

## 🏗️ Architecture

### MVVM (Model-View-ViewModel)
- **Models**: Data structures with Codable conformance and validation
- **Views**: SwiftUI views focused purely on UI presentation
- **ViewModels**: Business logic and state management using `@ObservableObject`

### Key Components

#### 📱 Views
- `HomeScreen`: Displays fitness progress and charts
- `InsertScreen`: Add workout exercises and track volume
- `GenerateWorkoutScreen`: AI-powered workout plan generation
- `SettingsScreen`: App settings and sign out functionality

#### 🧠 ViewModels
- `HomeViewModel`: Manages fitness data fetching and progress calculations
- `InsertViewModel`: Handles workout submission and validation
- `GenerateWorkoutViewModel`: Manages AI workout generation

#### 🌐 Networking
- `APIClient`: Protocol-based networking layer with async/await
- `MockAPIClient`: For testing and development
- Proper error handling and response parsing

#### 📊 Models
- `Exercise`: Core workout data model with validation
- `FitnessDataResponse`: API response models
- `WorkoutSubmission`: Structured workout submission data

## 🚀 Features

### Core Functionality
- ✅ **Google Sign-In Authentication**
- ✅ **Workout Tracking**: Add exercises with weight, reps, and volume calculation
- ✅ **Progress Visualization**: Charts showing exercise breakdown and yearly progress
- ✅ **AI Workout Generation**: Get personalized workout plans
- ✅ **Data Persistence**: All data stored securely in AWS backend
- ✅ **Independent Watch App**: Apple Watch app with its own API integration

### User Experience
- ✅ **Modern UI**: Clean, intuitive interface following iOS design guidelines
- ✅ **Loading States**: Proper loading indicators and error handling
- ✅ **Form Validation**: Real-time validation with helpful error messages
- ✅ **Pull-to-Refresh**: Refresh data on home screen
- ✅ **Responsive Design**: Works on all iPhone sizes

### Technical Excellence
- ✅ **MVVM Architecture**: Clean separation of concerns
- ✅ **Async/Await**: Modern concurrency patterns
- ✅ **Error Handling**: Comprehensive error management
- ✅ **Logging**: Structured logging with OSLog
- ✅ **Testing**: Mock clients for unit testing
- ✅ **Accessibility**: VoiceOver support and accessibility labels

## 🛠️ Development

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- CocoaPods (for DGCharts dependency)

### Setup
1. Clone the repository
2. Install dependencies: `pod install`
3. Open `volume_fitness_tracker.xcworkspace`
4. Configure Firebase and API credentials in `Secrets.plist`
5. Build and run

### Project Structure
```
volume_fitness_tracker/
├── Models.swift                 # Data models and validation
├── APIClient.swift             # Networking layer
├── FitnessApp.swift            # App entry point
├── ContentView.swift           # Main tab navigation
├── ViewModels/                 # MVVM ViewModels
│   ├── HomeViewModel.swift
│   ├── InsertViewModel.swift
│   └── GenerateWorkoutViewModel.swift
├── Components/                 # Reusable UI components
│   ├── LoadingView.swift
│   └── ErrorView.swift
├── Utils/                      # Utilities
│   └── Logger.swift
├── Screens/                    # Main app screens
│   ├── HomeScreen.swift
│   ├── InsertScreen.swift
│   ├── GenerateWorkoutScreen.swift
│   ├── LoginScreen.swift
│   └── SettingsScreen.swift
└── Charts/                     # Chart components
    ├── BarChartWrapper.swift
    └── PieChartWrapper.swift
```

## 🔧 Configuration

### Environment Variables
Create a `Secrets.plist` file with:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_URL</key>
    <string>https://your-api-gateway-url.execute-api.region.amazonaws.com</string>
    <key>API_TOKEN</key>
    <string>your-api-key</string>
</dict>
</plist>
```

### Firebase Configuration
1. Add `GoogleService-Info.plist` to the project
2. Configure Google Sign-In in Firebase Console
3. Enable Authentication with Google provider

## 🧪 Testing

### Unit Tests
- ViewModels can be tested with mock API clients
- Models include validation logic for testing
- Use `MockAPIClient` for network testing

### UI Tests
- Accessibility labels for automated testing
- Consistent view hierarchy for UI testing

## 📱 Deployment

### Production Checklist
- [ ] Configure production API endpoints
- [ ] Set up proper Firebase configuration
- [ ] Test on multiple device sizes
- [ ] Verify accessibility features
- [ ] Check performance metrics
- [ ] Validate error handling

### App Store Submission
- [ ] Update app metadata and screenshots
- [ ] Configure app signing and provisioning
- [ ] Test with TestFlight
- [ ] Submit for App Store review

## 🔒 Security

### Data Protection
- All API calls use HTTPS
- User authentication via Google OAuth
- API key stored securely in plist
- No sensitive data in logs

### Privacy
- Minimal data collection
- User data isolated by email
- No third-party analytics
- GDPR compliant

## 🚀 Performance

### Optimizations
- Lazy loading of charts
- Efficient data structures
- Minimal network requests
- Proper memory management

### Monitoring
- Structured logging for debugging
- Performance metrics tracking
- Error rate monitoring

## 🤝 Contributing

### Code Style
- Follow Swift style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Git Workflow
- Feature branches for new development
- Pull requests for code review
- Commit messages follow conventional format
- Squash commits before merging

## 📄 License

This project is proprietary software. All rights reserved.

## 🆘 Support

For issues and questions:
1. Check the logs using Console.app
2. Review error messages in the app
3. Contact the development team

---

**Built with ❤️ using SwiftUI and modern iOS development practices**
