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
    var dog: Dog
    
    var defaultDogImage: UIImage {
        UIImage(named: "defaultDogImage") ?? UIImage()
    }
    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: UIImage(data: dog.photo ?? Data()) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                Text(dog.name ?? "")
                Text(dog.home ?? "")
                Text(dog.type ?? "")
                Text(dog.memo ?? "")
                
                //            if let thumbnails = dog.thumbnails?.allObjects as? [Thumbnail], !thumbnails.isEmpty {
                //                ScrollView {
                //                    ForEach(thumbnails, id: \.self) { thumbnail in
                //                        if let imageData = thumbnail.imageData, let uiImage = UIImage(data: imageData) {
                //                            Image(uiImage: uiImage)
                //                                .resizable()
                //                                .scaledToFit()
                //                        } else {
                //                            // 画像がない場合の代替コンテンツ
                //                            Image(systemName: "photo")
                //                                .resizable()
                //                                .scaledToFit()
                //                                .foregroundColor(.gray)
                //                        }
                //                    }
                //                }
                //            }
            }
            .navigationBarTitle(dog.name ?? "名前不明", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.showActionSheet = true
            }) {
                Image(systemName: "ellipsis.circle.fill")
            }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("オプション"), buttons: [
                        .default(Text("編集"), action: {
                            self.showEditView = true
                        }),
                        .destructive(Text("削除"), action: deleteDog),
                        .cancel()
                    ])
                }
            )
        }
        .sheet(isPresented: $showEditView) {
            DogFormView(dog: dog)
       }
        
    }
    func deleteDog() {
            self.managedObjectContext.delete(dog)
            do {
                try self.managedObjectContext.save()
            } catch {
                print("削除中のエラー: \(error)")
            }
            // この後、前の画面に戻る動作が必要かもしれません。
        }
}
