//
//  WebsiteData.swift
//  Webdatacollect
//
//  Created by haoze li on 3/24/23.
//

import Foundation

struct Website: Identifiable {
    var id = UUID()
    var url: String
    var scrollCount: Int
}

class WebsiteDataManager: ObservableObject {
    @Published var websites: [Website] = []
    
    func incrementScrollCount(for websiteUrl: String) {
        if let index = websites.firstIndex(where: { $0.url == websiteUrl }) {
            websites[index].scrollCount += 1
        } else {
            websites.append(Website(url: websiteUrl, scrollCount: 1))
        }
    }
}






