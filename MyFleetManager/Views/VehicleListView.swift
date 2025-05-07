import SwiftUI

struct VehicleListView: View {
    @StateObject private var viewModel = FleetViewModel()
    @State private var showingAddVehicle = false
    @State private var showingReportView = false
    @State private var showingDeleteConfirmation = false
    @State private var vehicleToDelete: Vehicle?
    @State private var currentTipIndex = 0
    
    private let tips = [
        "💡 Tip: Use the Reports feature to generate detailed fleet reports",
        "💡 Tip: Swipe left on a vehicle to quickly delete it",
        "💡 Tip: Track maintenance by adding damages to vehicles",
        "💡 Tip: Export reports as PDF for professional documentation",
        "💡 Tip: Use the status feature to track vehicle conditions",
        "💡 Tip: Add photos to document vehicle conditions",
        "💡 Tip: Monitor rental and lease dates in the vehicle details",
        "💡 Tip: Sort vehicles by status, van number, or rental end date",
        "💡 Tip: View detailed vehicle information by tapping on any vehicle",
        "💡 Tip: Keep your fleet information up to date for accurate reporting"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HeaderView()
                
                // Welcome and Tips Section
                VStack(spacing: 12) {
                    Text("Welcome to My Fleet Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 2)
                    
                    if viewModel.vehicles.isEmpty {
                        Text("Get started by adding your first vehicle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text(tips[currentTipIndex])
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .onAppear {
                                // Rotate tips every 7 seconds
                                Timer.scheduledTimer(withTimeInterval: 7.0, repeats: true) { _ in
                                    withAnimation {
                                        currentTipIndex = (currentTipIndex + 1) % tips.count
                                    }
                                }
                            }
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: { showingAddVehicle = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Add Vehicle")
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: { showingReportView = true }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.title2)
                                Text("Reports")
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(.systemBackground))
                
                // DSP Question Section (only shown on first launch)
                if !viewModel.hasCompletedOnboarding {
                    VStack(spacing: 12) {
                        Text("Are you a DSP?")
                            .font(.headline)
                        
                        Text("(Delivery Service Partner)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Button(action: { viewModel.setDSPStatus(true) }) {
                                Text("Yes")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: { viewModel.setDSPStatus(false) }) {
                                Text("No")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Vehicle List
                if viewModel.vehicles.isEmpty {
                    Spacer()
                    Text("No vehicles added yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Sort:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Sort By", selection: $viewModel.sortOption) {
                                ForEach(VehicleSortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        
                        List {
                            ForEach(viewModel.sortedVehicles) { vehicle in
                                NavigationLink(destination: VehicleDetailView(vehicle: vehicle, viewModel: viewModel)) {
                                    VehicleRowView(vehicle: vehicle)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        vehicleToDelete = vehicle
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingReportView) {
                ReportView(viewModel: viewModel)
            }
            .alert("Delete Vehicle", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    vehicleToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let vehicle = vehicleToDelete {
                        viewModel.deleteVehicle(vehicle)
                    }
                    vehicleToDelete = nil
                }
            } message: {
                if let vehicle = vehicleToDelete {
                    Text("Are you sure you want to delete Van #\(vehicle.vanNumber)? This action cannot be undone.")
                }
            }
        }
        .navigationViewStyle(.stack) // This helps with iPad layout
    }
}

struct VehicleRowView: View {
    let vehicle: Vehicle
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Van #\(vehicle.vanNumber)")
                .font(.headline)
            Text("Plate: \(vehicle.plateNumber)")
                .font(.subheadline)
            Text("Status: \(vehicle.status.rawValue.capitalized)")
                .font(.caption)
                .foregroundColor(statusColor(vehicle.status))
        }
    }
    
    private func statusColor(_ status: VehicleStatus) -> Color {
        switch status {
        case .active: return .green
        case .needsRepair: return .orange
        case .grounded: return .red
        case .returned: return .gray
        }
    }
} 