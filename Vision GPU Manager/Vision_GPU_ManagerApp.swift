//
//  Vision_GPU_ManagerApp.swift
//  Vision GPU Manager
//
//  Created by Phoom Punpeng on 8/7/2565 BE.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Vision_GPU_ManagerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LoginView()
//            GPUView()
        }
    }
}
