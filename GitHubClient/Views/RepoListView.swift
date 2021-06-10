//
//  ContentView.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/06.
//

import SwiftUI
import Combine

struct RepoListView: View {
    @StateObject private var reposLoader = ReposLoader()

    var body: some View {
        NavigationView {
            if reposLoader.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposLoader.repos) { repo in
                    NavigationLink(
                        destination: RepoDetailView(repo: repo)) {
                        RepoRow(repo: repo)
                    }
                }
                .navigationTitle("Repositories")
            }
        }
        .onAppear {
            reposLoader.call()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}

class ReposLoader: ObservableObject {
    @Published private(set) var repos = [Repo]()
    private var cancellabels = Set<AnyCancellable>()

    func call() {
        let reposPublisher = Future<[Repo], Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                promise(.success([
                    .mock1, .mock2, .mock3, .mock4, .mock5
                ]))
            }
        }
        reposPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("Finished: ",completion)
            }, receiveValue: { [weak self] repos in
                self?.repos = repos
            }).store(in: &cancellabels)
    }

}
