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
    // Added touchPoints field
    var touchPoints: [CGPoint] = []
}

class WebsiteDataManager: ObservableObject {
    @Published var websites: [Website] = []
    
    // Added touchPoint parameter
    func incrementScrollCount(for websiteUrl: String, touchPoint: CGPoint) {
        if let index = websites.firstIndex(where: { $0.url == websiteUrl }) {
            websites[index].scrollCount += 1
            // Added touch point to touchPoints array
            websites[index].touchPoints.append(touchPoint)
        } else {
            // Added touchPoint to the new Website object
            websites.append(Website(url: websiteUrl, scrollCount: 1, touchPoints: [touchPoint]))
        }
        saveDataToFirebase()
    }
    
    func saveDataToFirebase() {
        let db = Firestore.firestore()
        
        for website in websites {
            // Convert touchPoints to an array of dictionaries
            let touchPointsArray = website.touchPoints.map { ["x": $0.x, "y": $0.y] }
            
            let data: [String: Any] = [
                "url": website.url,
                "scrollCount": website.scrollCount,
                // Added touchPoints to data
                "touchPoints": touchPointsArray
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

