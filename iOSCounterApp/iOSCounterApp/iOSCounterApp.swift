//
//  iOSCounterAppApp.swift
//  iOSCounterApp
//
//  Created by HuyNQ on 26/09/2023.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant

class FlutterDependencies: ObservableObject {
    let flutterEngine = FlutterEngine(name: "flutter-engine")
    init() {
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
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
