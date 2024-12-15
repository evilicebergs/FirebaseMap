//
//  ProductsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-12.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    
    //you should filter it on data base, before dowloadind
    @Published private(set) var products: [Product] = []
    @Published var selectedFilter: FilterOption = .noFilter
    @Published var selectedCategory: CategoryOption? = nil
    
//    func getAllProducts() async throws {
//        products = try await ProductsManager.shared.getAllProducts()
//    }
    
    enum FilterOption: String, CaseIterable {
        case noFilter = "None"
        case priceHigh = "From High To Low"
        case proceLow = "From Low To High"
        
        var priceDescending: Bool? {
            switch self {
            case .noFilter:
                return nil
            case .priceHigh:
                return true
            case .proceLow:
                return false
            }
        }
    }
    
    enum CategoryOption: String, CaseIterable {
        case noSorting = "No Sorting"
        case beauty
        case fragrances
        case furniture
        case groceries
    }
    
    func categorySelected(option: CategoryOption) async throws {
//        switch option {
//        case .beauty, .forniture, .fragrances, .groceries:
//            products = try await ProductsManager.shared.getAllProductsForCategory(category: option.rawValue)
//        case .noSorting:
//            products = try await ProductsManager.shared.getAllProducts()
//        }
        
        if option != .noSorting {
            self.selectedCategory = option
        } else {
            self.selectedCategory = nil
        }
        
        self.getProducts()
    }
    
    func getProducts() {
        Task {
            self.products = try await ProductsManager.shared.getAllProducts(descending: selectedFilter.priceDescending, category: selectedCategory?.rawValue)
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
//        switch option {
//        case .priceHigh:
//            products = try await ProductsManager.shared.
//            ge
//        case .proceLow:
//            products = try await ProductsManager.shared.getAllProductsSortedByPrice(descending: false)
//        case .noFilter:
//            products = try await ProductsManager.shared.getAllProducts()
//        }
        
        self.selectedFilter = option
        self.getProducts()
    }

}

struct ProductsView: View {
    
    @StateObject private var vm = ProductsViewModel()
    
    var body: some View {
        ZStack {
            List {
                ForEach(vm.products) { product in
                    ProductsCellView(product: product)
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Menu("Filter: \(vm.selectedFilter.rawValue)") {
                    ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { filterOption in
                        Button(filterOption.rawValue) {
                            Task {
                                try? await vm.filterSelected(option: filterOption)
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Category: \(vm.selectedCategory?.rawValue.capitalized ?? "None")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { filterOption in
                        Button(filterOption.rawValue.capitalized) {
                            Task {
                                try? await vm.categorySelected(option: filterOption)
                            }
                        }
                    }
                }
            }
        })
        .navigationTitle("Products")
        .onAppear {
            vm.getProducts()
        }
        
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
