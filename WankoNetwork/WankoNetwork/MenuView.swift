//
//  MenuView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/09.
//

import SwiftUI
import CoreData

struct MenuView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    
    @State private var showProfileDetail = false
    
    var body: some View {
        VStack {
            if let profile = profiles.first {
                VStack(alignment: .leading){
                    HStack {
                        Image(uiImage: UIImage(data: profile.photo ?? Data()) ?? UIImage(named: "wanko1")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            . offset(x:-20)
                        Text(profile.name ?? "")
                    }
                }
                
            } else {
                VStack(alignment: .leading){
                    HStack {
                        Image("wanko1") // Assuming you have this image in assets
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .offset(x:-20)
                        Text("Guest")
                    }.frame(height: 60)
                }
            }
            
            List {
                
                Section {
                    // プロフィールアイテム
                    Button(action: {
                        self.showProfileDetail.toggle()
                    }) {
                        Text("Profile").frame(height: 30)
                    }
                    Text("お散歩コース").frame(height: 30)
                    Text("友達になる").frame(height: 30)
                    
                } header: {
                    Text("My menu")
                }
                Section {
                    Text("About App").frame(height: 30)
                    Text("Policy").frame(height: 30)
                } header: {
                    Text("System")
                }
            }
            
            .listStyle(GroupedListStyle())
            
            //Spacer()
            //.padding()
            //.frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color.white)
        .transition(.move(edge: .leading))
        
        .fullScreenCover(isPresented: $showProfileDetail) {
            ProfileDetailView(profile: profiles.first ?? defaultProfile())
        }
    }
    func defaultProfile() -> Profile {
        let profile = Profile(context: managedObjectContext)
        profile.name = "Guest"
        // 他のデフォルトの属性も設定できます。
        return profile
    }
   
}
