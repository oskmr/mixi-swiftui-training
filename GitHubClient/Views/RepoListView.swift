//
//  ContentView.swift
//  GitHubClient
//
//  Created by 逢坂 美芹 on 2021/06/06.
//

import SwiftUI
import Combine

struct RepoListView: View {
    @StateObject private var viewModel = RepoListViewModel()

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.repos {
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
                                viewModel.onRetryButtonTapped() // リトライボタンをタップしたときに再度リクエストを投げる
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
            viewModel.onAppear()
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
