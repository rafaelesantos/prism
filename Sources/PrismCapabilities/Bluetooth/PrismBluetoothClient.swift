import Foundation

// MARK: - Bluetooth State

/// Represents the current state of the Bluetooth radio on the device.
///
/// Maps directly to `CBManagerState` for consistent state tracking across
/// the CoreBluetooth lifecycle.
public enum PrismBluetoothState: Sendable, CaseIterable {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

// MARK: - Peripheral

/// A discovered or connected BLE peripheral with basic metadata.
///
/// ```swift
/// let peripheral = PrismPeripheral(
///     id: UUID(),
///     name: "Heart Rate Sensor",
///     rssi: -45,
///     isConnected: false
/// )
/// ```
public struct PrismPeripheral: Sendable {
    /// The unique identifier for this peripheral.
    public let id: UUID
    /// The advertised local name, if available.
    public let name: String?
    /// The received signal strength indicator in dBm, if available.
    public let rssi: Int?
    /// Whether the peripheral is currently connected.
    public let isConnected: Bool

    public init(id: UUID, name: String? = nil, rssi: Int? = nil, isConnected: Bool = false) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.isConnected = isConnected
    }
}

// MARK: - BLE Service

/// A GATT service discovered on a connected peripheral.
public struct PrismBLEService: Sendable {
    /// The UUID string identifying this service.
    public let id: String
    /// The human-readable service name, if known.
    public let name: String?
    /// The characteristics belonging to this service.
    public let characteristics: [PrismBLECharacteristic]

    public init(id: String, name: String? = nil, characteristics: [PrismBLECharacteristic] = []) {
        self.id = id
        self.name = name
        self.characteristics = characteristics
    }
}

// MARK: - BLE Characteristic

/// A GATT characteristic within a service, including its current value and notification state.
public struct PrismBLECharacteristic: Sendable {
    /// The UUID string identifying this characteristic.
    public let id: String
    /// The last-read value of the characteristic.
    public let value: Data?
    /// Whether notifications are currently enabled for this characteristic.
    public let isNotifying: Bool
    /// The supported properties (read, write, notify, etc.).
    public let properties: PrismCharacteristicProperties

    public init(id: String, value: Data? = nil, isNotifying: Bool = false, properties: PrismCharacteristicProperties = []) {
        self.id = id
        self.value = value
        self.isNotifying = isNotifying
        self.properties = properties
    }
}

// MARK: - Characteristic Properties

/// An option set describing the capabilities of a BLE characteristic.
///
/// Mirrors `CBCharacteristicProperties` for a framework-agnostic API surface.
public struct PrismCharacteristicProperties: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// The characteristic supports reading its value.
    public static let read = PrismCharacteristicProperties(rawValue: 1 << 0)
    /// The characteristic supports writing its value with a response.
    public static let write = PrismCharacteristicProperties(rawValue: 1 << 1)
    /// The characteristic supports writing its value without a response.
    public static let writeWithoutResponse = PrismCharacteristicProperties(rawValue: 1 << 2)
    /// The characteristic supports notifications.
    public static let notify = PrismCharacteristicProperties(rawValue: 1 << 3)
    /// The characteristic supports indications.
    public static let indicate = PrismCharacteristicProperties(rawValue: 1 << 4)
}

// MARK: - Bluetooth Client

#if canImport(CoreBluetooth)
import CoreBluetooth

/// A client that wraps CoreBluetooth for BLE peripheral scanning, connection,
/// service discovery, and characteristic read/write/notify operations.
///
/// Designed as an `@Observable` class so SwiftUI views can react to state changes:
///
/// ```swift
/// let bluetooth = PrismBluetoothClient()
///
/// // Observe state
/// if bluetooth.state == .poweredOn {
///     bluetooth.startScanning(serviceUUIDs: nil)
/// }
///
/// // Connect to a discovered peripheral
/// if let peripheral = bluetooth.discoveredPeripherals.first {
///     try await bluetooth.connect(peripheral: peripheral)
///     let services = try await bluetooth.discoverServices(peripheral: peripheral)
/// }
/// ```
@MainActor
@Observable
public final class PrismBluetoothClient: NSObject {
    /// The current state of the Bluetooth radio.
    public private(set) var state: PrismBluetoothState = .unknown
    /// Peripherals discovered during the current or most recent scan.
    public private(set) var discoveredPeripherals: [PrismPeripheral] = []
    /// The peripheral that is currently connected, if any.
    public private(set) var connectedPeripheral: PrismPeripheral? = nil

    private var centralManager: CBCentralManager!
    private var delegate: BluetoothDelegate!
    private var cbPeripherals: [UUID: CBPeripheral] = [:]

    public override init() {
        super.init()
        delegate = BluetoothDelegate(client: self)
        centralManager = CBCentralManager(delegate: delegate, queue: .main)
    }

