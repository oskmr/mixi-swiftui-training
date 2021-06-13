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
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github.v3+json"
        ]

        let repoPublisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Repo].self, decoder: JSONDecoder())

        repoPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error: ", error)
                case .finished: print("Finished")
                }

                print("Finished: ",completion)
            }, receiveValue: { [weak self] repos in
                self?.repos = repos
            }).store(in: &cancellabels)
    }

}
