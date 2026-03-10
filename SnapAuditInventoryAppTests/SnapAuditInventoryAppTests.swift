//
//  SnapAuditInventoryAppTests.swift
//  SnapAuditInventoryAppTests
//
//  Created by Rork on March 1, 2026.
//

import Testing
@testable import SnapAuditInventoryApp

struct SnapAuditInventoryAppTests {

    @Test func testPredefinedCategories() async throws {
        let viewModel = await CatalogViewModel()
        let categories = await viewModel.categories
        
        let expected = ["Flower", "Pre-Rolls", "AIO Vapes", "Cartridges", "Concentrates", "Edibles", "Batteries"]
        for cat in expected {
            #expect(categories.contains(cat), "Missing category: \(cat)")
        }
    }

}
