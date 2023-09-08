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
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
