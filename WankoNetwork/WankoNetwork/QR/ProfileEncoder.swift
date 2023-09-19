//
//  ProfileEncoder.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/16.
//
import CoreData

struct ProfileEncoder {
    static func encodeProfile(_ profile: Profile) -> String {
        let codableProfile = CodableProfile(
            name: profile.name,
            home: profile.home,
            type: profile.type,
            age: profile.age,
            gender: profile.gender,
            memo: profile.memo,
            photo: profile.photo?.base64EncodedString()
        )
        let encoder = JSONEncoder()
        let data = try? encoder.encode(codableProfile)
        return String(data: data!, encoding: .utf8) ?? ""
    }

    static func decodeProfile(from string: String, using context: NSManagedObjectContext) -> Profile? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8),
              let codableProfile = try? decoder.decode(CodableProfile.self, from: data) else {
            return nil
        }
        let profile = Profile(context: context)
        profile.name = codableProfile.name
        profile.home = codableProfile.home
        profile.type = codableProfile.type
        profile.age = codableProfile.age ?? 0
        profile.gender = codableProfile.gender
        profile.memo = codableProfile.memo
        profile.photo = Data(base64Encoded: codableProfile.photo ?? "")
        return profile
    }
}

struct CodableProfile: Codable {
    var name: String?
    var home: String?
    var type: String?
    var age: Int16?
    var gender: String?
    var memo: String?
    var photo: String?  // photo is stored as a base64 string
}

