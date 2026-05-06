#if canImport(MapKit)
    import MapKit

    // MARK: - Map Route

    public struct PrismMapRoute: Sendable {
        public let distance: Double
        public let expectedTravelTime: TimeInterval
        public let name: String

        public init(distance: Double, expectedTravelTime: TimeInterval, name: String) {
            self.distance = distance
            self.expectedTravelTime = expectedTravelTime
            self.name = name
        }
    }

    // MARK: - Map Transport Type

    public enum PrismMapTransportType: Sendable, CaseIterable {
        case automobile
        case walking
        case transit
        case cycling
    }

    // MARK: - Point of Interest

    public struct PrismPOI: Sendable {
        public let name: String
        public let coordinate: PrismLocation
        public let category: String?

        public init(name: String, coordinate: PrismLocation, category: String? = nil) {
            self.name = name
            self.coordinate = coordinate
            self.category = category
        }
    }

    // MARK: - Map Client

    public struct PrismMapClient: Sendable {

        public init() {}

        public func directions(
            from origin: PrismLocation, to destination: PrismLocation,
            transportType: PrismMapTransportType = .automobile
        ) async throws -> [PrismMapRoute] {
            let request = MKDirections.Request()
            request.source = origin.mapItem
            request.destination = destination.mapItem
            request.transportType = transportType.mkTransportType

            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            return response.routes.map { route in
                PrismMapRoute(
                    distance: route.distance,
                    expectedTravelTime: route.expectedTravelTime,
                    name: route.name
                )
            }
        }

        public func estimatedTravelTime(
            from origin: PrismLocation, to destination: PrismLocation,
            transportType: PrismMapTransportType = .automobile
        ) async throws -> TimeInterval {
            let request = MKDirections.Request()
            request.source = origin.mapItem
            request.destination = destination.mapItem
            request.transportType = transportType.mkTransportType

            let directions = MKDirections(request: request)
            let response = try await directions.calculateETA()
            return response.expectedTravelTime
        }

        public func searchPOI(query: String, near location: PrismLocation, radius: Double) async throws -> [PrismPOI] {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: location.clCoordinate,
                latitudinalMeters: radius * 2,
                longitudinalMeters: radius * 2
            )

            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems.map { item in
                PrismPOI(
                    name: item.name ?? "",
                    coordinate: PrismLocation(
                        latitude: item.location.coordinate.latitude,
                        longitude: item.location.coordinate.longitude
                    ),
                    category: item.pointOfInterestCategory?.rawValue
                )
            }
        }
    }

    // MARK: - Private Extensions

    extension PrismLocation {
        fileprivate var clCoordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        fileprivate var mapItem: MKMapItem {
            MKMapItem(location: CLLocation(latitude: latitude, longitude: longitude), address: nil)
        }
    }

    extension PrismMapTransportType {
        fileprivate var mkTransportType: MKDirectionsTransportType {
            switch self {
            case .automobile: .automobile
            case .walking: .walking
            case .transit: .transit
            case .cycling: .automobile  // MapKit does not have a dedicated cycling type
            }
        }
    }
#endif
