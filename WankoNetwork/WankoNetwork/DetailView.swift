//
//  DetailView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var showActionSheet = false
    @State var showEditView = false
    @ObservedObject var dog: Dog
    
    
    var defaultDogImage: UIImage {
        UIImage(named: "defaultDogImage") ?? UIImage()
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                    Image(uiImage: UIImage(data: dog.photo ?? Data()) ?? UIImage(named: "wanko-sample")!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipShape(Rectangle())
               
                
                List{
                    Section(header: Text("PROFILE").font(.headline)) {
                        
                        HStack{
                            Image(systemName: "person.fill").foregroundColor(.gray)
                            Text("Name").font(.subheadline).foregroundColor(.gray)
                            Text(dog.name ?? "")
                            
                        }
                        HStack{
                            Image(systemName: "location.circle").foregroundColor(.gray)
                            Text("Place").font(.subheadline).foregroundColor(.gray)
                            Text(dog.home ?? "")
                            
                        }
                        HStack{
                            Image(systemName: "paperclip").foregroundColor(.gray)
                            Text("Breeds").font(.subheadline).foregroundColor(.gray)
                            Text(dog.type ?? "")
                            
                        }
                        
                        HStack{
                            Image(systemName: "calendar").foregroundColor(.gray)
                            Text("Age").font(.subheadline).foregroundColor(.gray)
                            Text("\(dog.age)")
                            
                        }
                        HStack{
                            Image(systemName: "person.crop.circle").foregroundColor(.gray)
                            Text("Gender").font(.subheadline).foregroundColor(.gray)
                            Text(dog.gender ?? "")
                            
                        }
                        
                    }
                    Section(header: Text("DETAIL").font(.headline)) {
                        HStack{
                            Image(systemName: "note.text").foregroundColor(.gray)
                            Text("Memo").font(.subheadline).foregroundColor(.gray)
                            Text(dog.memo ?? "")
                            
                        }
                        
                    }
                    
                }
                .background {
                    Color.white
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                Spacer()
                
                
                //                if let thumbnails = dog.thumbnails?.allObjects as? [Thumbnail], !thumbnails.isEmpty {
                //                    ScrollView {
                //                        ForEach(thumbnails, id: \.self) { thumbnail in
                //                            if let imageData = thumbnail.imageData, let uiImage = UIImage(data: imageData) {
                //                                Image(uiImage: uiImage)
                //                                    .resizable()
                //                                    .scaledToFit()
                //                            } else {
                //                                // 画像がない場合の代替コンテンツ
                //                                Image(systemName: "photo")
                //                                    .resizable()
                //                                    .scaledToFit()
                //                                    .foregroundColor(.gray)
                //                            }
                //                        }
                //                    }
                //                }
                
                Spacer()
                // ボタンを追加
                Button(action: {
                    self.showActionSheet = true
                }) {
                    Text("Edit")
                    //Image(systemName: "ellipsis.vertical")
                        .padding()
                        .background(Color("mainColor"))
                        .cornerRadius(10)
                        .frame(width: 200, height: 50)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Option"), buttons: [
                        .default(Text("Edit"), action: {
                            self.showEditView = true
                        }),
                        .destructive(Text("Delete"), action: deleteDog),
                        .cancel()
                    ])
                }
            }
            .background(Color("mainColor"))
        }
        
        .accentColor(.white)
        .sheet(isPresented: $showEditView) {
            DogFormView(dog: dog)
        }
        .background(Color("mainColor"))
        
    }
    func deleteDog() {
        self.managedObjectContext.delete(dog)
        do {
            try self.managedObjectContext.save()
        } catch {
            print("削除中のエラー: \(error)")
        }
    }
}
