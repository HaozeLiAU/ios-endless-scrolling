//
//  WebView.swift
//  Webdatacollect
//
//  Created by haoze li on 3/20/23.
//
import SwiftUI
import WebKit
struct WebView: UIViewRepresentable {
    @Binding var urlString: String
    @EnvironmentObject var websiteDataManager: WebsiteDataManager
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        loadUrl(webView: webView)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url?.absoluteString != urlString {
            loadUrl(webView: uiView)
        }
    }
    private func loadUrl(webView: WKWebView) {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        var parent: WebView
        var currentUrl:String?
        init(_ parent: WebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.urlString = webView.url?.absoluteString ?? ""
            currentUrl = webView.url?.absoluteString
            if !parent.websiteDataManager.websites.contains(where: { $0.url == parent.urlString }) {
                parent.websiteDataManager.websites.append(Website(url: parent.urlString, scrollCount: 0))
            }
        }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // Added touch point location
            let touchPoint = scrollView.panGestureRecognizer.location(in: scrollView)
                        
            // Added touchPoint as a parameter
            parent.websiteDataManager.incrementScrollCount(for: currentUrl!, touchPoint: touchPoint)

                
            
            
        }
    }
}









