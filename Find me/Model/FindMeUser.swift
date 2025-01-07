//
//  Person.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import Foundation
import FirebaseFirestore

struct FindMeUser: Codable, Identifiable {
    
    let id: String
    let email: String?
    var name: String?
    var phone: String?
    var friendPhone: String?
    let records: [String]
    var longitude: Double?
    var latitude: Double?
    var isOn: Bool
    var date: Date

    var personModel: [String : Any] {
        var person = [String: Any]()
        person["id"] = self.id
        person["email"] = self.email
        person["name"] = self.name
        person["phone"] = self.phone
        person["friendPhone"] = self.friendPhone
        person["records"] = self.records
        person["longitude"] = self.longitude
        person["latitude"] = self.latitude
        person["isOn"] = self.isOn
        person["date"] = self.date
        return person
    }
    
    static func personModel() -> FindMeUser {
        .init(id: "", email: "", name: "", phone: "", friendPhone: "",records: [], longitude: 0.0, latitude: 0.0, isOn: false, date: Date())
    }
}
