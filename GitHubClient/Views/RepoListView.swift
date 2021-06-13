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
            Group {
                switch reposLoader.repos {
                case .idle, .loading:
                    ProgressView("loading...")
                case .failed:
                    VStack {
                        Group {
                            Image("GitHubMark")
                            Text("Failed to load repositories")
                                .padding(.top, 4)
                        }
                        .foregroundColor(.black)
                        .opacity(0.4)
                        Button(
                            action: {
                                reposLoader.call() // リトライボタンをタップしたときに再度リクエストを投げる
                            }, label: {
                                Text("Retry")
                                    .fontWeight(.bold)
                            }
                        )
                        .padding(.top, 8)
                    }
                case let .loaded(repos):
                    if repos.isEmpty {
                        Text("No repositories")
                            .fontWeight(.bold)
                    } else {
                        List(repos) { repo in
                            NavigationLink(
                                destination: RepoDetailView(repo: repo)) {
                                RepoRow(repo: repo)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Repositories")
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

enum Stateful<Value> {
    case idle // まだデータを取得しにいっていない
    case loading // 読み込み中
    case failed(Error) // 読み込み失敗、遭遇したエラーを保持
    case loaded(Value) // 読み込み完了、読み込まれたデータを保持
}


class ReposLoader: ObservableObject {
    @Published private(set) var repos: Stateful<[Repo]> = .idle

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
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.repos = .loading
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error: ", error)
                case .finished: print("Finished: ", completion)
                }
            }, receiveValue: { [weak self] repos in
                self?.repos = .loaded(repos)
            }).store(in: &cancellabels)
    }

}
