//
//  Meow.swift
//  Mini FCM
//
//  Created by fridakitten on 11.12.24.
//

import SwiftUI
import WebKit

struct ServerRaw: View {
    let webView = WebViewNew(request: URLRequest(url: URL(string: "http://127.0.0.1:333/index.html")!))
    
    var body: some View {
        ZStack {
            VStack {
                //Spacer().frame(height: 130)
                webView
                    .frame(height: UIScreen.main.bounds.height)
            }
            
            VStack {
                Spacer().frame(height: UIScreen.main.bounds.height - 200)
                HStack {
                    Button(action: {
                        self.webView.goBack()
                    }){
                        Image(systemName: "arrowtriangle.left.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            .scaleEffect(0.75)
                    }
                    Spacer()
                    Button(action: {
                        self.webView.goHome()
                    }){
                        Image(systemName: "house.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            .scaleEffect(0.75)
                    }
                    Spacer()
                    Button(action: {
                        self.webView.refresh()
                    }){
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            .scaleEffect(0.75)
                    }
                    Spacer()
                    Button(action: {
                        self.webView.goForward()
                    }){
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            .scaleEffect(0.75)
                    }
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(25)
                .frame(width: UIScreen.main.bounds.width / 1.5)
            }
        }
        .ignoresSafeArea(.all)
    }
}

struct WebViewNew: UIViewRepresentable {
    let request: URLRequest
    private var webView: WKWebView?
    
    init(request: URLRequest) {
            self.webView = WKWebView()
            self.request = request
        }
  
    func makeUIView(context: Context) -> WKWebView {
        return webView!
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
    func goBack(){
        webView?.goBack()
    }

    func goForward(){
        webView?.goForward()
    }
    
    func refresh() {
        webView?.reload()
    }
    
    func goHome() {
        webView?.load(request)
    }
}
