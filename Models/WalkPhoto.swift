import Foundation
import SwiftUI

struct WalkPhoto: Identifiable, Codable, Hashable {
    let id: UUID
    let imageData: Data
    let timestamp: Date
    var dominantColors: [String]

    init(
        id: UUID = UUID(),
        imageData: Data,
        timestamp: Date = Date(),
        dominantColors: [String] = []
    ) {
        self.id = id
        self.imageData = imageData
        self.timestamp = timestamp
        self.dominantColors = dominantColors
    }

    var image: UIImage? {
        UIImage(data: imageData)
    }
}