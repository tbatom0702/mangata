import Foundation
import UIKit
import Photos

final class PhotoService: ObservableObject {
    @Published var isAuthorized: Bool = false

    func requestAuthorization() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            await MainActor.run { isAuthorized = true }
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            await MainActor.run { isAuthorized = (newStatus == .authorized || newStatus == .limited) }
            return newStatus == .authorized || newStatus == .limited
        default:
            return false
        }
    }

    func saveImage(_ image: UIImage) async -> Bool {
        guard await requestAuthorization() else { return false }
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    func extractDominantColors(from image: UIImage) -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        let width = 10
        let height = 10
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var colorCounts: [String: Int] = [:]
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = pixelData[i] / 32 * 32
            let g = pixelData[i+1] / 32 * 32
            let b = pixelData[i+2] / 32 * 32
            let hex = String(format: "#%02X%02X%02X", r, g, b)
            colorCounts[hex, default: 0] += 1
        }

        let sorted = colorCounts.sorted { $0.value > $1.value }
        return Array(sorted.prefix(5).map { $0.key })
    }

    func createWalkPhoto(from image: UIImage) -> WalkPhoto? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let colors = extractDominantColors(from: image)
        return WalkPhoto(imageData: data, timestamp: Date(), dominantColors: colors)
    }
}