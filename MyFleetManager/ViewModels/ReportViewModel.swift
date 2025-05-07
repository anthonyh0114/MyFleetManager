import Foundation
import SwiftUI

class ReportViewModel: ObservableObject {
    @Published var selectedStatus: VehicleStatus?
    @Published var selectedOwnership: VehicleOwnership?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var showOnlyDamaged: Bool = false
    
    func generateReport(from vehicles: [Vehicle]) -> [Vehicle] {
        var filteredVehicles = vehicles
        
        // Filter by status
        if let status = selectedStatus {
            filteredVehicles = filteredVehicles.filter { $0.status == status }
        }
        
        // Filter by ownership
        if let ownership = selectedOwnership {
            filteredVehicles = filteredVehicles.filter { $0.ownership == ownership }
        }
        
        // Filter by date range
        if let start = startDate, let end = endDate {
            filteredVehicles = filteredVehicles.filter { vehicle in
                if let rentalStart = vehicle.rentalStartDate {
                    return rentalStart >= start && rentalStart <= end
                }
                return false
            }
        }
        
        // Filter by damage
        if showOnlyDamaged {
            filteredVehicles = filteredVehicles.filter { !$0.damages.isEmpty }
        }
        
        return filteredVehicles
    }
    
    func generateReportText(from vehicles: [Vehicle]) -> String {
        var reportText = "Fleet Management Report\n"
        reportText += "Generated on: \(Date().formatted())\n\n"
        
        // Summary
        reportText += "Summary:\n"
        reportText += "Total Vehicles: \(vehicles.count)\n"
        reportText += "Active Vehicles: \(vehicles.filter { $0.status == .active }.count)\n"
        reportText += "Vehicles Needing Repair: \(vehicles.filter { $0.status == .needsRepair }.count)\n"
        reportText += "Rented Vehicles: \(vehicles.filter { $0.ownership == .rented }.count)\n"
        reportText += "Amazon Leased Vehicles: \(vehicles.filter { $0.ownership == .amazonLeased }.count)\n\n"
        
        // Mileage Summary
        let totalMileage = vehicles.reduce(0) { $0 + $1.currentMileage }
        let averageMileage = vehicles.isEmpty ? 0 : totalMileage / vehicles.count
        reportText += "Mileage Summary:\n"
        reportText += "Total Fleet Mileage: \(totalMileage)\n"
        reportText += "Average Vehicle Mileage: \(averageMileage)\n"
        reportText += "Highest Mileage: \(vehicles.map { $0.currentMileage }.max() ?? 0)\n"
        reportText += "Lowest Mileage: \(vehicles.map { $0.currentMileage }.min() ?? 0)\n\n"
        
        // Detailed List
        reportText += "Detailed Vehicle List:\n"
        for vehicle in vehicles {
            reportText += "\nVan #\(vehicle.vanNumber)\n"
            reportText += "Plate: \(vehicle.plateNumber)\n"
            reportText += "VIN: \(vehicle.vin)\n"
            reportText += "Status: \(vehicle.status.rawValue)\n"
            reportText += "Ownership: \(vehicle.ownership.rawValue)\n"
            
            // Mileage Information
            reportText += "Current Mileage: \(vehicle.currentMileage)\n"
            if let lastUpdate = vehicle.lastMileageUpdate {
                reportText += "Last Mileage Update: \(lastUpdate.formatted(date: .long, time: .omitted))\n"
            }
            
            // Mileage History
            if !vehicle.mileageRecords.isEmpty {
                reportText += "Mileage History:\n"
                for record in vehicle.mileageRecords.sorted(by: { $0.date > $1.date }) {
                    reportText += "- \(record.mileage) miles on \(record.date.formatted(date: .long, time: .omitted))\n"
                }
            }
            
            if vehicle.ownership == .rented {
                reportText += "Rental Company: \(vehicle.rentalCompany ?? "N/A")\n"
                if let startDate = vehicle.rentalStartDate {
                    reportText += "Rental Start: \(startDate.formatted(date: .long, time: .omitted))\n"
                }
                if let endDate = vehicle.rentalEndDate {
                    reportText += "Rental End: \(endDate.formatted(date: .long, time: .omitted))\n"
                }
            }
            
            if vehicle.ownership == .amazonLeased {
                if let startDate = vehicle.rentalStartDate {
                    reportText += "Lease Start: \(startDate.formatted(date: .long, time: .omitted))\n"
                }
                if let endDate = vehicle.rentalEndDate {
                    reportText += "Lease End: \(endDate.formatted(date: .long, time: .omitted))\n"
                }
            }
            
            if !vehicle.damages.isEmpty {
                reportText += "Damage Reports: \(vehicle.damages.count)\n"
                for damage in vehicle.damages {
                    reportText += "- \(damage.description) (\(damage.dateReported.formatted()))\n"
                }
            }
            
            reportText += "Photos: \(vehicle.photos.count)\n"
            reportText += "----------------------------------------\n"
        }
        
        return reportText
    }
} 