import Foundation

// MARK: - Bluetooth State

public enum PrismBluetoothState: Sendable, CaseIterable {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

// MARK: - Peripheral

public struct PrismPeripheral: Sendable {
    public let id: UUID
    public let name: String?
    public let rssi: Int?
    public let isConnected: Bool

    public init(id: UUID, name: String? = nil, rssi: Int? = nil, isConnected: Bool = false) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.isConnected = isConnected
    }
}

// MARK: - BLE Service

public struct PrismBLEService: Sendable {
    public let id: String
    public let name: String?
    public let characteristics: [PrismBLECharacteristic]

    public init(id: String, name: String? = nil, characteristics: [PrismBLECharacteristic] = []) {
        self.id = id
        self.name = name
        self.characteristics = characteristics
    }
}

// MARK: - BLE Characteristic

public struct PrismBLECharacteristic: Sendable {
    public let id: String
    public let value: Data?
    public let isNotifying: Bool
    public let properties: PrismCharacteristicProperties

    public init(
        id: String, value: Data? = nil, isNotifying: Bool = false, properties: PrismCharacteristicProperties = []
    ) {
        self.id = id
        self.value = value
        self.isNotifying = isNotifying
        self.properties = properties
    }
}

// MARK: - Characteristic Properties

public struct PrismCharacteristicProperties: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let read = PrismCharacteristicProperties(rawValue: 1 << 0)
    public static let write = PrismCharacteristicProperties(rawValue: 1 << 1)
    public static let writeWithoutResponse = PrismCharacteristicProperties(rawValue: 1 << 2)
    public static let notify = PrismCharacteristicProperties(rawValue: 1 << 3)
    public static let indicate = PrismCharacteristicProperties(rawValue: 1 << 4)
}
