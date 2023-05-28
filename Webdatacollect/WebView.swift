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
    var motionManager = CMMotionManager() // 添加这一行

    func makeCoordinator() -> Coordinator {
        Coordinator(self, motionManager: motionManager) // 修改这一行
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
        var motionManager: CMMotionManager // 添加这一行
        var lastContentOffset: CGPoint = .zero // 添加这一行

        init(_ parent: WebView, motionManager: CMMotionManager) { // 修改这一行
            self.parent = parent
            self.motionManager = motionManager // 添加这一行
            super.init() // 添加这一行
            startAccelerometer() // 添加这一行
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.urlString = webView.url?.absoluteString ?? ""
            currentUrl = webView.url?.absoluteString
            if !parent.websiteDataManager.websites.contains(where: { $0.url == parent.urlString }) {
                parent.websiteDataManager.websites.append(Website(url: parent.urlString, scrollCount: 0))
            }
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            // 记录开始拖动时的内容偏移量
            lastContentOffset = scrollView.contentOffset
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // Record touch location and timestamp
            let touchPoint = scrollView.panGestureRecognizer.location(in: scrollView)
            let timestamp = Date().timeIntervalSince1970

            // 计算滚动速度
            let currentContentOffset = scrollView.contentOffset
            let scrollVelocity = sqrt(pow(currentContentOffset.x - lastContentOffset.x, 2) + pow(currentContentOffset.y - lastContentOffset.y, 2))

            // 记录加速度
            if let accelerometerData = motionManager.accelerometerData {
                let acceleration = accelerometerData.acceleration
                parent.websiteDataManager.incrementScrollCount(for: currentUrl!, touchPoint: touchPoint, timestamp: timestamp, scrollVelocity: scrollVelocity, acceleration: acceleration)
            }
        }
        
        // 开始收集加速度计数据
        func startAccelerometer() {
            if motionManager.isAccelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 0.1 // 更新频率
                motionManager.startAccelerometerUpdates()
            }
        }
    }
}










