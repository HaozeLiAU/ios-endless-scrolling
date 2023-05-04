//
//  ContentView.swift
//  Webdatacollect
//
//  Created by haoze li on 3/18/23.
//
import SwiftUI


struct ContentView: View {
    @State private var inputUrlString = "https://www.example.com"
    @State private var webViewUrlString = "https://www.example.com"
    @StateObject private var websiteDataManager = WebsiteDataManager()

    func loadUrl() {
        webViewUrlString = inputUrlString
    }

    func showWebsiteData() {
        print("now show data")
        for website in websiteDataManager.websites {
            print("Website: \(website.url), Scroll Count: \(website.scrollCount)")
        }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Enter URL", text: $inputUrlString)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: loadUrl) {
                    Text("Go")
                }
                .padding()
                Button(action: showWebsiteData) {
                    Text("Show Data")
                }
                .padding()
            }
            WebView(urlString: $webViewUrlString).environmentObject(websiteDataManager)
                
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WebsiteDataManager())
    }
}




