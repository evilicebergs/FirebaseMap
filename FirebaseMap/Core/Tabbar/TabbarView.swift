//
//  TabbarView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-17.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            Tab("Products", systemImage: "cart") {
                NavigationStack {
                    ProductsView()
                }
            }
            Tab("Profile", systemImage: "star.fill") {
                NavigationStack {
                    ProfileView(showSignInView: $showSignInView)
                }
            }
            
            Tab("Favourites", systemImage: "heart") {
                NavigationStack {
                    FavouritesView()
                }
            }
        }
    }
}

#Preview {
    TabbarView(showSignInView: .constant(false))
}
