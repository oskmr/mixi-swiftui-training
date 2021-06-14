//
//  RepoListViewModel.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/13.
//

import Foundation
import Combine

class RepoListViewModel: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle

    private var cancellabels = Set<AnyCancellable>()
    private let repoRepository: RepoRepository

    func onAppear() {
        loadRepos()
    }

    func onRetryButtonTapped() {
        loadRepos()
    }

    init(repoRepository: RepoRepository = RepoDataRepository()) {
        self.repoRepository = repoRepository
    }

    private func loadRepos() {
        repoRepository.fetchRepos()
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repos = .loading
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error: ", error)
                    self?.repos = .failed(error)
                case .finished: print("Finished")
                }
            }, receiveValue: { [weak self] repos in
                self?.repos = .loaded(repos)
            })
            .store(in: &cancellabels)
    }
}
