//
//  AddDogView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/08.
//

import SwiftUI

struct DogFormView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var name: String
    @State private var type: String
    @State private var home: String
    @State private var memo: String
    @State private var photo: UIImage?
    
    @State private var image: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    
    var editingDog: Dog?  // 編集のための犬のオブジェクト
    
    init(dog: Dog? = nil) {
        _name = State(initialValue: dog?.name ?? "")
        _type = State(initialValue: dog?.type ?? "")
        _home = State(initialValue: dog?.home ?? "")
        _memo = State(initialValue: dog?.memo ?? "")
        if let data = dog?.photo {
            _photo = State(initialValue: UIImage(data: data))
        } else {
            _photo = State(initialValue: nil)
        }
        self.editingDog = dog
    }
    
    var body: some View {
        VStack {
            if let photo = photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
            }
            Button(action: {
                self.sourceType = .photoLibrary
                self.isImagePickerPresented = true
            }) {
                Image(systemName: "photo.on.rectangle")
                Text("写真を選択")
            }
            
            Button(action: {
                self.sourceType = .camera
                self.isImagePickerPresented = true
            }) {
                Image(systemName: "camera")
                Text("写真を撮影")
            }
            TextField("名前", text: $name)
            TextField("種類", text: $type)
            TextField("住まい", text: $home)
            TextField("メモ", text: $memo)
            
            Button(action: saveDog) {
                Text(editingDog == nil ? "追加" : "更新")
            }
            .padding()
            .background(Color("mainColor"))
            .foregroundColor(.white)
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(sourceType: self.sourceType, selectedImage: self.$photo)
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
        dogToSave.photo = photo?.pngData()
        
        do {
            try managedObjectContext.save()
        } catch {
            print("保存に失敗しました: \(error)")
        }
    }
}
