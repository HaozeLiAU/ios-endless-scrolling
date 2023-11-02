//
//  WebView.swift
//  Webdatacollect
//
//  Created by haoze li on 3/20/23.
//
import SwiftUI
import WebKit
import CoreMotion // 添加这一行

struct WebView: UIViewRepresentable {
    @Binding var urlString: String
    @EnvironmentObject var websiteDataManager: WebsiteDataManager
    var motionManager = CMMotionManager() 

    func makeCoordinator() -> Coordinator {
        Coordinator(self, motionManager: motionManager) 
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
        var currentUrl: String?
        var motionManager: CMMotionManager 
        var lastContentOffset: CGPoint = .zero 

        init(_ parent: WebView, motionManager: CMMotionManager) { 
            self.parent = parent
            self.motionManager = motionManager 
            super.init() 
            startAccelerometer() 
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.urlString = webView.url?.absoluteString ?? ""
            currentUrl = webView.url?.absoluteString
            if !parent.websiteDataManager.websites.contains(where: { $0.url == parent.urlString }) {
                parent.websiteDataManager.websites.append(Website(url: parent.urlString, scrollCount: 0))
            }
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            
            lastContentOffset = scrollView.contentOffset
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // Record touch location and timestamp
            let touchPoint = scrollView.panGestureRecognizer.location(in: scrollView)
            let timestamp = Date().timeIntervalSince1970

            
            let currentContentOffset = scrollView.contentOffset
            let scrollVelocity = sqrt(pow(currentContentOffset.x - lastContentOffset.x, 2) + pow(currentContentOffset.y - lastContentOffset.y, 2))

            
            if let accelerometerData = motionManager.accelerometerData {
                let acceleration = accelerometerData.acceleration
                parent.websiteDataManager.incrementScrollCount(for: currentUrl!, touchPoint: touchPoint, timestamp: timestamp, scrollVelocity: scrollVelocity, acceleration: acceleration)
            }
        }
        
        // Accelerometer
        func startAccelerometer() {
            if motionManager.isAccelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 0.1 // rate
                motionManager.startAccelerometerUpdates()
            }
        }
    }
}










