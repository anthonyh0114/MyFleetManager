import Foundation

struct DamageRecord: Identifiable, Codable {
    var id: UUID
    var description: String
    var dateReported: Date
    var isNewDamage: Bool
    var photos: [VehiclePhoto]
    
    init(id: UUID = UUID(), description: String, dateReported: Date = Date(), 
         isNewDamage: Bool, photos: [VehiclePhoto] = []) {
        self.id = id
        self.description = description
        self.dateReported = dateReported
        self.isNewDamage = isNewDamage
        self.photos = photos
    }
} 