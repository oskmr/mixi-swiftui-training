//
//  GitHubClientTests.swift
//  GitHubClientTests
//
//  Created by 逢坂 美芹 on 2021/06/14.
//

import XCTest
import Combine
@testable import GitHubClient

class RepoListViewModelTests: XCTestCase {

    override func setUpWithError() throws {
    }

    func test_onAppear_正常系() {
        let viewModel = RepoListViewModel(
            repoRepository: MockRepoRepository(
                repos: [.mock1, .mock2]
            )
        )
    }

    struct MockRepoRepository: RepoRepository {
        let repos: [Repo]

        init(repos: [Repo]) {
            self.repos = repos
        }

        func fetchRepos() -> AnyPublisher<[Repo], Error> {
            Just(repos)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

}
