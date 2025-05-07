import SwiftUI

struct UpdateMileageView: View {
    let vehicle: Vehicle
    @ObservedObject var viewModel: FleetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var newMileage: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Mileage Information")) {
                    if let lastUpdate = vehicle.lastMileageUpdate {
                        Text("Last Updated: \(lastUpdate.formatted(date: .long, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Current Mileage: \(vehicle.currentMileage)")
                        .font(.headline)
                }
                
                Section(header: Text("Update Mileage")) {
                    TextField("New Mileage", text: $newMileage)
                        .keyboardType(.numberPad)
                    
                    Button("Update Mileage") {
                        updateMileage()
                    }
                    .disabled(newMileage.isEmpty)
                }
                
                if !vehicle.mileageRecords.isEmpty {
                    Section(header: Text("Mileage History")) {
                        ForEach(vehicle.mileageRecords.sorted(by: { $0.date > $1.date })) { record in
                            HStack {
                                Text("\(record.mileage)")
                                    .font(.headline)
                                Spacer()
                                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Update Mileage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Mileage Update", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateMileage() {
        guard let mileage = Int(newMileage) else {
            alertMessage = "Please enter a valid mileage number"
            showingAlert = true
            return
        }
        
        if mileage < vehicle.currentMileage {
            alertMessage = "New mileage cannot be less than current mileage"
            showingAlert = true
            return
        }
        
        let record = MileageRecord(mileage: mileage)
        var updatedVehicle = vehicle
        updatedVehicle.mileageRecords.append(record)
        viewModel.updateVehicle(updatedVehicle)
        
        alertMessage = "Mileage updated successfully"
        showingAlert = true
    }
} 