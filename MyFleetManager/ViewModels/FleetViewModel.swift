import Foundation
import SwiftUI

enum VehicleSortOption: String, CaseIterable {
    case resetOrder = "Reset"
    case status = "Status"
    case vanNumber = "Van Number"
    case rentalEndDate = "Rental End Date"
}

class FleetViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var sortOption: VehicleSortOption = .resetOrder
    @Published var isDSP: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    
    private let saveKey = "fleetVehicles"
    private let dspKey = "isDSP"
    private let onboardingKey = "hasCompletedOnboarding"
    
    var sortedVehicles: [Vehicle] {
        switch sortOption {
        case .resetOrder:
            return vehicles
        case .status:
            return vehicles.sorted { $0.status.rawValue < $1.status.rawValue }
        case .vanNumber:
            return vehicles.sorted { $0.vanNumber < $1.vanNumber }
        case .rentalEndDate:
            return vehicles.sorted { 
                let date1 = $0.rentalEndDate ?? Date.distantFuture
                let date2 = $1.rentalEndDate ?? Date.distantFuture
                return date1 < date2
            }
        }
    }
    
    init() {
        loadVehicles()
        loadDSPStatus()
        loadOnboardingStatus()
    }
    
    func setDSPStatus(_ isDSP: Bool) {
        self.isDSP = isDSP
        UserDefaults.standard.set(isDSP, forKey: dspKey)
        UserDefaults.standard.set(true, forKey: onboardingKey)
        hasCompletedOnboarding = true
    }
    
    private func loadDSPStatus() {
        isDSP = UserDefaults.standard.bool(forKey: dspKey)
    }
    
    private func loadOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        saveVehicles()
    }
    
    func updateVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
            saveVehicles()
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        saveVehicles()
    }
    
    func addPhoto(to vehicle: Vehicle, imageData: Data, description: String) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            let photo = VehiclePhoto(imageData: imageData, description: description)
            vehicles[index].photos.append(photo)
            saveVehicles()
        }
    }
    
    func addDamage(to vehicle: Vehicle, description: String, isNewDamage: Bool, photos: [VehiclePhoto]) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            let damage = DamageRecord(description: description, isNewDamage: isNewDamage, photos: photos)
            vehicles[index].damages.append(damage)
            saveVehicles()
        }
    }
    
    private func saveVehicles() {
        if let encoded = try? JSONEncoder().encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadVehicles() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Vehicle].self, from: data) {
            vehicles = decoded
        }
    }
} 