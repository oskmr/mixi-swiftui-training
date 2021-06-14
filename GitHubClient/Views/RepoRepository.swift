//
//  RepoRepository.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/13.
//

import Foundation
import Combine

protocol RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error>
}

struct RepoDataRepository: RepoRepository {
    func fetchRepos() -> AnyPublisher<[Repo], Error> {
        RepoAPIClient().getRepos()
    }
}
