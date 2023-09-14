//
//  ProfileDetailView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/09.
//

// ProfileDetailView.swift
import SwiftUI
import CoreData

struct ProfileDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @State var showActionSheet = false
    @State var showEditView = false
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    
    @State private var isImagePickerShown = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var photo: UIImage?
    @State private var isEditing = false
    
    @ObservedObject var profile: Profile
    
    var profileBinding: Binding<Profile?> {
        Binding<Profile?>(
            get: { self.profile },
            set: { newValue in
            }
        )
    }
    
    var body: some View {
        NavigationView {
            if isEditing {
                ProfileEditView(profile: profileBinding, isEditing: $isEditing)
                    .navigationBarItems(
                        leading: Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }.foregroundColor(.white),
                        trailing: Button("Cancel") {
                            do {
                                try managedObjectContext.save()
                                isEditing.toggle()
                            } catch {
                                print("Failed to save changes: \(error)")
                            }
                        }.foregroundColor(.white)
                    )
            } else {
                // Details view code here
                VStack {
                    ZStack{
                        ZStack(){
                            // Image Picker Logic for photo
                            if let data = profile.photo, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 150, height: 150)
                                    .onTapGesture {
                                        showActionSheet.toggle()
                                    }
                            } else {
                                Image("wanko1") // Default image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                                    .onTapGesture {
                                        showActionSheet.toggle()
                                    }
                            }
                        }.frame(width: 340, height: 150)
                        
                    }
                    
                    List{
                        Section(header: Text("PROFILE").font(.headline)) {
                            
                            HStack{
                                Image(systemName: "person.fill").foregroundColor(.gray)
                                Text("Name").font(.subheadline).foregroundColor(.gray)
                                Text(profile.name ?? "Unknown")
                            }
                            HStack{
                                Image(systemName: "location.circle").foregroundColor(.gray)
                                Text("Place").font(.subheadline).foregroundColor(.gray)
                                Text(profile.home ?? "Unknown")
                            }
                            HStack{
                                Image(systemName: "paperclip").foregroundColor(.gray)
                                Text("Breeds").font(.subheadline).foregroundColor(.gray)
                                Text(profile.type ?? "Unknown")
                            }
                            HStack{
                                Image(systemName: "calendar").foregroundColor(.gray)
                                Text("Age").font(.subheadline).foregroundColor(.gray)
                                Text(profile.age != nil ? "\(profile.age)" : "Unknown")
                            }
                            HStack{
                                Image(systemName: "person.crop.circle").foregroundColor(.gray)
                                Text("Gender").font(.subheadline).foregroundColor(.gray)
                                Text(profile.gender ?? "Unknown")
                            }
                            
                        }
                        Section(header: Text("DETAIL").font(.headline)) {
                            HStack{
                                Image(systemName: "note.text").foregroundColor(.gray)
                                Text("Memo").font(.subheadline).foregroundColor(.gray)
                                Text(profile.memo ?? "Unknown")
                            }
                            
                        }
                        
                    }
                    .background {
                        Color.white
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    Spacer()
                }
                .background(Color("mainColor"))
                
                .navigationBarItems(
                    leading:
                
                    // 1st Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back")
                            .foregroundColor(.white)
                    },
                    trailing:
                    // 2nd Button
                    Button(action: {
                        self.showActionSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                    }
                
                )

                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Option"), buttons: [
                        .default(Text("Edit"), action: {
                            self.isEditing = true // Editを選択したときの動作を設定
                        }),
                        .destructive(Text("Delete"), action: {
                            deleteProfile() // Deleteを選択したときの動作を設定
                        }),
                        .cancel()
                    ])
                }
                
                
                
            }
        }
    }
    func deleteProfile() {
        self.managedObjectContext.delete(profile)
        do {
            try self.managedObjectContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("削除中のエラー: \(error)")
        }
    }
    
    
}


