//
//  Repo.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/06.
//

import Foundation

struct Repo: Identifiable, Codable {
    var id: Int
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case description
        case stargazersCount = "stargazers_count"
    }
}
