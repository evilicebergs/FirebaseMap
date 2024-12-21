//
//  OnFirstAppearViewModifier.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-21.
//

import Foundation
import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didAppear {
                    perform?()
                    didAppear = true
                }
            }
    }
    
}

extension View {
    
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: {
            perform?()
        }))
    }
    
}
