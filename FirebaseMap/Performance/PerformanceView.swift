//
//  PerformanceView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2025-01-21.
//

import SwiftUI
import FirebasePerformance

final class PerformanceManager {
    
    static let shared = PerformanceManager()
    private init() {}
    
    private var traces: [String:Trace] = [:]
    
    func startTrace(name: String) {
        let trace = Performance.startTrace(name: name)
        traces[name] = trace
    }
    
    func setValueForTrace(value: String, traceName: String, forAttribute: String) {
        guard let trace = traces[traceName] else { return }
        
        trace.setValue(value, forAttribute: forAttribute)
    }
    
    func stopTrace(name: String) {
        guard let trace = traces[name] else { return }
        trace.stop()
        traces.removeValue(forKey: name)
    }
    
}

struct PerformanceView: View {
    
    @State private var title: String = "Some Title"
    
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                PerformanceManager.shared.startTrace(name: "performance_screen_time")
                
                configure()
                downloadProductsAndUploadToFirebase()
            }
            .onDisappear {
                PerformanceManager.shared.stopTrace(name: "performance_screen_time")
            }
    }
    
    private func configure() {
        
        PerformanceManager.shared.startTrace(name: "performance_view_loading")
        PerformanceManager.shared.setValueForTrace(value: title, traceName: "performance_view_loading", forAttribute: "title_text")
        
        Task {
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            PerformanceManager.shared.setValueForTrace(value: "started downloading", traceName: "performance_view_loading", forAttribute: "func_state")
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            PerformanceManager.shared.setValueForTrace(value: "continued downloading", traceName: "performance_view_loading", forAttribute: "func_state")
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            PerformanceManager.shared.setValueForTrace(value: "finished downloading", traceName: "performance_view_loading", forAttribute: "func_state")
            
            PerformanceManager.shared.stopTrace(name: "performance_view_loading")
        }
    }
    
    func downloadProductsAndUploadToFirebase() {
        
        let urlString = "https://dummyjson.com/products"
        
        guard let url = URL(string: urlString), let metric = HTTPMetric(url: url, httpMethod: .get) else { return }
        metric.start()
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let response = response as? HTTPURLResponse {
                    metric.responseCode = response.statusCode
                }
                
                metric.stop()
                print("SUCCESS")
            } catch {
                print(error)
                metric.stop()
            }
        }
    }
    
}

#Preview {
    PerformanceView()
}
