# AssaAbloy Test iOS

Welcome to the Assa Abloy Test App documentation. This iOS application manages building access control, allowing users to securely authenticate and view managed doors, read door events in real-time, and manage explicit access permissions across various credential mechanisms.

## Features

- **Authentication Module**: Secure SignIn and SignUp implementations using JWT token-based authentication stored in the Keychain.
- **Doors Management**: 
  - List available doors associated with a user's account.
  - Interactive UI supporting real-time data pulling and generic loading/empty states.
- **Door Events**: View historical events mapped to specific doors (Unlock events, access denials, hardware alerts).
- **Permissions Generation**: Add, edit, and delete access credentials assigning access to a door.
  - Supports credential models: `SMARTPHONE`, `PASSCODE`, or `CARD`.
  - Immutable specific types and credential entries post-creation.
  - Bitmask-derived day-of-the-week management handling days visually mapped effectively to API backend properties.
- **Global Empty State UI**: Clean, responsive modular `.overlay()` interfaces gracefully masking empty datasets.

## Architecture

This project is built using native iOS frameworks and follows a clean MVVM (Model-View-ViewModel) architectural pattern augmented by clear directory segregation, minimizing module coupling.

- `Core/`: Contains reusable structural components (Networking client, Keychain wrapper, utilities, and views like `EmptyStateView`).
- `Features/`: Encapsulates independent user journeys (`Auth`, `Doors`). Each module follows internal `Models/`, `Services/`, `ViewModels/`, `Views/`, and `DI/` (Dependency Injection logic parsing module builders/factories).
- native `SwiftUI`: Fully implemented in SwiftUI. Minimal state coupling relying primarily on `@StateObject` publishers ensuring real-time responsive UIs.
- **Network Routing**: A streamlined generic lightweight REST client using standard `async/await` handling robust networking, status codes logic, and decoding standard decoupled DTO payloads seamlessly.

## Requirements

- **iOS Version**: 16.0+
- **Xcode Version**: 15.0+
- **Language**: Swift 5.9+

## Running the Project

1. Open `AssaAbloy.xcodeproj` in Xcode.
2. Select an active iOS Simulator / physical device matching constraints.
3. Build and Run (`Cmd + R`).

*Ensure the backend endpoints and environment urls defined in `Configuration.swift` match your mock or local Postman test server configurations before launching.*

## Testing

A native `XCTest` suite lives under the `AssaAbloyTests/` target validating core business logic.
To run tests locally:
1. Hit `Cmd + U` within Xcode.
2. Ensure specific networking service mocks intercept payloads correctly ensuring accurate Model validation (`PermissionModels`, `AuthViewModel`, etc).

## AI Usage

This project was developed with the assistance of Copilot/Claude. It aided in various stages of the development lifecycle, including structuring the initial architecture, generating repetitive boilerplate code, implementing specific complex logic like the bitwise operations for day parsing, validating constraints across network responses, and formatting pull requests/documentations
