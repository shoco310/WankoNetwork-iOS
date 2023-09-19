//
//  ProfileEditView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/09.
//

import SwiftUI
import CoreData

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var profile: Profile?
    @Binding var isEditing: Bool
    
    @State private var showActionSheet = false
    @State private var isImagePickerShown = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Profile attributes for editing
    @State private var name: String = ""
    @State private var home: String = ""
    @State private var type: String = ""
    @State private var photo: UIImage? = nil
    @State private var age: Int16 = 0
    @State private var ageString: String = ""
    @State private var gender: String = ""
    @State private var memo: String = ""
    
    @State private var editingProfile: Profile?
    
    init(profile: Binding<Profile?>, isEditing: Binding<Bool>) {
        self._profile = profile
        self._isEditing = isEditing
        self.editingProfile = profile.wrappedValue
    }
    
    var body: some View {
        VStack {
            ZStack{
                ZStack {
                    if let uiImage = photo ?? (profile?.photo.flatMap(UIImage.init(data:))) {
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
                }
                .frame(width: 340, height: 150)
                ZStack(alignment: .top){
                    Button(action: {
                        showActionSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                }.frame(width: 340, height: 100)
            }
            Form{
                Section(header: Text("PROFILE").font(.headline)) {
                    
                    HStack{
                        Image(systemName: "person.fill").foregroundColor(.gray)
                        TextField("Name", text: $name)
                        
                    }
                    HStack{
                        Image(systemName: "location.circle").foregroundColor(.gray)
                        TextField("Place", text: $home)
                        
                    }
                    HStack{
                        Image(systemName: "paperclip").foregroundColor(.gray)
                        TextField("Breeds", text: $type)
                        
                    }
                    
                    HStack{
                        Image(systemName: "calendar").foregroundColor(.gray)
                        TextField("Age", text: $ageString)
                            .onChange(of: ageString) { newValue in
                                if let intValue = Int16(newValue) {
                                    editingProfile?.age = intValue
                                }
                            }
                    }
                    
                    HStack{
                        Image(systemName: "person.crop.circle").foregroundColor(.gray)
                        TextField("Gender", text: $gender)
                        
                    }
                    
                }
                Section(header: Text("DETAIL").font(.headline)) {
                    HStack{
                        Image(systemName: "note.text").foregroundColor(.gray)
                        TextField("Memo", text: $memo)
                        
                    }
                    
                }
                
            }
            .background {
                Color.white
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            Spacer()
            
            Button(action: saveProfile) {
                Text("Update")
                    .padding()
                    .background(Color("mainColor"))
                    .cornerRadius(10)
                    .frame(width: 200, height: 50)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            
        }
        .background(Color("mainColor"))
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("写真を選択"), buttons: [
                .default(Text("写真ライブラリ"), action: {
                    self.sourceType = .photoLibrary
                    self.isImagePickerShown = true
                }),
                .default(Text("カメラ"), action: {
                    self.sourceType = .camera
                    self.isImagePickerShown = true
                }),
                .cancel()
            ])
        }
        .sheet(isPresented: $isImagePickerShown) {
            ImagePicker(sourceType: self.sourceType, selectedImage: self.$photo)
        }
        
        .onAppear {
            self.editingProfile = profile
            if let profileData = editingProfile {
                name = profileData.name ?? ""
                home = profileData.home ?? ""
                type = profileData.type ?? ""
                memo = profileData.memo ?? ""
                ageString = "\(profileData.age)"
                gender = profileData.gender ?? ""
            }
        }
        
    }
    
    func saveProfile() {
        print("editingProfile: \(String(describing: editingProfile))")
        let profileToSave: Profile
        
        if let profile = editingProfile {
            profileToSave = profile
        } else {
            deleteExistingProfiles()
            profileToSave = Profile(context: managedObjectContext)
        }
        managedObjectContext.performAndWait {
            profileToSave.name = name
            profileToSave.home = home
            profileToSave.type = type
            profileToSave.memo = memo
            profileToSave.gender = gender
            saveProfilePhoto()  // 写真を保存
            
            if let intAge = Int16(ageString) {
                profileToSave.age = intAge
            } else {
                print("年齢の入力が不正です")
                return
            }
            
            print("Saving context...")
            do {
                try managedObjectContext.save()
                presentationMode.wrappedValue.dismiss()
                print("Context saved successfully!")
            } catch {
                print("保存に失敗しました: \(error)")
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let rect = CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func saveProfilePhoto() {
        print("saveProfilePhoto called")
        if let image = photo {
            let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 250, height: 250))
            if let imageData = resizedImage.jpegData(compressionQuality: 0.6) {
                editingProfile?.photo = imageData
            }
        }
    }

    func deleteExistingProfiles() {
        let fetchRequest: NSFetchRequest<Profile> = Profile.fetchRequest()
        do {
            let existingProfiles = try managedObjectContext.fetch(fetchRequest)
            for profile in existingProfiles {
                managedObjectContext.delete(profile)
            }
        } catch {
            print("既存のProfileのフェッチに失敗: \(error)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                print("Image selected and set to parent.selectedImage")
            }
            
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
