//
//  ProductsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-12.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProductsViewModel: ObservableObject {
    
    //you should filter it on data base, before dowloadind
    @Published private(set) var products: [Product] = []
    @Published var selectedFilter: FilterOption = .noFilter
    @Published var selectedCategory: CategoryOption? = nil
    
    private var lastDocument: DocumentSnapshot? = nil
    
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
        if option != .noSorting {
            self.selectedCategory = option
        } else {
            self.selectedCategory = nil
        }
        
        self.products = []
        
        self.lastDocument = nil
        
        self.getProducts()
    }
    
    func getProducts() {
        PerformanceManager.shared.startTrace(name: "get_products")
        
        Task {
            PerformanceManager.shared.setValueForTrace(value: "start downloading", traceName: "get_products", forAttribute: "func_speed")
            let (newProducts, newDocument) = try await ProductsManager.shared.getAllProducts(descending: selectedFilter.priceDescending, category: selectedCategory?.rawValue, count: 10, lastDocument: lastDocument)
            PerformanceManager.shared.setValueForTrace(value: "end downloading", traceName: "get_products", forAttribute: "func_speed")
            if let newDocument {
                self.lastDocument = newDocument
            }
            self.products.append(contentsOf: newProducts)
            PerformanceManager.shared.setValueForTrace(value: "append to array", traceName: "get_products", forAttribute: "func_speed")
            
            PerformanceManager.shared.stopTrace(name: "get_products")
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        
        self.products = []
        self.lastDocument = nil
        
        self.getProducts()
    }
    
    func addUserFavouriteProduct(productId: Int) {
        Task {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.addUserFavouriteProduct(userId: authUser.uid, productId: productId)
        }
    }
    
//    func getProductsCount() {
//        Task {
//            let count = try await ProductsManager.shared.getAllProductCount()
//            print(count)
//        }
//    }
    
//    func getProductsByRating() {
//        Task {
////            let newArr = try await ProductsManager.shared.getProductsByRating(limit: 3, lastRating: self.products.last?.rating)
//            
//            let (newArr, document) = try await  ProductsManager.shared.getProductsByRating(limit: 3, last: lastDocument)
//            
//            self.lastDocument = document
//            self.products.append(contentsOf: newArr)
//        }
//    }

}

struct ProductsView: View {
    
    @StateObject private var vm = ProductsViewModel()
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductsCellView(product: product)
                    .contextMenu {
                        Button("Add To Favoutite") {
                            vm.addUserFavouriteProduct(productId: product.id)
                        }
                    }
                
                if product == vm.products.last {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        vm.getProducts()
                    }
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
            //vm.getProductsCount()
        }
        
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
