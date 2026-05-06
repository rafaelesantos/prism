#if canImport(CoreLocation)
    import CoreLocation
    #if canImport(MapKit)
        import MapKit
    #endif

    // MARK: - Location Permission

    public enum PrismLocationPermission: Sendable, CaseIterable {
        case notDetermined
        case restricted
        case denied
        case authorizedWhenInUse
        case authorizedAlways
    }

    // MARK: - Location Accuracy

    public enum PrismLocationAccuracy: Sendable {
        case best
        case nearestTenMeters
        case hundredMeters
        case kilometer
        case threeKilometers
    }

    // MARK: - Location

    public struct PrismLocation: Sendable {
        public let latitude: Double
        public let longitude: Double
        public let altitude: Double?
        public let horizontalAccuracy: Double
        public let timestamp: Date

        public init(
            latitude: Double, longitude: Double, altitude: Double? = nil, horizontalAccuracy: Double = 0,
            timestamp: Date = Date()
        ) {
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.horizontalAccuracy = horizontalAccuracy
            self.timestamp = timestamp
        }
    }

    // MARK: - Geofence Region

    public struct PrismGeofenceRegion: Sendable {
        public let id: String
        public let latitude: Double
        public let longitude: Double
        public let radius: Double
        public let notifyOnEntry: Bool
        public let notifyOnExit: Bool

        public init(
            id: String, latitude: Double, longitude: Double, radius: Double, notifyOnEntry: Bool = true,
            notifyOnExit: Bool = true
        ) {
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.radius = radius
            self.notifyOnEntry = notifyOnEntry
            self.notifyOnExit = notifyOnExit
        }
    }

    // MARK: - Geocoding Result

    public struct PrismGeocodingResult: Sendable {
        public let name: String?
        public let locality: String?
        public let administrativeArea: String?
        public let country: String?
        public let postalCode: String?
        public let coordinate: PrismLocation?

        public init(
            name: String? = nil, locality: String? = nil, administrativeArea: String? = nil, country: String? = nil,
            postalCode: String? = nil, coordinate: PrismLocation? = nil
        ) {
            self.name = name
            self.locality = locality
            self.administrativeArea = administrativeArea
            self.country = country
            self.postalCode = postalCode
            self.coordinate = coordinate
        }
    }

    // MARK: - Location Client

    @MainActor @Observable
    public final class PrismLocationClient: NSObject, Sendable {
        public private(set) var currentLocation: PrismLocation?
        public private(set) var permissionStatus: PrismLocationPermission = .notDetermined

        private let manager = CLLocationManager()

        private var permissionContinuation: CheckedContinuation<PrismLocationPermission, Never>?
        private var locationContinuation: CheckedContinuation<PrismLocation, any Error>?

        public override init() {
            super.init()
            manager.delegate = self
            syncPermissionStatus()
        }

        public func requestPermission(always: Bool = false) async -> PrismLocationPermission {
            if always {
                manager.requestAlwaysAuthorization()
            } else {
                manager.requestWhenInUseAuthorization()
            }
            return await withCheckedContinuation { continuation in
                permissionContinuation = continuation
            }
        }

        public func requestLocation() async throws -> PrismLocation {
            try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation
                manager.requestLocation()
            }
        }

        public func startUpdating(accuracy: PrismLocationAccuracy = .best) {
            manager.desiredAccuracy = accuracy.clAccuracy
            manager.startUpdatingLocation()
        }

        public func stopUpdating() {
            manager.stopUpdatingLocation()
        }

        public func startMonitoring(region: PrismGeofenceRegion) {
            let clRegion = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude),
                radius: region.radius,
                identifier: region.id
            )
            clRegion.notifyOnEntry = region.notifyOnEntry
            clRegion.notifyOnExit = region.notifyOnExit
            manager.startMonitoring(for: clRegion)
        }

        public func stopMonitoring(region: PrismGeofenceRegion) {
            let clRegion = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude),
                radius: region.radius,
                identifier: region.id
            )
            manager.stopMonitoring(for: clRegion)
        }

        public func geocode(address: String) async throws -> [PrismGeocodingResult] {
            #if canImport(MapKit)
                guard let request = MKGeocodingRequest(addressString: address) else {
                    return []
                }
                let items = try await request.mapItems
                return items.map { $0.toPrismGeocodingResult() }
            #else
                return []
            #endif
        }

        public func reverseGeocode(location: PrismLocation) async throws -> [PrismGeocodingResult] {
            #if canImport(MapKit)
                let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                guard let request = MKReverseGeocodingRequest(location: clLocation) else {
                    return []
                }
                let items = try await request.mapItems
                return items.map { $0.toPrismGeocodingResult() }
            #else
                return []
            #endif
        }

        // MARK: - Private

        private func syncPermissionStatus() {
            permissionStatus = CLLocationManager().authorizationStatus.toPrismPermission()
        }
    }

    // MARK: - CLLocationManagerDelegate

    extension PrismLocationClient: CLLocationManagerDelegate {
        public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus.toPrismPermission()
            MainActor.assumeIsolated {
                permissionStatus = status
                permissionContinuation?.resume(returning: status)
                permissionContinuation = nil
            }
        }

        public nonisolated func locationManager(
            _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
        ) {
            MainActor.assumeIsolated {
                guard let clLocation = locations.last else { return }
                let location = clLocation.toPrismLocation()
                currentLocation = location
                locationContinuation?.resume(returning: location)
                locationContinuation = nil
            }
        }

        public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
            MainActor.assumeIsolated {
                locationContinuation?.resume(throwing: error)
                locationContinuation = nil
            }
        }
    }

    // MARK: - Private Extensions

    extension CLAuthorizationStatus {
        fileprivate func toPrismPermission() -> PrismLocationPermission {
            switch self {
            case .notDetermined: .notDetermined
            case .restricted: .restricted
            case .denied: .denied
            case .authorizedWhenInUse: .authorizedWhenInUse
            case .authorizedAlways: .authorizedAlways
            @unknown default: .notDetermined
            }
        }
    }

    extension CLLocation {
        fileprivate func toPrismLocation() -> PrismLocation {
            PrismLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                timestamp: timestamp
            )
        }
    }

    #if canImport(MapKit)
        extension MKMapItem {
            fileprivate func toPrismGeocodingResult() -> PrismGeocodingResult {
                PrismGeocodingResult(
                    name: name,
                    coordinate: location.toPrismLocation()
                )
            }
        }
    #endif

    extension PrismLocationAccuracy {
        fileprivate var clAccuracy: CLLocationAccuracy {
            switch self {
            case .best: kCLLocationAccuracyBest
            case .nearestTenMeters: kCLLocationAccuracyNearestTenMeters
            case .hundredMeters: kCLLocationAccuracyHundredMeters
            case .kilometer: kCLLocationAccuracyKilometer
            case .threeKilometers: kCLLocationAccuracyThreeKilometers
            }
        }
    }
#endif
