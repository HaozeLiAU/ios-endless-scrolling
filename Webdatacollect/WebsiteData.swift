//
//  WebsiteData.swift
//  Webdatacollect
//
//  Created by haoze li on 3/24/23.
//

import FirebaseFirestore

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
        saveDataToFirebase()
    }
    
    func saveDataToFirebase() {
        let db = Firestore.firestore()
        
        for website in websites {
            let data: [String: Any] = [
                "url": website.url,
                "scrollCount": website.scrollCount
            ]
            
            db.collection("websites").document(website.id.uuidString).setData(data) { error in
                if let error = error {
                    print("Error saving data to Firestore: \(error)")
                } else {
                    print("Data successfully saved to Firestore")
                }
            }
        }
    }
    
}



