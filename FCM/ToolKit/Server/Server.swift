//
//  Server.swift
//  Mini FCM
//
//  Created by fridakitten on 10.12.24.
//

import SwiftUI
import WebKit
import SystemConfiguration

let server: HttpServer = HttpServer()

func findFoldersRecursively(at path: String) -> [String] {
    var folderPaths: [String] = []

    // Helper function to recursively explore directories
    func exploreDirectory(at currentPath: String, relativeTo basePath: String) {
        let fileManager = FileManager.default

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: currentPath)
            for item in contents {
                let fullPath = (currentPath as NSString).appendingPathComponent(item)
                var isDirectory: ObjCBool = false

                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory), isDirectory.boolValue {
                    let relativePath = (fullPath as NSString).substring(from: basePath.count)
                    folderPaths.append(relativePath)
                    exploreDirectory(at: fullPath, relativeTo: basePath)
                }
            }
        } catch {
            print("Error while exploring directory at \(currentPath): \(error)")
        }
    }

    // Ensure the path does not end with a trailing slash
    let sanitizedPath = (path as NSString).expandingTildeInPath

    exploreDirectory(at: sanitizedPath, relativeTo: sanitizedPath)

    return folderPaths
}

func startServer(path: String) {
    // whitelisting server root
    server["/:path"] = shareFilesFromDirectory(path)
    let tree: [String] = findFoldersRecursively(at: path)
    for item in tree {
        server["\(item)/:path"] = shareFilesFromDirectory("\(path)\(item)")
    }
    
    server["/"] = { request in
        let filePath = "/index.html"
        guard let htmlData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return .notFound
        }
        return HttpResponse.raw(200, "OK", ["Content-Type": "text/html"]) { writer in
            try writer.write(htmlData)
        }
    }
    
    do {
        try server.start(333, forceIPv4: true)
    } catch {
        print(error)
    }
}

func stopServer() {
    server.stop()
}

// A SwiftUI wrapper for WKWebView
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        // Create a WKWebView
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load the URL in the WebView
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

func getIPAddress() -> String {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }

            guard let interface = ptr?.pointee else { return "" }
            let addrFamily = interface.ifa_addr.pointee.sa_family

            // Check if it's IPv4 (AF_INET) and if it's the Wi-Fi interface "en0"
            if addrFamily == UInt8(AF_INET) {
                let name: String = String(cString: interface.ifa_name)
                if name == "en0" {  // "en0" is typically the Wi-Fi interface
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
    }
    return address ?? "127.0.0.1"
}

struct ServerView: View {
    @Binding var isPresented: Bool
    var url: URL?
    
    init(isPresented: Binding<Bool>, url: URL? = nil, action: @escaping () -> Void) {
        action()
        _isPresented = isPresented
        self.url = url
    }
    
    var body: some View {
        NavigationView {
            if let url = url {
                //WebView(url: url)
                ServerRaw()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                server.stop()
                                isPresented = false
                            }) {
                                Text("Stop")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                    .navigationTitle("Server (\(getIPAddress()):333)")
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea()
            }
        }
    }
}
