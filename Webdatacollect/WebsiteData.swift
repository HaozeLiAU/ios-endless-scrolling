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
    var touchEvents: [(point: CGPoint, timestamp: TimeInterval)] = []
}

class WebsiteDataManager: ObservableObject {
    @Published var websites: [Website] = []

    // Add timestamp parameter
    func incrementScrollCount(for websiteUrl: String, touchPoint: CGPoint, timestamp: TimeInterval) {
        if let index = websites.firstIndex(where: { $0.url == websiteUrl }) {
            websites[index].scrollCount += 1
            // Add touch point and timestamp to touchEvents array
            websites[index].touchEvents.append((point: touchPoint, timestamp: timestamp))
        } else {
            // Add touchPoint and timestamp to the new Website object
            websites.append(Website(url: websiteUrl, scrollCount: 1, touchEvents: [(point: touchPoint, timestamp: timestamp)]))
        }
        saveDataToFirebase()
    }

    func saveDataToFirebase() {
        let db = Firestore.firestore()

        for website in websites {
            // Convert touchEvents to an array of dictionaries
            let touchEventsArray = website.touchEvents.map { ["x": $0.point.x, "y": $0.point.y, "timestamp": $0.timestamp] }

            let data: [String: Any] = [
                "url": website.url,
                "scrollCount": website.scrollCount,
                // Add touchEvents to data
                "touchEvents": touchEventsArray
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