    /// Begins scanning for peripherals advertising the given service UUIDs.
    ///
    /// Pass `nil` to discover all nearby peripherals (not recommended for production).
    /// - Parameter serviceUUIDs: Optional array of service UUID strings to filter by.
    public func startScanning(serviceUUIDs: [String]? = nil) {
        let cbuuids = serviceUUIDs?.map { CBUUID(string: $0) }
        discoveredPeripherals = []
        cbPeripherals = [:]
        centralManager.scanForPeripherals(withServices: cbuuids)
    }

    /// Stops the current peripheral scan.
    public func stopScanning() {
        centralManager.stopScan()
    }

    /// Connects to the specified peripheral.
    ///
    /// - Parameter peripheral: The peripheral to connect to, previously discovered via scanning.
    /// - Throws: An error if the connection fails or the peripheral is unknown.
    public func connect(peripheral: PrismPeripheral) async throws {
        guard let cbPeripheral = cbPeripherals[peripheral.id] else {
            throw BluetoothError.peripheralNotFound
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.connectContinuation = continuation
            centralManager.connect(cbPeripheral)
        }
        connectedPeripheral = PrismPeripheral(
            id: peripheral.id,
            name: peripheral.name,
            rssi: peripheral.rssi,
            isConnected: true
        )
    }

    /// Disconnects from the specified peripheral.
    ///
    /// - Parameter peripheral: The peripheral to disconnect from.
    public func disconnect(peripheral: PrismPeripheral) {
        guard let cbPeripheral = cbPeripherals[peripheral.id] else { return }
        centralManager.cancelPeripheralConnection(cbPeripheral)
        if connectedPeripheral?.id == peripheral.id {
            connectedPeripheral = nil
        }
    }

    /// Discovers all GATT services on the specified peripheral.
    ///
    /// - Parameter peripheral: The connected peripheral to query.
    /// - Returns: An array of discovered services with their characteristics.
    /// - Throws: An error if service discovery fails.
    public func discoverServices(peripheral: PrismPeripheral) async throws -> [PrismBLEService] {
        guard let cbPeripheral = cbPeripherals[peripheral.id] else {
            throw BluetoothError.peripheralNotFound
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PrismBLEService], Error>) in
            delegate.servicesContinuation = continuation
            cbPeripheral.delegate = delegate
            cbPeripheral.discoverServices(nil)
        }
    }

    /// Reads the current value of a characteristic.
    ///
    /// - Parameters:
    ///   - id: The UUID string of the characteristic to read.
    ///   - serviceID: The UUID string of the service containing the characteristic.
    /// - Returns: The characteristic value, or `nil` if unavailable.
    /// - Throws: An error if the read operation fails.
    public func readCharacteristic(id: String, serviceID: String) async throws -> Data? {
        guard let cbPeripheral = connectedCBPeripheral else {
            throw BluetoothError.notConnected
        }
        guard let characteristic = findCharacteristic(id: id, serviceID: serviceID, on: cbPeripheral) else {
            throw BluetoothError.characteristicNotFound
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) in
            delegate.readContinuation = continuation
            cbPeripheral.readValue(for: characteristic)
        }
    }

    /// Writes a value to the specified characteristic.
    ///
    /// - Parameters:
    ///   - id: The UUID string of the characteristic to write to.
    ///   - serviceID: The UUID string of the service containing the characteristic.
    ///   - value: The data to write.
    /// - Throws: An error if the write operation fails.
    public func writeCharacteristic(id: String, serviceID: String, value: Data) async throws {
        guard let cbPeripheral = connectedCBPeripheral else {
            throw BluetoothError.notConnected
        }
        guard let characteristic = findCharacteristic(id: id, serviceID: serviceID, on: cbPeripheral) else {
            throw BluetoothError.characteristicNotFound
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.writeContinuation = continuation
            cbPeripheral.writeValue(value, for: characteristic, type: .withResponse)
        }
    }

    /// Enables or disables notifications for the specified characteristic.
    ///
    /// - Parameters:
    ///   - enabled: Whether to enable or disable notifications.
    ///   - characteristicID: The UUID string of the characteristic.
    ///   - serviceID: The UUID string of the service containing the characteristic.
    /// - Throws: An error if the operation fails.
    public func setNotify(enabled: Bool, characteristicID: String, serviceID: String) async throws {
        guard let cbPeripheral = connectedCBPeripheral else {
            throw BluetoothError.notConnected
        }
        guard let characteristic = findCharacteristic(id: characteristicID, serviceID: serviceID, on: cbPeripheral) else {
            throw BluetoothError.characteristicNotFound
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.notifyContinuation = continuation
            cbPeripheral.setNotifyValue(enabled, for: characteristic)
        }
    }

    // MARK: - Internal Helpers

    fileprivate func updateState(_ cbState: CBManagerState) {
        state = switch cbState {
        case .unknown: .unknown
        case .resetting: .resetting
        case .unsupported: .unsupported
        case .unauthorized: .unauthorized
        case .poweredOff: .poweredOff
        case .poweredOn: .poweredOn
        @unknown default: .unknown
        }
    }

    fileprivate func addDiscoveredPeripheral(_ cbPeripheral: CBPeripheral, rssi: NSNumber) {
        let id = cbPeripheral.identifier
        cbPeripherals[id] = cbPeripheral
        let peripheral = PrismPeripheral(
            id: id,
            name: cbPeripheral.name,
            rssi: rssi.intValue,
            isConnected: false
        )
        if !discoveredPeripherals.contains(where: { $0.id == id }) {
            discoveredPeripherals.append(peripheral)
        }
    }

    private var connectedCBPeripheral: CBPeripheral? {
        guard let id = connectedPeripheral?.id else { return nil }
        return cbPeripherals[id]
    }

    private func findCharacteristic(id: String, serviceID: String, on peripheral: CBPeripheral) -> CBCharacteristic? {
        let serviceUUID = CBUUID(string: serviceID)
        let charUUID = CBUUID(string: id)
        return peripheral.services?
            .first(where: { $0.uuid == serviceUUID })?
            .characteristics?
            .first(where: { $0.uuid == charUUID })
    }
}

