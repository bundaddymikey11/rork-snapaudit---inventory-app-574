import Foundation

/// Lightweight filter for narrowing a `[ProductSKU]` candidate set.
/// Used by the catalog UI and the recognition pipeline.
nonisolated struct SKUCatalogFilter: Sendable {
    /// nil = include all parent categories
    var parentCategory: String?
    /// nil = include all subcategories (ignored if parentCategory is nil)
    var subcategory: String?
    /// empty = include all brands
    var brands: Set<String>
    /// nil = include all look-alike groups
    var lookAlikeGroupId: UUID?
    /// When true, only `isActive == true` SKUs are returned
    var activeOnly: Bool

    init(
        parentCategory: String? = nil,
        subcategory: String? = nil,
        brands: Set<String> = [],
        lookAlikeGroupId: UUID? = nil,
        activeOnly: Bool = true
    ) {
        self.parentCategory = parentCategory
        self.subcategory = subcategory
        self.brands = brands
        self.lookAlikeGroupId = lookAlikeGroupId
        self.activeOnly = activeOnly
    }

    /// Returns the subset of `skus` that pass all active filters.
    func apply(to skus: [ProductSKU]) -> [ProductSKU] {
        skus.filter { passes($0) }
    }

    /// Returns the UUIDs of SKUs that pass all active filters.
    func candidateIds(from skus: [ProductSKU]) -> [UUID] {
        skus.compactMap { passes($0) ? $0.id : nil }
    }

    // MARK: Private

    private func passes(_ sku: ProductSKU) -> Bool {
        if activeOnly && !sku.isActive { return false }

        if let pc = parentCategory, !pc.isEmpty {
            guard sku.normalizedParentCategory == pc.normalized else { return false }
            if let sc = subcategory, !sc.isEmpty {
                guard sku.normalizedSubcategory == sc.normalized else { return false }
            }
        }

        if !brands.isEmpty {
            let normalizedBrands = brands.map { $0.normalized }
            guard normalizedBrands.contains(sku.normalizedBrand) else { return false }
        }

        if let groupId = lookAlikeGroupId {
            guard sku.lookAlikeGroupId == groupId else { return false }
        }

        return true
    }
}
