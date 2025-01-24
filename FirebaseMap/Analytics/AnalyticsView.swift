//
//  AnalyticsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2025-01-24.
//

import SwiftUI
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() { }
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, property: String) {
        //AnalyticsEventSignUp
        Analytics.setUserProperty(value, forName: property)
    }
    
}

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 25) {
            Button {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_ButtonClick")
            } label: {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 5)
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 50)
                    .overlay {
                        Text("Click Me")
                            .padding()
                    }
            }
            
            Button {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_SecondaryButtonClick", params: [
                    "screen_title" : "Hello World!"
                ])
            } label: {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 5)
                    .foregroundColor(.blue)
                    .frame(width: 150, height: 50)
                    .overlay {
                        Text("Click Me Too")
                            .padding()
                    }
            }
            .analyticsScreen(name: "AnalyticsView")

        }
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Appear")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Dissappear")
            
            AnalyticsManager.shared.setUserId(userId: "ABC123")
            
            AnalyticsManager.shared.setUserProperty(value: true.description, property: "user_is_premium")
        }
    }
}

#Preview {
    AnalyticsView()
}
