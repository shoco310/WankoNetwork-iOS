//
//  WankoNetworkApp.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/04/18.
//

import SwiftUI

@main
struct WankoNetworkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            //ContentView()
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
