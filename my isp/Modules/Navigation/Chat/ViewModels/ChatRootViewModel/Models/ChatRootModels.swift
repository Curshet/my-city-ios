import Foundation

// MARK: - ChatRootViewData
struct ChatRootViewData {
    let layout: ChatRootViewLayout
    let webview: ChatRootWebViewData
}

// MARK: - ChatRootWebViewData
struct ChatRootWebViewData {
    let request: URLRequest?
    let script: String
}
