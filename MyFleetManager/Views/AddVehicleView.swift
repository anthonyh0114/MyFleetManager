import SwiftUI

struct AddVehicleView: View {
    @ObservedObject var viewModel: FleetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var vanNumber = ""
    @State private var plateNumber = ""
    @State private var vin = ""
    @State private var ownership: VehicleOwnership = .owned
    @State private var rentalCompany = ""
    @State private var rentalStartDate = Date()
    @State private var rentalEndDate = Date()
    @State private var leasingCompany = ""
    @State private var leaseStartDate = Date()
    @State private var leaseEndDate = Date()
    @State private var status: VehicleStatus = .active
    
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
                        Text("Owned").tag(VehicleOwnership.owned)
                        Text("Rented").tag(VehicleOwnership.rented)
                        if viewModel.isDSP {
                            Text("Amazon Leased").tag(VehicleOwnership.amazonLeased)
                        } else {
                            Text("Leased").tag(VehicleOwnership.leased)
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
                    
                    if ownership == .leased {
                        TextField("Leasing Company", text: $leasingCompany)
                        DatePicker("Lease Start Date", selection: $leaseStartDate, displayedComponents: .date)
                        DatePicker("Lease End Date", selection: $leaseEndDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Vehicle")
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
        let vehicle = Vehicle(
            vanNumber: vanNumber,
            plateNumber: plateNumber,
            vin: vin,
            ownership: ownership,
            rentalCompany: ownership == .rented ? rentalCompany : 
                         ownership == .leased ? leasingCompany : nil,
            rentalStartDate: ownership == .rented ? rentalStartDate : 
                           ownership == .amazonLeased ? rentalStartDate :
                           ownership == .leased ? leaseStartDate : nil,
            rentalEndDate: ownership == .rented ? rentalEndDate :
                         ownership == .amazonLeased ? rentalEndDate :
                         ownership == .leased ? leaseEndDate : nil,
            status: status
        )
        viewModel.addVehicle(vehicle)
    }
} 