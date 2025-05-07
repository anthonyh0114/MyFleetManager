import Foundation

enum VehicleStatus: String, Codable {
    case active
    case needsRepair = "Needs Repair"
    case grounded
    case returned
}

enum VehicleOwnership: String, Codable {
    case owned
    case rented
    case amazonLeased = "Amazon Leased"
    case leased = "Leased"
}

struct MileageRecord: Identifiable, Codable {
    var id: UUID
    var mileage: Int
    var date: Date
    
    init(id: UUID = UUID(), mileage: Int, date: Date = Date()) {
        self.id = id
        self.mileage = mileage
        self.date = date
    }
}

struct Vehicle: Identifiable, Codable {
    var id: UUID
    var vanNumber: String
    var plateNumber: String
    var vin: String
    var ownership: VehicleOwnership
    var rentalCompany: String?
    var rentalStartDate: Date?
    var rentalEndDate: Date?
    var status: VehicleStatus
    var photos: [VehiclePhoto]
    var damages: [DamageRecord]
    var mileageRecords: [MileageRecord]
    
    init(id: UUID = UUID(), vanNumber: String, plateNumber: String, vin: String, 
         ownership: VehicleOwnership, rentalCompany: String? = nil, 
         rentalStartDate: Date? = nil, rentalEndDate: Date? = nil, 
         status: VehicleStatus = .active, photos: [VehiclePhoto] = [], 
         damages: [DamageRecord] = [], mileageRecords: [MileageRecord] = []) {
        self.id = id
        self.vanNumber = vanNumber
        self.plateNumber = plateNumber
        self.vin = vin
        self.ownership = ownership
        self.rentalCompany = rentalCompany
        self.rentalStartDate = rentalStartDate
        self.rentalEndDate = rentalEndDate
        self.status = status
        self.photos = photos
        self.damages = damages
        self.mileageRecords = mileageRecords
    }
    
    var currentMileage: Int {
        mileageRecords.sorted { $0.date > $1.date }.first?.mileage ?? 0
    }
    
    var lastMileageUpdate: Date? {
        mileageRecords.sorted { $0.date > $1.date }.first?.date
    }
} 