import Foundation
import CoreLocation
import SwiftUI

struct Walk: Identifiable, Codable, Hashable {
    let id: UUID
    let colorId: String
    let colorName: String
    let hexColor: String
    let startTime: Date
    var endTime: Date?
    var stepCount: Int
    var photos: [WalkPhoto]
    var routeCoordinates: [CodableCoordinate]

    var duration: TimeInterval {
        (endTime ?? Date()) - startTime
    }

    var durationMinutes: Int {
        Int(duration) / 60
    }

    var distanceKm: Double {
        guard routeCoordinates.count >= 2 else { return 0 }
        var total: Double = 0
        for i in 1..<routeCoordinates.count {
            let from = CLLocation(latitude: routeCoordinates[i-1].lat, longitude: routeCoordinates[i-1].lon)
            let to = CLLocation(latitude: routeCoordinates[i].lat, longitude: routeCoordinates[i].lon)
            total += from.distance(from: to)
        }
        return total / 1000.0
    }

    var distanceMiles: Double {
        distanceKm * 0.621371
    }

    var swiftUIColor: Color {
        if hexColor == "gradient" {
            return .blue
        }
        return Color(hex: hexColor)
    }

    init(
        id: UUID = UUID(),
        colorId: String,
        colorName: String,
        hexColor: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        stepCount: Int = 0,
        photos: [WalkPhoto] = [],
        routeCoordinates: [CodableCoordinate] = []
    ) {
        self.id = id
        self.colorId = colorId
        self.colorName = colorName
        self.hexColor = hexColor
        self.startTime = startTime
        self.endTime = endTime
        self.stepCount = stepCount
        self.photos = photos
        self.routeCoordinates = routeCoordinates
    }
}

struct CodableCoordinate: Codable, Hashable {
    let lat: Double
    let lon: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.lat = coordinate.latitude
        self.lon = coordinate.longitude
    }

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}