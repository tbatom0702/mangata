import Foundation
import CoreMotion
import Combine

final class MotionService: ObservableObject {
    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()

    @Published var stepCount: Int = 0
    @Published var isAvailable: Bool = false
    @Published var isTracking: Bool = false

    private var startDate: Date?

    init() {
        isAvailable = CMPedometer.isStepCountingAvailable()
    }

    func startCounting(from date: Date = Date()) {
        guard isAvailable else { return }
        startDate = date
        isTracking = true
        pedometer.startUpdates(from: date) { [weak self] data, error in
            DispatchQueue.main.async {
                if let data = data {
                    self?.stepCount = data.numberOfSteps.intValue
                } else if let error = error {
                    print("Pedometer error: \(error.localizedDescription)")
                }
            }
        }
    }

    func stopCounting() {
        isTracking = false
        pedometer.stopUpdates()
    }

    func querySteps(from startDate: Date, to endDate: Date) async -> Int {
        guard isAvailable else { return 0 }
        return await withCheckedContinuation { continuation in
            pedometer.queryPedometerData(from: startDate, to: endDate) { data, _ in
                continuation.resume(returning: data?.numberOfSteps.intValue ?? 0)
            }
        }
    }
}