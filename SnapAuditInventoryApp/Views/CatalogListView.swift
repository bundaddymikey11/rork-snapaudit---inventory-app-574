import SwiftUI
import SwiftData

struct CatalogListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: CatalogViewModel
    @State private var showAddProduct = false
    @State private var productToEdit: ProductSKU?
    @State private var showDeleteAlert = false
    @State private var productToDelete: ProductSKU?

    var body: some View {
        List {
            if !viewModel.filteredProducts.isEmpty {
                filterSection
            }

            ForEach(viewModel.filteredProducts, id: \.id) { product in
                NavigationLink(value: product.id) {
                    ProductRow(product: product)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        productToDelete = product
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        productToEdit = product
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.filteredProducts.isEmpty && viewModel.products.isEmpty {
                EmptyStateView(
                    title: "No Products",
                    subtitle: "Tap + to add your first product to the catalog",
                    icon: "shippingbox"
                )
            } else if viewModel.filteredProducts.isEmpty {
                EmptyStateView(
                    title: "No Results",
                    subtitle: "Try adjusting your search or filters",
                    icon: "magnifyingglass"
                )
            }
        }
        .navigationTitle("Catalog")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchText, prompt: "Search products, SKUs, brands…")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddProduct = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddProduct) {
            ProductFormView(viewModel: viewModel)
        }
        .sheet(item: $productToEdit) { product in
            ProductFormView(viewModel: viewModel, product: product)
        }
        .navigationDestination(for: UUID.self) { productId in
            if let product = viewModel.products.first(where: { $0.id == productId }) {
                ProductDetailView(product: product, viewModel: viewModel)
            }
        }
        .alert("Delete Product?", isPresented: $showDeleteAlert, presenting: productToDelete) { product in
            Button("Delete", role: .destructive) { viewModel.deleteProduct(product) }
            Button("Cancel", role: .cancel) { }
        } message: { product in
            Text("This will permanently delete \"\(product.name)\".")
        }
        .onAppear { viewModel.setup(context: modelContext) }
        .sensoryFeedback(.success, trigger: viewModel.products.count)
    }

    private var filterSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "Brand: \(viewModel.selectedBrand)",
                        isActive: viewModel.selectedBrand != "All",
                        options: viewModel.brands,
                        selection: $viewModel.selectedBrand
                    )
                    FilterChip(
                        title: "Category: \(viewModel.selectedParentCategory)",
                        isActive: viewModel.selectedParentCategory != "All",
                        options: viewModel.parentCategories,
                        selection: Binding(
                            get: { viewModel.selectedParentCategory },
                            set: { viewModel.selectedParentCategory = $0; viewModel.selectedSubcategory = "All" }
                        )
                    )
                    if viewModel.selectedParentCategory != "All" && viewModel.subcategories.count > 1 {
                        FilterChip(
                            title: "Sub: \(viewModel.selectedSubcategory)",
                            isActive: viewModel.selectedSubcategory != "All",
                            options: viewModel.subcategories,
                            selection: $viewModel.selectedSubcategory
                        )
                    }
                }
            }
            .contentMargins(.horizontal, 0)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }
}

struct ProductRow: View {
    let product: ProductSKU

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(product.productName)
                        .font(.body.weight(.medium))
                    if !product.isActive {
                        Image(systemName: "moon.zzz")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 6) {
                    Text(product.sku)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                    if !product.variant.isEmpty {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(product.variant)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !product.parentCategory.isEmpty {
                    HStack(spacing: 4) {
                        Text(product.parentCategory)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        if !product.subcategory.isEmpty {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8))
                                .foregroundStyle(.quaternary)
                            Text(product.subcategory)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }

            Spacer()

            if !product.brand.isEmpty {
                Text(product.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }
}

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let options: [String]
    @Binding var selection: String

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    HStack {
                        Text(option)
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isActive ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isActive ? Color.accentColor : Color(.tertiarySystemFill))
                .clipShape(Capsule())
        }
    }
}
