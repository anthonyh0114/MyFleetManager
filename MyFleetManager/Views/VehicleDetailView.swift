import SwiftUI
import PhotosUI

struct VehicleDetailView: View {
    let vehicle: Vehicle
    @ObservedObject var viewModel: FleetViewModel
    @State private var showingImageSourcePicker = false
    @State private var showingDamageSheet = false
    @State private var showingEditSheet = false
    @State private var showingMileageSheet = false
    @State private var selectedImage: UIImage?
    @State private var photoDescription = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Basic Information
                GroupBox("Vehicle Information") {
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(title: "Van Number", value: vehicle.vanNumber)
                        InfoRow(title: "Plate Number", value: vehicle.plateNumber)
                        InfoRow(title: "VIN", value: vehicle.vin)
                        InfoRow(title: "Status", value: vehicle.status.rawValue.capitalized)
                        InfoRow(title: "Ownership", value: vehicle.ownership.rawValue.capitalized)
                        
                        if vehicle.ownership == .rented {
                            InfoRow(title: "Rental Company", value: vehicle.rentalCompany ?? "N/A")
                            if let startDate = vehicle.rentalStartDate {
                                InfoRow(title: "Rental Start", value: startDate.formatted(date: .long, time: .omitted))
                            }
                            if let endDate = vehicle.rentalEndDate {
                                InfoRow(title: "Rental End", value: endDate.formatted(date: .long, time: .omitted))
                            }
                        }
                        
                        if vehicle.ownership == .amazonLeased {
                            if let startDate = vehicle.rentalStartDate {
                                InfoRow(title: "Lease Start", value: startDate.formatted(date: .long, time: .omitted))
                            }
                            if let endDate = vehicle.rentalEndDate {
                                InfoRow(title: "Lease End", value: endDate.formatted(date: .long, time: .omitted))
                            }
                        }
                        
                        // Mileage Information
                        VStack(alignment: .leading, spacing: 5) {
                            InfoRow(title: "Current Mileage", value: "\(vehicle.currentMileage)")
                            if let lastUpdate = vehicle.lastMileageUpdate {
                                InfoRow(title: "Last Updated", value: lastUpdate.formatted(date: .long, time: .omitted))
                            }
                            
                            Button(action: { showingMileageSheet = true }) {
                                HStack {
                                    Image(systemName: "speedometer")
                                    Text("Update Mileage")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // QR Code Section
                GroupBox("Vehicle QR Code") {
                    VStack {
                        QRCodeView(vin: vehicle.vin)
                            .padding()
                        
                        Text("Scan to view vehicle information")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Photos Section
                GroupBox("Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(vehicle.photos) { photo in
                                if let uiImage = UIImage(data: photo.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            
                            Button(action: { showingImageSourcePicker = true }) {
                                VStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.largeTitle)
                                    Text("Add Photo")
                                }
                                .frame(width: 200, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                
                // Damages Section
                GroupBox("Damage History") {
                    ForEach(vehicle.damages) { damage in
                        VStack(alignment: .leading) {
                            Text(damage.description)
                                .font(.headline)
                            Text("Reported: \(damage.dateReported.formatted())")
                                .font(.caption)
                            Text(damage.isNewDamage ? "New Damage" : "Existing Damage")
                                .font(.caption)
                                .foregroundColor(damage.isNewDamage ? .red : .orange)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Button("Report New Damage") {
                        showingDamageSheet = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Van #\(vehicle.vanNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingImageSourcePicker) {
            ImageSourcePicker(image: $selectedImage, onImagePicked: { image in
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    viewModel.addPhoto(to: vehicle, imageData: imageData, description: photoDescription)
                }
            })
        }
        .sheet(isPresented: $showingDamageSheet) {
            AddDamageView(vehicle: vehicle, viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditVehicleView(vehicle: vehicle, viewModel: viewModel)
        }
        .sheet(isPresented: $showingMileageSheet) {
            UpdateMileageView(vehicle: vehicle, viewModel: viewModel)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
} 