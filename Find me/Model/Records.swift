//
//  Records.swift
//  Find me
//
//  Created by Евгений Полтавец on 20/12/2024.
//

import Foundation

struct Records: Codable, Identifiable {
    let id: String
    let title: String?
    let date: Date?
    let audioURL: String?

    var recordsModel: [String : Any] {
        var records = [String: Any]()
        records["id"] = self.id
        records["date"] = self.date
        return records
    }
}
