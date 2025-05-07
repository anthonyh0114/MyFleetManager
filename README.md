# My Fleet Manager

An iOS application for managing fleet vehicles, tracking rental agreements, and monitoring vehicle status. This app is designed to help fleet managers, particularly Delivery Service Partners (DSPs), efficiently manage their vehicle fleet.

## Features

- Track van numbers, plate numbers, and VINs
- Manage different types of vehicle ownership:
  - Owned vehicles
  - Rented vehicles
  - Amazon Leased vehicles (for DSPs)
  - Leased vehicles (for non-DSPs)
- Store rental and lease agreements
- Track vehicle operational status:
  - Active
  - Needs Repair
  - Grounded
  - Returned
- Document vehicle condition with photos
- Track damage history
- Local storage for all data
- DSP-specific features and configurations

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/anthonyh0114/MyFleetManager.git
   ```
2. Open `MyFleetManager.xcodeproj` in Xcode
3. Build and run the project

## Usage

1. On first launch, the app will ask if you are a DSP (Delivery Service Partner)
2. Based on your DSP status, you'll see different ownership options when adding vehicles
3. Add vehicles using the "Add Vehicle" button
4. View and manage your fleet in the main list
5. Use the Reports button to access fleet analytics

## Project Structure

- `Models/`: Data models for vehicles and related entities
- `Views/`: SwiftUI views for the user interface
- `ViewModels/`: View models for data management
- `Services/`: Business logic and data persistence
- `Utilities/`: Helper functions and extensions
- `Resources/`: Assets and configuration files

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Content Rights

Please read our [CONTENT_RIGHTS.md](CONTENT_RIGHTS.md) for information about content licensing and usage rights.

## Privacy

Please read our [PRIVACY.md](PRIVACY.md) for information about how we handle your data.

## Support

If you encounter any issues or have questions, please:
1. Check the [Issues](https://github.com/anthonyh0114/MyFleetManager/issues) page
2. Create a new issue if your problem hasn't been reported
3. Contact support at support@myfleetmanager.com

## Acknowledgments

- SwiftUI for the modern UI framework
- Apple's Core Data for local storage
- The open-source community for various tools and libraries 