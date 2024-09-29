# SWAPI PlanetsApp

This iOS app displays a list of planets from the Star Wars universe using the [SWAPI](https://swapi.dev/) (Star Wars API). The app focuses on providing an offline-first experience with a clean, modern UI built using SwiftUI.

## Features

- Displays a list of planet names from the first page of planet data
- Persists planet data for offline viewing
- Universal app design (works on iPhone and iPad)
- Built with SwiftUI and Combine
- Uses Codable for JSON parsing
- Includes unit tests
- Supports iOS 15.0 and later

## Requirements

- Xcode 13.0 or later
- iOS 15.0 or later
- Swift 5.5 or later


## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses SwiftUI for the UI layer. It also incorporates Combine for reactive programming and Core Data for local persistence.

## Project Structure

- `Models/`: Contains the data models for planets
- `Views/`: Contains SwiftUI views
- `ViewModels/`: Contains view models that manage the business logic
- `Services/`: Contains networking and persistence services
- `Utilities/`: Contains helper classes and extensions
- `Tests/`: Contains unit tests for the app

## API

The app uses the following API endpoint:

```
https://swapi.dev/api/planets/
```

This endpoint returns a JSON list of planets from the Star Wars universe.

## Future Improvements

1. Implement pagination to load more than the first page of planet data
2. Add a search feature to filter planets by name
3. Include detailed views for each planet with more information
4. Implement error handling and retry mechanisms for network requests
5. Add pull-to-refresh functionality to update planet data
6. Implement a favorites system for users to bookmark their favorite planets
7. Add localization support for multiple languages
8. Implement dark mode support
9. Add accessibility features to improve the app's usability for all users
10. Implement caching mechanisms to reduce API calls and improve performance
