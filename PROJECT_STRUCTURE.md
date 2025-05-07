# My Fleet Manager - Project Structure

```
MyFleetManager/
├── MyFleetManagerApp.swift (Main app entry point)
├── ContentView.swift (Root view)
├── Info.plist (App configuration)
│
├── Models/
│   ├── Vehicle.swift (Vehicle data model)
│   ├── VehiclePhoto.swift (Photo data model)
│   └── DamageRecord.swift (Damage record model)
│
├── Views/
│   ├── VehicleListView.swift (Main list of vehicles)
│   ├── VehicleDetailView.swift (Detailed vehicle view)
│   ├── AddVehicleView.swift (Add new vehicle form)
│   ├── AddDamageView.swift (Report damage form)
│   └── ImagePicker.swift (Photo picker component)
│
├── ViewModels/
│   └── FleetViewModel.swift (Business logic and data management)
│
├── Services/
│   └── (Future service layer for API calls, etc.)
│
├── Utilities/
│   └── (Helper functions and extensions)
│
└── Resources/
    └── (Assets, configurations, etc.)
```

## Key Components

### Models
- **Vehicle**: Core data model for fleet vehicles
- **VehiclePhoto**: Model for storing vehicle photos
- **DamageRecord**: Model for tracking vehicle damages

### Views
- **VehicleListView**: Main screen showing all vehicles
- **VehicleDetailView**: Detailed view of a single vehicle
- **AddVehicleView**: Form for adding new vehicles
- **AddDamageView**: Form for reporting damages
- **ImagePicker**: Reusable photo picker component

### ViewModels
- **FleetViewModel**: Manages vehicle data and business logic

### Data Flow
```
User Interface (Views) ←→ ViewModel ←→ Data Models
```

### Features
- Vehicle management (add, edit, delete)
- Photo documentation
- Damage tracking
- Rental agreement management
- Status monitoring 