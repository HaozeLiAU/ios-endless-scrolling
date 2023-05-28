//
//  WebsiteData.swift
//  Webdatacollect
//
//  Created by haoze li on 3/24/23.
//
import FirebaseFirestore
import CoreMotion
import UIKit


struct Website: Identifiable {
    var id = UUID()
    var url: String
    var scrollCount: Int
    var touchEvents: [(point: CGPoint, timestamp: TimeInterval, scrollVelocity: CGFloat, acceleration: CMAcceleration)] = []
}


class WebsiteDataManager: ObservableObject {
    @Published var websites: [Website] = []


    func incrementScrollCount(for websiteUrl: String, touchPoint: CGPoint, timestamp: TimeInterval, scrollVelocity: CGFloat, acceleration: CMAcceleration) {
        // 添加 scrollVelocity 和 acceleration 参数
        if let index = websites.firstIndex(where: { $0.url == websiteUrl }) {
            websites[index].scrollCount += 1
            websites[index].touchEvents.append((point: touchPoint, timestamp: timestamp, scrollVelocity: scrollVelocity, acceleration: acceleration)) // 添加 scrollVelocity 和 acceleration 数据到 touchEvents
        } else {
            websites.append(Website(url: websiteUrl, scrollCount: 1, touchEvents: [(point: touchPoint, timestamp: timestamp, scrollVelocity: scrollVelocity, acceleration: acceleration)])) // 添加 scrollVelocity 和 acceleration 数据到新的Website对象
        }
        saveDataToFirebase()
    }


    func saveDataToFirebase() {
        let db = Firestore.firestore()


        for website in websites {
            // Convert touchEvents to an array of dictionaries
            let touchEventsArray = website.touchEvents.map { ["x": $0.point.x, "y": $0.point.y, "timestamp": $0.timestamp, "scrollVelocity": $0.scrollVelocity, "accelerationX": $0.acceleration.x, "accelerationY": $0.acceleration.y, "accelerationZ": $0.acceleration.z] } // 添加 scrollVelocity 和 acceleration 数据到 Firestore 数据


            let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown device" // 获取设备 UUID


            let data: [String: Any] = [
                "url": website.url,
                "scrollCount": website.scrollCount,
                "touchEvents": touchEventsArray,
                "deviceID": deviceID // 添加 deviceID 到 Firestore 数据
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




