//
//  Repo.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/06.
//

import Foundation

struct Repo: Identifiable {
    var id: Int
    var name: String
    var owner: User
    var description: String
    var stargazersCount: Int
}
