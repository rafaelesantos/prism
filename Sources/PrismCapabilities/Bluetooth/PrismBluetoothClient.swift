import Foundation

#if canImport(CoreBluetooth)
    import CoreBluetooth

    // MARK: - Bluetooth Client

    @MainActor
    @Observable
    public final class PrismBluetoothClient: NSObject {
        public private(set) var state: PrismBluetoothState = .unknown
        public private(set) var discoveredPeripherals: [PrismPeripheral] = []
        public private(set) var connectedPeripheral: PrismPeripheral? = nil

        private var centralManager: CBCentralManager!
        private var delegate: BluetoothDelegate!
        private var cbPeripherals: [UUID: CBPeripheral] = [:]

        public override init() {
            super.init()
            delegate = BluetoothDelegate(client: self)
            centralManager = CBCentralManager(delegate: delegate, queue: .main)
        }

        public func startScanning(serviceUUIDs: [String]? = nil) {
            let cbuuids = serviceUUIDs?.map { CBUUID(string: $0) }
            discoveredPeripherals = []
            cbPeripherals = [:]
            centralManager.scanForPeripherals(withServices: cbuuids)
        }

        public func stopScanning() {
            centralManager.stopScan()
        }

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

        public func disconnect(peripheral: PrismPeripheral) {
            guard let cbPeripheral = cbPeripherals[peripheral.id] else { return }
            centralManager.cancelPeripheralConnection(cbPeripheral)
            if connectedPeripheral?.id == peripheral.id {
                connectedPeripheral = nil
            }
        }

        public func discoverServices(peripheral: PrismPeripheral) async throws -> [PrismBLEService] {
            guard let cbPeripheral = cbPeripherals[peripheral.id] else {
                throw BluetoothError.peripheralNotFound
            }
            return try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<[PrismBLEService], Error>) in
                delegate.servicesContinuation = continuation
                cbPeripheral.delegate = delegate
                cbPeripheral.discoverServices(nil)
            }
        }

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

        public func setNotify(enabled: Bool, characteristicID: String, serviceID: String) async throws {
            guard let cbPeripheral = connectedCBPeripheral else {
                throw BluetoothError.notConnected
            }
            guard let characteristic = findCharacteristic(id: characteristicID, serviceID: serviceID, on: cbPeripheral)
            else {
                throw BluetoothError.characteristicNotFound
            }
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                delegate.notifyContinuation = continuation
                cbPeripheral.setNotifyValue(enabled, for: characteristic)
            }
        }

        // MARK: - Internal Helpers

        package func updateState(_ cbState: CBManagerState) {
            state =
                switch cbState {
                case .unknown: .unknown
                case .resetting: .resetting
                case .unsupported: .unsupported
                case .unauthorized: .unauthorized
                case .poweredOff: .poweredOff
                case .poweredOn: .poweredOn
                @unknown default: .unknown
                }
        }

        package func addDiscoveredPeripheral(_ cbPeripheral: CBPeripheral, rssi: NSNumber) {
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

        private func findCharacteristic(id: String, serviceID: String, on peripheral: CBPeripheral) -> CBCharacteristic?
        {
            let serviceUUID = CBUUID(string: serviceID)
            let charUUID = CBUUID(string: id)
            return peripheral.services?
                .first(where: { $0.uuid == serviceUUID })?
                .characteristics?
                .first(where: { $0.uuid == charUUID })
        }
    }
#endif
