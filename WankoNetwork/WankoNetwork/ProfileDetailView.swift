//
//  ProfileDetailView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/09.
//

import SwiftUI

import SwiftUI

struct ProfileDetailView: View {
    // あなたのプロフィール情報のための変数やStateをここに追加

    var body: some View {
        VStack {
            // プロフィール写真
            Image(systemName: "person.circle.fill") // ここを実際のプロフィール写真に置き換えてください
                .resizable()
                .scaledToFit()
                .padding()
            
            // その他のプロフィール情報を表示するビュー
            Text("名前")
            Text("住所")
            Text("品種")
            Text("年齢")
            Text("性別")
            Text("その他のメモ")

            Spacer()
        }
        .padding()
        .navigationBarTitle("プロフィール", displayMode: .inline)
    }
}

