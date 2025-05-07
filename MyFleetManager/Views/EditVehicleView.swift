import SwiftUI

struct EditVehicleView: View {
    @ObservedObject var viewModel: FleetViewModel
    @Environment(\.dismiss) var dismiss
    
    let vehicle: Vehicle
    @State private var vanNumber: String
    @State private var plateNumber: String
    @State private var vin: String
    @State private var ownership: VehicleOwnership
    @State private var rentalCompany: String
    @State private var rentalStartDate: Date
    @State private var rentalEndDate: Date
    @State private var status: VehicleStatus
    
    init(vehicle: Vehicle, viewModel: FleetViewModel) {
        self.vehicle = vehicle
        self.viewModel = viewModel
        _vanNumber = State(initialValue: vehicle.vanNumber)
        _plateNumber = State(initialValue: vehicle.plateNumber)
        _vin = State(initialValue: vehicle.vin)
        _ownership = State(initialValue: vehicle.ownership)
        _rentalCompany = State(initialValue: vehicle.rentalCompany ?? "")
        _rentalStartDate = State(initialValue: vehicle.rentalStartDate ?? Date())
        _rentalEndDate = State(initialValue: vehicle.rentalEndDate ?? Date())
        _status = State(initialValue: vehicle.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Van Number", text: $vanNumber)
                    TextField("Plate Number", text: $plateNumber)
                    TextField("VIN", text: $vin)
                    Picker("Status", selection: $status) {
                        ForEach([VehicleStatus.active, .needsRepair, .grounded, .returned], id: \.self) { status in
                            Text(status.rawValue.capitalized)
                        }
                    }
                }
                
                Section(header: Text("Ownership")) {
                    Picker("Ownership", selection: $ownership) {
                        ForEach([VehicleOwnership.owned, .rented, .amazonLeased], id: \.self) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if ownership == .rented {
                        TextField("Rental Company", text: $rentalCompany)
                        DatePicker("Rental Start Date", selection: $rentalStartDate, displayedComponents: .date)
                        DatePicker("Rental End Date", selection: $rentalEndDate, displayedComponents: .date)
                    }
                    
                    if ownership == .amazonLeased {
                        Text("Amazon Leased vehicles are managed through Amazon's leasing program.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        DatePicker("Lease Start Date", selection: $rentalStartDate, displayedComponents: .date)
                        DatePicker("Lease End Date", selection: $rentalEndDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveVehicle()
                        dismiss()
                    }
                    .disabled(vanNumber.isEmpty || plateNumber.isEmpty || vin.isEmpty)
                }
            }
        }
    }
    
    private func saveVehicle() {
        let updatedVehicle = Vehicle(
            id: vehicle.id,
            vanNumber: vanNumber,
            plateNumber: plateNumber,
            vin: vin,
            ownership: ownership,
            rentalCompany: ownership == .rented ? rentalCompany : nil,
            rentalStartDate: ownership == .rented ? rentalStartDate : nil,
            rentalEndDate: ownership == .rented ? rentalEndDate : nil,
            status: status,
            photos: vehicle.photos,
            damages: vehicle.damages
        )
        viewModel.updateVehicle(updatedVehicle)
    }
} 