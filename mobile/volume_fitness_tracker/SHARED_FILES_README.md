# Shared Files Setup for iOS and watchOS

This document explains how to set up shared files between the iOS and watchOS targets to ensure consistency and reduce code duplication.

## Shared Files

The following files should be shared between both targets:

### 1. SharedCloudKitManager.swift
**Location**: `volume_fitness_tracker/Utils/SharedCloudKitManager.swift`

This file contains the CloudKit manager that handles user data synchronization between iOS and watchOS apps.

### 2. SharedConstants.swift
**Location**: `volume_fitness_tracker/Utils/SharedConstants.swift`

This file contains shared constants, error types, and logging prefixes used by both apps.

### 3. SharedModels.swift
**Location**: `volume_fitness_tracker/Utils/SharedModels.swift`

This file contains shared data models (ExerciseData, FitnessDataResponse, ExerciseDetail) used by both apps.

## How to Add Files to Both Targets

### In Xcode:

1. **Add the file to the iOS target first**:
   - Right-click on the `Utils` folder in the iOS target
   - Select "Add Files to 'volume_fitness_tracker'"
   - Choose the file you want to add

2. **Add the same file to the watchOS target**:
   - In the Project Navigator, find the file you just added
   - Select the file
   - In the File Inspector (right panel), check the box next to the watchOS target
   - The file should now appear in both targets

### Alternative Method:

1. **Drag and drop the file**:
   - Drag the file from Finder into the Xcode project
   - In the dialog that appears, make sure both targets are checked
   - Click "Add"

## Current Shared Files

### SharedCloudKitManager.swift
- **Purpose**: Manages CloudKit operations for user data synchronization
- **Features**:
  - Saves user email and name from iOS app to CloudKit
  - Fetches user data on both iOS and watchOS apps
  - Handles CloudKit status checking
  - Provides comprehensive logging for debugging
  - Supports thousands of users with proper error handling

### SharedConstants.swift
- **Purpose**: Provides shared constants and error types
- **Features**:
  - CloudKit configuration constants
  - UI constants for consistent styling
  - Chart configuration constants
  - Number formatting constants
  - Logging prefixes for consistent debugging
  - Shared error types

### SharedModels.swift
- **Purpose**: Provides shared data models
- **Features**:
  - ExerciseData for chart display
  - FitnessDataResponse for API responses
  - ExerciseDetail for exercise information
  - Proper Codable conformance for JSON parsing

## CloudKit Configuration

The shared CloudKit manager uses the following configuration:

- **Container ID**: `iCloud.com.bernsonfamily.volume-fitness-tracker`
- **Record Type**: `UserData`
- **Record Name**: `currentUser`
- **Fields**: `email`, `name`, `lastUpdated`

## Logging

Both apps use consistent logging prefixes:
- **iOS**: `📱 iOS`
- **Watch**: `⌚ Watch`
- **CloudKit**: `☁️ CloudKit`

## Benefits of Shared Files

1. **DRY Principle**: No code duplication between targets
2. **Consistency**: Both apps use the same constants and logic
3. **Maintainability**: Changes only need to be made in one place
4. **Debugging**: Consistent logging across both platforms
5. **Scalability**: Supports thousands of users with proper CloudKit handling

## Troubleshooting

### If files don't appear in both targets:
1. Select the file in Xcode
2. Open the File Inspector (right panel)
3. Check that both targets are selected under "Target Membership"

### If CloudKit isn't working:
1. Check that both apps have the same CloudKit container identifier
2. Verify that the user is signed into iCloud on both devices
3. Check the console logs for detailed error messages
4. Ensure the CloudKit container is properly configured in Apple Developer Console

### If shared constants aren't being recognized:
1. Make sure the file is added to both targets
2. Clean and rebuild the project
3. Check that there are no naming conflicts with existing constants

## Future Considerations

When adding new shared functionality:

1. **Create shared files** in the `Utils` folder
2. **Add to both targets** using the methods described above
3. **Use shared constants** for configuration values
4. **Follow the logging pattern** with appropriate prefixes
5. **Test on both platforms** to ensure compatibility
