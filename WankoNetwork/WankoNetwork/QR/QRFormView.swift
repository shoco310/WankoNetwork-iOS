//
//  QRFormView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/16.
//

import SwiftUI
import CoreData

struct QRFormView: View {
    @ObservedObject var profile: Profile
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode

    @State private var editingDog: Dog? = nil

    init(profile: Profile, editingDog: Dog? = nil) {
        self._profile = ObservedObject(initialValue: profile)
        self.editingDog = editingDog
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if let imageData = profile.photo, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                    }
                }.frame(width: 340, height: 150)
                
                List {
                    Section(header: Text("PROFILE").font(.headline)) {
                        
                        HStack{
                            Image(systemName: "person.fill").foregroundColor(.gray)
                            Text("Name").font(.subheadline).foregroundColor(.gray)
                            TextField("", text: Binding<String>(
                                get: { profile.name ?? "" },
                                set: { profile.name = $0 }
                            ))
                        }
                        
                        HStack{
                            Image(systemName: "location.circle").foregroundColor(.gray)
                            Text("Place").font(.subheadline).foregroundColor(.gray)
                            TextField("", text: Binding<String>(
                                get: { profile.home ?? "" },
                                set: { profile.home = $0 }
                            ))
                        }
                        
                        HStack{
                            Image(systemName: "paperclip").foregroundColor(.gray)
                            Text("Breeds").font(.subheadline).foregroundColor(.gray)
                            TextField("", text: Binding<String>(
                                get: { profile.type ?? "" },
                                set: { profile.type = $0 }
                            ))
                        }
                        
                        HStack{
                            Image(systemName: "calendar").foregroundColor(.gray)
                            Text("Age").font(.subheadline).foregroundColor(.gray)
                            TextField("", value: Binding<Int16>(
                                get: { profile.age },
                                set: { profile.age = $0 }
                            ), formatter: NumberFormatter())
                        }
                        
                        HStack{
                            Image(systemName: "person.crop.circle").foregroundColor(.gray)
                            Text("Gender").font(.subheadline).foregroundColor(.gray)
                            TextField("", text: Binding<String>(
                                get: { profile.gender ?? "" },
                                set: { profile.gender = $0 }
                            ))
                        }
                    }
                    
                    Section(header: Text("DETAIL").font(.headline)) {
                        HStack{
                            Image(systemName: "note.text").foregroundColor(.gray)
                            Text("Memo").font(.subheadline).foregroundColor(.gray)
                            TextField("", text: Binding<String>(
                                get: { profile.memo ?? "" },
                                set: { profile.memo = $0 }
                            ))
                        }
                    }
                }
                .background {
                    Color.white
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                
                Spacer()
                
                Button("保存") {
                    saveDogProfileToDogEntity()
                }
                .padding()
                
            }
            .background(Color("mainColor"))
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.white)
            )
        }
    }
    
    private func saveDogProfileToDogEntity() {
        let dogToSave: Dog
        
        if let dog = editingDog {
            dogToSave = dog
        } else {
            dogToSave = Dog(context: managedObjectContext)
        }
        
        dogToSave.name = profile.name
        dogToSave.type = profile.type
        dogToSave.home = profile.home
        dogToSave.memo = profile.memo
        dogToSave.gender = profile.gender
        dogToSave.age = profile.age
        dogToSave.photo = profile.photo
        
        do {
            try managedObjectContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("保存に失敗しました: \(error)")
        }
    }
}
