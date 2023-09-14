//
//  MainTabView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/15.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            MenuView()
                .tabItem {
                    Label("Menu", systemImage: "gear")
                }
        }
    }
}
