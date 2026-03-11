import Foundation

// MARK: - InventoryCategory

/// Top-level parent categories for SnapAudit.
/// These drive the category picker in product forms and audit setup.
/// The hierarchy is data-driven via `InventoryCategory.subcategoryMap`.
enum InventoryCategory: String, CaseIterable, Identifiable, Codable {
    case flower = "Flower"
    case vapePens = "Vape Pens"
    case edibles = "Edibles"
    case concentrates = "Concentrates"
    case preRolls = "Pre-Rolls"
    case batteries = "Batteries"
    case merchandise = "Merchandise"
    case accessories = "Accessories"
    case other = "Other"

    var id: String { rawValue }
    var displayName: String { rawValue }

    /// Subcategory options for each parent category.
    /// Stored as a static dictionary so it can grow without schema changes.
    static let subcategoryMap: [String: [String]] = [
        "Flower": ["Bud", "Infused Flower", "Preroll", "Infused Preroll"],
        "Vape Pens": ["All-In-One", "Cartridge", "Pod"],
        "Pre-Rolls": ["Singles", "Multipack", "Infused"],
        "Edibles": ["Gummy", "Chocolate", "Beverage", "Capsule", "Tincture", "Other Edible"],
        "Concentrates": ["Budder", "Crumble", "Diamonds", "Distillate", "Hash", "Rosin", "Sauce", "Shatter", "Wax"],
        "Batteries": ["510 Battery", "Pod Battery"],
        "Merchandise": [],
        "Accessories": [],
        "Other": [],
    ]

    /// Returns the list of subcategories for this parent, or an empty array.
    var subcategories: [String] {
        InventoryCategory.subcategoryMap[self.rawValue] ?? []
    }

    /// Returns subcategories for an arbitrary parent category string.
    static func subcategories(for parent: String) -> [String] {
        subcategoryMap[parent] ?? []
    }

    /// Categories exposed to the recognition / audit pipeline.
    static var auditCategories: [InventoryCategory] {
        [.flower, .vapePens, .preRolls, .concentrates, .edibles, .batteries]
    }

    /// All display names in stable sorted order for pickers.
    static var allDisplayNames: [String] {
        allCases.map(\.rawValue)
    }
}
