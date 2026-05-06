import Foundation

#if canImport(CoreMotion) && (os(iOS) || os(watchOS))
    import CoreMotion

    @MainActor @Observable
    public final class PrismMotionClient {
        private let motionManager = CMMotionManager()
        private let pedometer = CMPedometer()
        private let activityManager = CMMotionActivityManager()
        private let altimeter = CMAltimeter()

        // MARK: - Availability

        public var isAccelerometerAvailable: Bool { motionManager.isAccelerometerAvailable }

        public var isGyroscopeAvailable: Bool { motionManager.isGyroscopeAvailable }

        public var isDeviceMotionAvailable: Bool { motionManager.isDeviceMotionAvailable }

        public var isPedometerAvailable: Bool { CMPedometer.isStepCountingAvailable() }

        // MARK: - Latest Readings

        public private(set) var latestAccelerometer: PrismAccelerometerData?

        public private(set) var latestGyroscope: PrismGyroscopeData?

        public private(set) var latestMotion: PrismDeviceMotion?

        public private(set) var currentActivity: PrismActivityType = .unknown

        public private(set) var latestAltitude: PrismAltitudeData?

        public init() {}

        // MARK: - Accelerometer

        public func startAccelerometerUpdates(interval: TimeInterval) {
            motionManager.accelerometerUpdateInterval = interval
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                MainActor.assumeIsolated {
                    self.latestAccelerometer = PrismAccelerometerData(
                        x: data.acceleration.x,
                        y: data.acceleration.y,
                        z: data.acceleration.z,
                        timestamp: Date(timeIntervalSinceReferenceDate: data.timestamp)
                    )
                }
            }
        }

        public func stopAccelerometerUpdates() {
            motionManager.stopAccelerometerUpdates()
            latestAccelerometer = nil
        }

        // MARK: - Gyroscope

        public func startGyroscopeUpdates(interval: TimeInterval) {
            motionManager.gyroUpdateInterval = interval
            motionManager.startGyroUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                MainActor.assumeIsolated {
                    self.latestGyroscope = PrismGyroscopeData(
                        x: data.rotationRate.x,
                        y: data.rotationRate.y,
                        z: data.rotationRate.z,
                        timestamp: Date(timeIntervalSinceReferenceDate: data.timestamp)
                    )
                }
            }
        }

        public func stopGyroscopeUpdates() {
            motionManager.stopGyroUpdates()
            latestGyroscope = nil
        }

        // MARK: - Device Motion

        public func startDeviceMotionUpdates(interval: TimeInterval) {
            motionManager.deviceMotionUpdateInterval = interval
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                let timestamp = Date(timeIntervalSinceReferenceDate: data.timestamp)
                MainActor.assumeIsolated {
                    self.latestMotion = PrismDeviceMotion(
                        attitude: PrismAttitude(
                            roll: data.attitude.roll,
                            pitch: data.attitude.pitch,
                            yaw: data.attitude.yaw
                        ),
                        rotationRate: PrismGyroscopeData(
                            x: data.rotationRate.x,
                            y: data.rotationRate.y,
                            z: data.rotationRate.z,
                            timestamp: timestamp
                        ),
                        gravity: PrismAccelerometerData(
                            x: data.gravity.x,
                            y: data.gravity.y,
                            z: data.gravity.z,
                            timestamp: timestamp
                        ),
                        userAcceleration: PrismAccelerometerData(
                            x: data.userAcceleration.x,
                            y: data.userAcceleration.y,
                            z: data.userAcceleration.z,
                            timestamp: timestamp
                        )
                    )
                }
            }
        }

        public func stopDeviceMotionUpdates() {
            motionManager.stopDeviceMotionUpdates()
            latestMotion = nil
        }

        // MARK: - Pedometer

        public func queryPedometer(from: Date, to: Date) async throws -> PrismPedometerData {
            try await withCheckedThrowingContinuation { continuation in
                pedometer.queryPedometerData(from: from, to: to) { data, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data else {
                        continuation.resume(throwing: PrismMotionError.noData)
                        return
                    }
                    let result = PrismPedometerData(
                        steps: data.numberOfSteps.intValue,
                        distance: data.distance?.doubleValue,
                        floorsAscended: data.floorsAscended?.intValue,
                        floorsDescended: data.floorsDescended?.intValue,
                        startDate: data.startDate,
                        endDate: data.endDate
                    )
                    continuation.resume(returning: result)
                }
            }
        }

        // MARK: - Activity

        public func startActivityUpdates() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self, let activity else { return }
                MainActor.assumeIsolated {
                    self.currentActivity = activity.prismActivityType
                }
            }
        }

        public func stopActivityUpdates() {
            activityManager.stopActivityUpdates()
            currentActivity = .unknown
        }

        // MARK: - Altitude

        public func startAltitudeUpdates() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                guard let self, let data else { return }
                MainActor.assumeIsolated {
                    self.latestAltitude = PrismAltitudeData(
                        relativeAltitude: data.relativeAltitude.doubleValue,
                        pressure: data.pressure.doubleValue,
                        timestamp: Date()
                    )
                }
            }
        }

        public func stopAltitudeUpdates() {
            altimeter.stopRelativeAltitudeUpdates()
            latestAltitude = nil
        }
    }

    // MARK: - Motion Error

    enum PrismMotionError: Error {
        case noData
    }

    // MARK: - Private Extensions

    extension CMMotionActivity {
        fileprivate var prismActivityType: PrismActivityType {
            if automotive { return .automotive }
            if cycling { return .cycling }
            if running { return .running }
            if walking { return .walking }
            if stationary { return .stationary }
            return .unknown
        }
    }
#endif
