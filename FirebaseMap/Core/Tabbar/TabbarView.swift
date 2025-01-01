//
//  TabbarView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-17.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    @State var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Products", systemImage: "cart", value: 0) {
                NavigationStack {
                    ProductsView()
                }
            }
            
            Tab("Favourites", systemImage: "heart", value: 1) {
                NavigationStack {
                    FavouritesView(selectedTab: $selectedTab)
                }
            }
            
            Tab("Profile", systemImage: "star.fill", value: 2) {
                NavigationStack {
                    ProfileView(showSignInView: $showSignInView)
                }
            }
        }
    }
}

#Preview {
    TabbarView(showSignInView: .constant(false))
}
