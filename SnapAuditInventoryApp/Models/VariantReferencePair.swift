import Foundation
import SwiftData

@Model
class VariantReferencePair {
    @Attribute(.unique) var id: UUID
    var lookAlikeGroupId: UUID
    var primarySkuId: UUID
    var comparisonSkuId: UUID
    var createdAt: Date

    init(
        lookAlikeGroupId: UUID,
        primarySkuId: UUID,
        comparisonSkuId: UUID
    ) {
        self.id = UUID()
        self.lookAlikeGroupId = lookAlikeGroupId
        self.primarySkuId = primarySkuId
        self.comparisonSkuId = comparisonSkuId
        self.createdAt = Date()
    }
}
