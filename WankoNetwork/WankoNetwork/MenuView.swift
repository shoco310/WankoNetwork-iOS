//
//  MenuView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/09.
//

import SwiftUI
import CoreData
import CoreImage.CIFilterBuiltins
import Photos


struct MenuView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Profile.entity(), sortDescriptors: []) var profiles: FetchedResults<Profile>
    @State private var showProfileDetail = false
    
    //QR 状態変数の追加
    @State private var isShowingScanner: Bool = false
    @State private var isShowingMyQR: Bool = false
    @State private var scannedProfile: CodableProfile?
    @State private var showForm: Bool = false
    
    
    enum ScannerMode {
        case scanner, myQR
    }
    @State private var currentMode: ScannerMode = .scanner
    
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
                        Image("wanko1")
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
                    //プロフィールアイテム
                    Button(action: {
                        self.showProfileDetail.toggle()
                    }) {
                        Text("Profile").frame(height: 30)
                    }
                    Text("お散歩コース").frame(height: 30)
                    //QRコードのスキャン
                    Button(action: {
                        self.isShowingScanner.toggle()
                    }) {
                        Text("友達になる").frame(height: 30)
                    }
                    
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
            
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color.white)
        .transition(.move(edge: .leading))
        .fullScreenCover(isPresented: $showProfileDetail) {
            ProfileDetailView(profile: profiles.first ?? defaultProfile())
        }
        
        .sheet(isPresented: $isShowingScanner, onDismiss: resetSheetStates) {
            VStack {
                if self.currentMode == .scanner {
                    QRScannerView { code in
                        self.scannedProfile = decodeProfile(from: code)
                        self.showForm = true
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            VStack {
                                Button(action: {
                                    self.isShowingScanner = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                                .background(Color.clear)
                                Spacer()
                            }
                        }
                    )
                    Button(action: {
                        self.currentMode = .myQR
                    }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                                .foregroundColor(.primary)
                            Text("マイQRコード")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(#colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)), lineWidth: 1)
                        )
                    }
                    Text("QRコードをスキャンして友達の情報を読み込みましょう。")
                } else if self.currentMode == .myQR {
                    if let myProfile = profiles.first {
                        VStack {
                            let qrImage = generateQRCode(from: ProfileEncoder.encodeProfile(myProfile))
                            Image(uiImage: qrImage)
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding()
                            Text("マイQRコードを使って、友だちを追加しましょう")
                                .frame(width: 200, height: 50)
                            HStack {
                                Button(action: {
                                    self.currentMode = .scanner
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left")
                                            .foregroundColor(.primary)
                                        Text("戻る")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(10)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(#colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)), lineWidth: 1)
                                    )
                                }
                                
                                Button(action: {
                                    saveImageToPhotoAlbum(qrImage)
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                            .foregroundColor(.primary)
                                        Text("保存")
                                            .foregroundColor(.primary)
                                    }
                                    .padding(10)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(#colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    } else {
                        Text("No profile data to encode.")
                        Button("戻る") {
                            self.currentMode = .scanner
                        }
                    }
                }
            }
        }
        
        .fullScreenCover(isPresented: $showForm) {
            if let scannedProfile = self.scannedProfile {
                if let existingProfile = self.createProfileFromCodableProfile(scannedProfile) {
                    QRFormView(profile: existingProfile)
                }
            }
        }
    }
    func resetSheetStates() {
        self.currentMode = .scanner
        self.scannedProfile = nil
        self.showForm = false
    }
    func defaultProfile() -> Profile {
        let profile = Profile(context: managedObjectContext)
        profile.name = "Default Name"
        return profile
    }
    
    struct CodableProfile: Codable {
        var name: String?
        var home: String?
        var type: String?
        var age: Int16?
        var gender: String?
        var memo: String?
        var photo: String?
    }
    
    func createProfileFromCodableProfile(_ codableProfile: CodableProfile) -> Profile? {
        let profile = Profile(context: managedObjectContext)
        profile.name = codableProfile.name
        profile.home = codableProfile.home
        profile.type = codableProfile.type
        profile.age = codableProfile.age ?? 0
        profile.gender = codableProfile.gender
        profile.memo = codableProfile.memo
        profile.photo = Data(base64Encoded: codableProfile.photo ?? "")
        return profile
    }
    
    func decodeProfile(from string: String) -> CodableProfile? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        return try? decoder.decode(CodableProfile.self, from: data)
    }
    // QRコード保存
    func saveImageToPhotoAlbum(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if success {
                // 保存成功時の処理
                print("Successfully saved image to Photo Library.")
            } else {
                // エラー処理
                print("Error saving photo: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
}
public func generateQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let data = string.data(using: String.Encoding.utf8)
    filter.setValue(data, forKey: "inputMessage")
    
    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
    }
    
    return UIImage(systemName: "xmark.circle") ?? UIImage()
}


