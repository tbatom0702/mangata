import Foundation
import SwiftUI
import MapKit
import Combine
import SwiftData

@MainActor
final class WalkViewModel: ObservableObject {
    @Published var walk: Walk?
    @Published var isWalking: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var photos: [WalkPhoto] = []
    @Published var routeCoordinates: [CodableCoordinate] = []
    @Published var stepCount: Int = 0
    @Published var currentCity: String = ""
    @Published var currentDistrict: String = ""
    @Published var showingCamera: Bool = false
    @Published var showingFinishAlert: Bool = false

    let locationService = LocationService()
    let motionService = MotionService()
    let photoService = PhotoService()

    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    let maxPhotos = 9

    init() {
        setupBindings()
    }

    private func setupBindings() {
        locationService.$routeCoordinates
            .map { $0.map { CodableCoordinate($0) } }
            .assign(to: &$routeCoordinates)

        locationService.$currentCity
            .assign(to: &$currentCity)

        locationService.$currentDistrict
            .assign(to: &$currentDistrict)

        motionService.$stepCount
            .assign(to: &$stepCount)
    }

    func startWalk(theme: ColorTheme) {
        walk = Walk(
            colorId: theme.id,
            colorName: theme.name,
            hexColor: theme.hex
        )
        isWalking = true
        elapsedSeconds = 0

        locationService.requestAuthorization()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.locationService.startTracking()
        }

        motionService.startCounting()
        startTimer()
    }

    func finishWalk() {
        guard var currentWalk = walk else { return }
        stopTimer()
        locationService.stopTracking()
        motionService.stopCounting()
        isWalking = false

        currentWalk = Walk(
            id: currentWalk.id,
            colorId: currentWalk.colorId,
            colorName: currentWalk.colorName,
            hexColor: currentWalk.hexColor,
            startTime: currentWalk.startTime,
            endTime: Date(),
            stepCount: stepCount,
            photos: photos,
            routeCoordinates: routeCoordinates
        )
        walk = currentWalk
    }

    func addPhoto(_ image: UIImage) {
        guard photos.count < maxPhotos, let photo = photoService.createWalkPhoto(from: image) else { return }
        photos.append(photo)
    }

    func removePhoto(_ photo: WalkPhoto) {
        photos.removeAll { $0.id == photo.id }
    }

    var durationString: (hours: String, minutes: String, seconds: String) {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return (
            String(format: "%02d", h),
            String(format: "%02d", m),
            String(format: "%02d", s)
        )
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    var mapRegion: MKCoordinateRegion? {
        locationService.region
    }

    var routePolyline: MKPolyline? {
        guard !routeCoordinates.isEmpty else { return nil }
        return MKPolyline(coordinates: routeCoordinates.map { $0.clCoordinate }, count: routeCoordinates.count)
    }

    var cityDistrict: String {
        if !currentCity.isEmpty && !currentDistrict.isEmpty {
            return "\(currentCity)·\(currentDistrict)"
        } else if !currentCity.isEmpty {
            return currentCity
        }
        return "未知位置"
    }

    var completedWalk: Walk? {
        guard let w = walk, !isWalking else { return nil }
        return Walk(
            id: w.id,
            colorId: w.colorId,
            colorName: w.colorName,
            hexColor: w.hexColor,
            startTime: w.startTime,
            endTime: w.endTime ?? Date(),
            stepCount: stepCount,
            photos: photos,
            routeCoordinates: routeCoordinates
        )
    }
}