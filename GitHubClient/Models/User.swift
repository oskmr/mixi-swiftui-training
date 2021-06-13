//
//  User.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/06.
//

import Foundation

struct User: Codable {
    var name: String

    private enum CodingKeys: String, CodingKey {
        case name = "login"
    }
}
