import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // The name of the HTML file in the bundle
    var htmlFileName: String

    // Create the WKWebView
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    // Load the HTML file from the bundle and set the base URL
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlPath = htmlFileName
        let fileURL = URL(fileURLWithPath: htmlPath)
        let directoryURL = fileURL.deletingLastPathComponent()
        do {
            //let htmlString = try String(contentsOf: fileURL, encoding: .utf8)
            webView.loadFileURL(fileURL, allowingReadAccessTo: URL(fileURLWithPath: "\(global_documents)"))
        } catch {
            print("Error loading HTML file: \(error.localizedDescription)")
        }
    }
}
