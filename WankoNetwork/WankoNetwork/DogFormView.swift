//
//  AddDogView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//

import SwiftUI

struct DogFormView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var home: String = ""
    @State private var type: String = ""
    @State private var photo: UIImage? = nil
    @State private var age: Int16 = 0
    @State private var ageString: String = ""
    @State private var gender: String = ""
    @State private var memo: String = ""
    
    
    @State private var image: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showActionSheet: Bool = false
    @State private var isImagePickerShown: Bool = false
    
    var editingDog: Dog?  // 編集のための犬のオブジェクト
    
    init(dog: Dog? = nil) {
        _name = State(initialValue: dog?.name ?? "")
        _type = State(initialValue: dog?.type ?? "")
        _home = State(initialValue: dog?.home ?? "")
        _memo = State(initialValue: dog?.memo ?? "")
        _gender = State(initialValue: dog?.gender ?? "")
        _age = State(initialValue: dog?.age ?? 0)
        _ageString = State(initialValue: "\(dog?.age ?? 0)")
        
        if let data = dog?.photo {
            _photo = State(initialValue: UIImage(data: data))
        } else {
            _photo = State(initialValue: nil)
        }
        self.editingDog = dog
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    ZStack {
                        if let photo = photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipShape(Rectangle())
                        } else {
                            Image("wanko-sample")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipShape(Rectangle())
                        }
                        Button(action: {
                            self.showActionSheet = true
                        }) {
                            Image(systemName: "plus")
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .background(Color.black)
                        }
                    }
                    List{
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
                                Image(systemName: "calendar")
                                TextField("Age", text: $ageString)
                                    .onChange(of: ageString) { newValue in
                                        if let intValue = Int16(newValue) {
                                            editingDog?.age = intValue
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
                    .padding()
                    .background {
                        Color.white
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    Spacer()
                    
                    
                    Button(action: saveDog) {
                        Text(editingDog == nil ? "Add" : "Update")
                    }
                    .padding()
                    .background(Color("mainColor"))
                    .cornerRadius(10)
                    .frame(width: 200, height: 50)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    
                    Spacer()
                    
                }
            }
            .background(Color("mainColor"))
            
        }.background(Color("mainColor"))
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
        
    }
    func showImagePicker() {
        self.isImagePickerShown = true
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
                }
                
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    
    func saveDog() {
        let dogToSave: Dog
        
        if let dog = editingDog {
            dogToSave = dog
        } else {
            dogToSave = Dog(context: managedObjectContext)
        }
        
        dogToSave.name = name
        dogToSave.type = type
        dogToSave.home = home
        dogToSave.memo = memo
        dogToSave.gender = gender
        dogToSave.photo = photo?.pngData()
        if let intAge = Int16(ageString) {
                dogToSave.age = intAge
            } else {
                print("年齢の入力が不正です")
                return
            }
        
        do {
            try managedObjectContext.save()
            
            presentationMode.wrappedValue.dismiss()  // 保存後に画面を閉じる
            
        } catch {
            print("保存に失敗しました: \(error)")
        }
    }
}
