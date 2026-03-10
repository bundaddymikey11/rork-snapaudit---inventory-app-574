import Foundation
import SwiftData

@Model
class VariantComparisonProfile {
    @Attribute(.unique) var id: UUID
    var lookAlikeGroupId: UUID
    var createdAt: Date
    var updatedAt: Date
    var notes: String
    var differentiatorZonesJSON: String
    var differentiatorKeywordsJSON: String

    init(
        lookAlikeGroupId: UUID,
        notes: String = "",
        differentiatorZonesJSON: String = "[]",
        differentiatorKeywordsJSON: String = "{}"
    ) {
        self.id = UUID()
        self.lookAlikeGroupId = lookAlikeGroupId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.notes = notes
        self.differentiatorZonesJSON = differentiatorZonesJSON
        self.differentiatorKeywordsJSON = differentiatorKeywordsJSON
    }

    var differentiatorZones: [ZoneRect] {
        get {
            guard let data = differentiatorZonesJSON.data(using: .utf8) else { return [] }
            return (try? JSONDecoder().decode([ZoneRect].self, from: data)) ?? []
        }
        set {
            let data = (try? JSONEncoder().encode(newValue)) ?? Data()
            differentiatorZonesJSON = String(data: data, encoding: .utf8) ?? "[]"
            updatedAt = Date()
        }
    }

    /// Keywords keyed by SKU ID string → array of keywords
    var differentiatorKeywords: [String: [String]] {
        get {
            guard let data = differentiatorKeywordsJSON.data(using: .utf8) else { return [:] }
            return (try? JSONDecoder().decode([String: [String]].self, from: data)) ?? [:]
        }
        set {
            let data = (try? JSONEncoder().encode(newValue)) ?? Data()
            differentiatorKeywordsJSON = String(data: data, encoding: .utf8) ?? "{}"
            updatedAt = Date()
        }
    }
}
