import Foundation
import SwiftData

@Model
class VariantEvidenceScore {
    @Attribute(.unique) var id: UUID
    var detectionEvidenceId: UUID
    var skuId: UUID
    var contrastiveScore: Double
    var differentiatorMatchNotes: String
    var createdAt: Date

    init(
        detectionEvidenceId: UUID,
        skuId: UUID,
        contrastiveScore: Double,
        differentiatorMatchNotes: String = ""
    ) {
        self.id = UUID()
        self.detectionEvidenceId = detectionEvidenceId
        self.skuId = skuId
        self.contrastiveScore = contrastiveScore
        self.differentiatorMatchNotes = differentiatorMatchNotes
        self.createdAt = Date()
    }
}
