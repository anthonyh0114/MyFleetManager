import Foundation

struct VehiclePhoto: Identifiable, Codable {
    var id: UUID
    var imageData: Data
    var timestamp: Date
    var description: String
    
    init(id: UUID = UUID(), imageData: Data, timestamp: Date = Date(), description: String) {
        self.id = id
        self.imageData = imageData
        self.timestamp = timestamp
        self.description = description
    }
} 