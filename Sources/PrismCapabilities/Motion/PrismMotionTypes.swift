import Foundation

// MARK: - Accelerometer Data

public struct PrismAccelerometerData: Sendable {
    public let x: Double
    public let y: Double
    public let z: Double
    public let timestamp: Date

    public init(x: Double, y: Double, z: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
}

// MARK: - Gyroscope Data

public struct PrismGyroscopeData: Sendable {
    public let x: Double
    public let y: Double
    public let z: Double
    public let timestamp: Date

    public init(x: Double, y: Double, z: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.z = z
        self.timestamp = timestamp
    }
}

// MARK: - Attitude

public struct PrismAttitude: Sendable {
    public let roll: Double
    public let pitch: Double
    public let yaw: Double

    public init(roll: Double, pitch: Double, yaw: Double) {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
}

// MARK: - Device Motion

public struct PrismDeviceMotion: Sendable {
    public let attitude: PrismAttitude
    public let rotationRate: PrismGyroscopeData
    public let gravity: PrismAccelerometerData
    public let userAcceleration: PrismAccelerometerData

    public init(
        attitude: PrismAttitude,
        rotationRate: PrismGyroscopeData,
        gravity: PrismAccelerometerData,
        userAcceleration: PrismAccelerometerData
    ) {
        self.attitude = attitude
        self.rotationRate = rotationRate
        self.gravity = gravity
        self.userAcceleration = userAcceleration
    }
}

// MARK: - Pedometer Data

public struct PrismPedometerData: Sendable {
    public let steps: Int
    public let distance: Double?
    public let floorsAscended: Int?
    public let floorsDescended: Int?
    public let startDate: Date
    public let endDate: Date

    public init(
        steps: Int,
        distance: Double? = nil,
        floorsAscended: Int? = nil,
        floorsDescended: Int? = nil,
        startDate: Date,
        endDate: Date
    ) {
        self.steps = steps
        self.distance = distance
        self.floorsAscended = floorsAscended
        self.floorsDescended = floorsDescended
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Activity Type

public enum PrismActivityType: Sendable, CaseIterable {
    case stationary
    case walking
    case running
    case cycling
    case automotive
    case unknown
}

// MARK: - Altitude Data

public struct PrismAltitudeData: Sendable {
    public let relativeAltitude: Double
    public let pressure: Double
    public let timestamp: Date

    public init(relativeAltitude: Double, pressure: Double, timestamp: Date) {
        self.relativeAltitude = relativeAltitude
        self.pressure = pressure
        self.timestamp = timestamp
    }
}