// MARK: - Bluetooth Errors

/// Errors that can occur during Bluetooth operations.
private enum BluetoothError: Error, Sendable {
    case peripheralNotFound
    case notConnected
    case characteristicNotFound
}

// MARK: - Bluetooth Delegate

/// Internal delegate that bridges CoreBluetooth callbacks to the PrismBluetoothClient.
///
/// Uses continuations to convert delegate-based APIs into async/await calls.
private final class BluetoothDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, @unchecked Sendable {
    private weak var client: PrismBluetoothClient?

    var connectContinuation: CheckedContinuation<Void, Error>?
    var servicesContinuation: CheckedContinuation<[PrismBLEService], Error>?
    var readContinuation: CheckedContinuation<Data?, Error>?
    var writeContinuation: CheckedContinuation<Void, Error>?
    var notifyContinuation: CheckedContinuation<Void, Error>?

    init(client: PrismBluetoothClient) {
        self.client = client
    }

    // MARK: CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        Task { @MainActor in
            self.client?.updateState(state)
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        nonisolated(unsafe) let p = peripheral
        let rssi = RSSI
        Task { @MainActor in
            self.client?.addDiscoveredPeripheral(p, rssi: rssi)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            self.connectContinuation?.resume()
            self.connectContinuation = nil
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let err = error
        Task { @MainActor in
            self.connectContinuation?.resume(throwing: err ?? BluetoothError.peripheralNotFound)
            self.connectContinuation = nil
        }
    }

    // MARK: CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        nonisolated(unsafe) let p = peripheral
        let err = error
        Task { @MainActor in
            if let err {
                self.servicesContinuation?.resume(throwing: err)
                self.servicesContinuation = nil
                return
            }
            let services = p.services ?? []
            if services.isEmpty {
                self.servicesContinuation?.resume(returning: [])
                self.servicesContinuation = nil
                return
            }
            for service in services {
                p.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        nonisolated(unsafe) let p = peripheral
        let err = error
        Task { @MainActor in
            if let err {
                self.servicesContinuation?.resume(throwing: err)
                self.servicesContinuation = nil
                return
            }
            let allServices = p.services ?? []
            let allDiscovered = allServices.allSatisfy { $0.characteristics != nil }
            guard allDiscovered else { return }

            let prismServices = allServices.map { service in
                let chars = (service.characteristics ?? []).map { char in
                    PrismBLECharacteristic(
                        id: char.uuid.uuidString,
                        value: char.value,
                        isNotifying: char.isNotifying,
                        properties: PrismCharacteristicProperties(cbProperties: char.properties)
                    )
                }
                return PrismBLEService(
                    id: service.uuid.uuidString,
                    name: nil,
                    characteristics: chars
                )
            }
            self.servicesContinuation?.resume(returning: prismServices)
            self.servicesContinuation = nil
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let value = characteristic.value
        let err = error
        Task { @MainActor in
            if let err {
                self.readContinuation?.resume(throwing: err)
            } else {
                self.readContinuation?.resume(returning: value)
            }
            self.readContinuation = nil
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let err = error
        Task { @MainActor in
            if let err {
                self.writeContinuation?.resume(throwing: err)
            } else {
                self.writeContinuation?.resume()
            }
            self.writeContinuation = nil
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let err = error
        Task { @MainActor in
            if let err {
                self.notifyContinuation?.resume(throwing: err)
            } else {
                self.notifyContinuation?.resume()
            }
            self.notifyContinuation = nil
        }
    }
}

// MARK: - Private Extensions

private extension PrismCharacteristicProperties {
    init(cbProperties: CBCharacteristicProperties) {
        var props = PrismCharacteristicProperties()
        if cbProperties.contains(.read) { props.insert(.read) }
        if cbProperties.contains(.write) { props.insert(.write) }
        if cbProperties.contains(.writeWithoutResponse) { props.insert(.writeWithoutResponse) }
        if cbProperties.contains(.notify) { props.insert(.notify) }
        if cbProperties.contains(.indicate) { props.insert(.indicate) }
        self = props
    }
}
#endif
