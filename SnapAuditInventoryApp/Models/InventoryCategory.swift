import Foundation

enum InventoryCategory: String, CaseIterable, Identifiable, Codable {
    case flower = "Flower"
    case preRolls = "Pre-Rolls"
    case aioVapes = "AIO Vapes"
    case cartridges = "Cartridges"
    case concentrates = "Concentrates"
    case edibles = "Edibles"
    case batteries = "Batteries"
    case merchandise = "Merchandise" // Added a few common ones just in case
    case accessories = "Accessories"
    case other = "Other"

    var id: String { rawValue }
    var displayName: String { rawValue }

    static var auditCategories: [InventoryCategory] {
        [.flower, .preRolls, .aioVapes, .cartridges, .concentrates, .edibles, .batteries]
    }
}
