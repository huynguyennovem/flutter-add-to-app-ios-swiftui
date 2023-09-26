//
//  iOSCounterAppApp.swift
//  iOSCounterApp
//
//  Created by HuyNQ on 26/09/2023.
//

import SwiftUI
import Flutter

class FlutterDependencies: ObservableObject {
    let flutterEngine = FlutterEngine(name: "flutter-engine")
    init() {
        flutterEngine.run()
    }
}

@main
struct iOSCounterApp: App {
    @StateObject var flutterDependencies = FlutterDependencies()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(flutterDependencies)
        }
    }
}
