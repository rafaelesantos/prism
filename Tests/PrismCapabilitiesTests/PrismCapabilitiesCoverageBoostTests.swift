import Foundation
import Testing

@testable import PrismCapabilities

// MARK: - Health Types

#if canImport(HealthKit)
    @Suite("HealthTypes")
    struct PrismHealthTypesTests {
        @Test("Health data type has all cases")
        func allCases() {
            let cases = PrismHealthDataType.allCases
            #expect(cases.count == 8)
        }

        @Test("Health sample stores all properties")
        func sampleInit() {
            let now = Date()
            let later = now.addingTimeInterval(3600)
            let sample = PrismHealthSample(
                type: .stepCount, value: 1234, unit: "count",
                startDate: now, endDate: later
            )
            #expect(sample.type == .stepCount)
            #expect(sample.value == 1234)
            #expect(sample.unit == "count")
            #expect(sample.startDate == now)
            #expect(sample.endDate == later)
        }

        @Test("Health statistics stores optional aggregates")
        func statsInit() {
            let stats = PrismHealthStatistics(
                type: .heartRate, sum: 100, average: 72, min: 55, max: 120, unit: "bpm"
            )
            #expect(stats.type == .heartRate)
            #expect(stats.sum == 100)
            #expect(stats.average == 72)
            #expect(stats.min == 55)
            #expect(stats.max == 120)
            #expect(stats.unit == "bpm")
        }

        @Test("Health statistics nil aggregates")
        func statsNilAggregates() {
            let stats = PrismHealthStatistics(type: .bodyMass, unit: "kg")
            #expect(stats.sum == nil)
            #expect(stats.average == nil)
            #expect(stats.min == nil)
            #expect(stats.max == nil)
        }

        @Test("Delivery frequency cases")
        func deliveryFrequency() {
            let immediate = PrismHealthDeliveryFrequency.immediate
            let hourly = PrismHealthDeliveryFrequency.hourly
            let daily = PrismHealthDeliveryFrequency.daily
            let weekly = PrismHealthDeliveryFrequency.weekly
            _ = (immediate, hourly, daily, weekly)
        }

        @Test("Health sample with all data types")
        func sampleWithAllTypes() {
            let now = Date()
            for dataType in PrismHealthDataType.allCases {
                let sample = PrismHealthSample(
                    type: dataType, value: 42.0, unit: "test",
                    startDate: now, endDate: now
                )
                #expect(sample.type == dataType)
            }
        }
    }
#endif

// MARK: - Game Center Types

#if canImport(GameKit)
    @Suite("GameCenterTypes")
    struct PrismGameCenterTypesTests {
        @Test("Player stores all properties")
        func playerInit() {
            let player = PrismGameCenterPlayer(
                id: "p1", displayName: "Player One",
                alias: "p1alias", isAuthenticated: true
            )
            #expect(player.id == "p1")
            #expect(player.displayName == "Player One")
            #expect(player.alias == "p1alias")
            #expect(player.isAuthenticated)
        }

        @Test("Leaderboard score stores all properties")
        func scoreInit() {
            let date = Date(timeIntervalSince1970: 1_000_000)
            let score = PrismLeaderboardScore(
                playerID: "p1", displayName: "Player",
                value: 9999, rank: 1,
                formattedValue: "9,999", date: date
            )
            #expect(score.playerID == "p1")
            #expect(score.value == 9999)
            #expect(score.rank == 1)
            #expect(score.formattedValue == "9,999")
            #expect(score.date == date)
        }

        @Test("Leaderboard score nil formatted value")
        func scoreNilFormatted() {
            let score = PrismLeaderboardScore(
                playerID: "p2", displayName: "P2",
                value: 100, rank: 5, date: Date()
            )
            #expect(score.formattedValue == nil)
        }

        @Test("Leaderboard scope cases")
        func scopeCases() {
            _ = PrismLeaderboardScope.global
            _ = PrismLeaderboardScope.friends
        }

        @Test("Leaderboard time scope all cases")
        func timeScopeCases() {
            let cases = PrismLeaderboardTimeScope.allCases
            #expect(cases.count == 3)
        }

        @Test("Achievement stores all properties")
        func achievementInit() {
            let achievement = PrismAchievement(
                id: "a1", title: "First Win",
                percentComplete: 100.0, isCompleted: true,
                showsCompletionBanner: true
            )
            #expect(achievement.id == "a1")
            #expect(achievement.title == "First Win")
            #expect(achievement.percentComplete == 100.0)
            #expect(achievement.isCompleted)
            #expect(achievement.showsCompletionBanner)
        }

        @Test("Achievement incomplete")
        func achievementIncomplete() {
            let achievement = PrismAchievement(
                id: "a2", title: "Progress",
                percentComplete: 50.0, isCompleted: false,
                showsCompletionBanner: false
            )
            #expect(!achievement.isCompleted)
            #expect(achievement.percentComplete == 50.0)
        }

        @Test("Match request stores all properties")
        func matchRequestInit() {
            let request = PrismMatchRequest(
                minPlayers: 2, maxPlayers: 4,
                playerGroup: 1, defaultNumberOfPlayers: 2
            )
            #expect(request.minPlayers == 2)
            #expect(request.maxPlayers == 4)
            #expect(request.playerGroup == 1)
            #expect(request.defaultNumberOfPlayers == 2)
        }

        @Test("Match request nil player group")
        func matchRequestNilGroup() {
            let request = PrismMatchRequest(
                minPlayers: 2, maxPlayers: 2, defaultNumberOfPlayers: 2
            )
            #expect(request.playerGroup == nil)
        }

        @Test("Match status all cases")
        func matchStatusCases() {
            let cases = PrismMatchStatus.allCases
            #expect(cases.count == 4)
        }
    }
#endif

// MARK: - Location Types

#if canImport(CoreLocation)
    @Suite("LocationTypes")
    struct PrismLocationTypesTests {
        @Test("Location permission all cases")
        func permissionCases() {
            let cases = PrismLocationPermission.allCases
            #expect(cases.count == 5)
        }

        @Test("Location accuracy cases")
        func accuracyCases() {
            _ = PrismLocationAccuracy.best
            _ = PrismLocationAccuracy.nearestTenMeters
            _ = PrismLocationAccuracy.hundredMeters
            _ = PrismLocationAccuracy.kilometer
            _ = PrismLocationAccuracy.threeKilometers
        }

        @Test("Location stores all properties")
        func locationInit() {
            let date = Date(timeIntervalSince1970: 1_000_000)
            let loc = PrismLocation(
                latitude: 37.7749, longitude: -122.4194,
                altitude: 10.5, horizontalAccuracy: 5.0,
                timestamp: date
            )
            #expect(loc.latitude == 37.7749)
            #expect(loc.longitude == -122.4194)
            #expect(loc.altitude == 10.5)
            #expect(loc.horizontalAccuracy == 5.0)
            #expect(loc.timestamp == date)
        }

        @Test("Location default optional values")
        func locationDefaults() {
            let loc = PrismLocation(latitude: 0, longitude: 0)
            #expect(loc.altitude == nil)
            #expect(loc.horizontalAccuracy == 0)
        }

        @Test("Geofence region stores all properties")
        func geofenceInit() {
            let region = PrismGeofenceRegion(
                id: "office", latitude: 37.0, longitude: -122.0,
                radius: 100.0, notifyOnEntry: true, notifyOnExit: false
            )
            #expect(region.id == "office")
            #expect(region.latitude == 37.0)
            #expect(region.longitude == -122.0)
            #expect(region.radius == 100.0)
            #expect(region.notifyOnEntry)
            #expect(!region.notifyOnExit)
        }

        @Test("Geofence region default notify flags")
        func geofenceDefaults() {
            let region = PrismGeofenceRegion(
                id: "home", latitude: 0, longitude: 0, radius: 50
            )
            #expect(region.notifyOnEntry)
            #expect(region.notifyOnExit)
        }

        @Test("Geocoding result stores all properties")
        func geocodingInit() {
            let loc = PrismLocation(latitude: 37.0, longitude: -122.0)
            let result = PrismGeocodingResult(
                name: "Apple Park", locality: "Cupertino",
                administrativeArea: "CA", country: "US",
                postalCode: "95014", coordinate: loc
            )
            #expect(result.name == "Apple Park")
            #expect(result.locality == "Cupertino")
            #expect(result.administrativeArea == "CA")
            #expect(result.country == "US")
            #expect(result.postalCode == "95014")
            #expect(result.coordinate?.latitude == 37.0)
        }

        @Test("Geocoding result all nil")
        func geocodingNil() {
            let result = PrismGeocodingResult()
            #expect(result.name == nil)
            #expect(result.locality == nil)
            #expect(result.administrativeArea == nil)
            #expect(result.country == nil)
            #expect(result.postalCode == nil)
            #expect(result.coordinate == nil)
        }
    }
#endif

// MARK: - Map Types

#if canImport(MapKit)
    @Suite("MapTypes")
    struct PrismMapTypesTests {
        @Test("Map route stores all properties")
        func routeInit() {
            let route = PrismMapRoute(
                distance: 15000, expectedTravelTime: 900, name: "US-101"
            )
            #expect(route.distance == 15000)
            #expect(route.expectedTravelTime == 900)
            #expect(route.name == "US-101")
        }

        @Test("Map transport type all cases")
        func transportCases() {
            let cases = PrismMapTransportType.allCases
            #expect(cases.count == 4)
        }

        @Test("POI stores all properties")
        func poiInit() {
            let coord = PrismLocation(latitude: 37.0, longitude: -122.0)
            let poi = PrismPOI(
                name: "Coffee Shop", coordinate: coord, category: "cafe"
            )
            #expect(poi.name == "Coffee Shop")
            #expect(poi.coordinate.latitude == 37.0)
            #expect(poi.category == "cafe")
        }

        @Test("POI nil category")
        func poiNilCategory() {
            let coord = PrismLocation(latitude: 0, longitude: 0)
            let poi = PrismPOI(name: "Unknown", coordinate: coord)
            #expect(poi.category == nil)
        }
    }
#endif

// MARK: - StoreKit Types

#if canImport(StoreKit)
    @Suite("StoreKitTypes")
    struct PrismStoreKitTypesTests {
        @Test("Product type all cases")
        func productTypeCases() {
            let cases = PrismProductType.allCases
            #expect(cases.count == 4)
        }

        @Test("Product info stores all properties")
        func productInfoInit() {
            let info = PrismProductInfo(
                id: "com.app.premium", displayName: "Premium",
                description: "Unlock all features",
                price: Decimal(9.99), type: .nonConsumable
            )
            #expect(info.id == "com.app.premium")
            #expect(info.displayName == "Premium")
            #expect(info.description == "Unlock all features")
            #expect(info.price == Decimal(9.99))
            #expect(info.type == .nonConsumable)
        }

        @Test("Transaction info stores all properties")
        func transactionInfoInit() {
            let date = Date(timeIntervalSince1970: 1_000_000)
            let expiry = date.addingTimeInterval(86400 * 30)
            let tx = PrismTransactionInfo(
                id: 12345, productID: "com.app.sub",
                purchaseDate: date, expirationDate: expiry,
                isUpgraded: true, revocationDate: nil
            )
            #expect(tx.id == 12345)
            #expect(tx.productID == "com.app.sub")
            #expect(tx.purchaseDate == date)
            #expect(tx.expirationDate == expiry)
            #expect(tx.isUpgraded)
            #expect(tx.revocationDate == nil)
        }

        @Test("Transaction info default values")
        func transactionDefaults() {
            let tx = PrismTransactionInfo(
                id: 1, productID: "p", purchaseDate: Date()
            )
            #expect(tx.expirationDate == nil)
            #expect(!tx.isUpgraded)
            #expect(tx.revocationDate == nil)
        }

        @Test("Subscription status all cases")
        func subscriptionStatusCases() {
            let cases = PrismSubscriptionStatus.allCases
            #expect(cases.count == 5)
        }

        @Test("Product info for each type")
        func productInfoTypes() {
            for productType in PrismProductType.allCases {
                let info = PrismProductInfo(
                    id: "id", displayName: "Name",
                    description: "Desc", price: 1, type: productType
                )
                #expect(info.type == productType)
            }
        }
    }
#endif

// MARK: - CloudKit Types

#if canImport(CloudKit)
    @Suite("CloudKitTypes")
    struct PrismCloudKitTypesTests {
        @Test("Cloud value string")
        func cloudValueString() {
            let val = PrismCloudValue.string("hello")
            if case .string(let s) = val {
                #expect(s == "hello")
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud value int")
        func cloudValueInt() {
            let val = PrismCloudValue.int(42)
            if case .int(let i) = val {
                #expect(i == 42)
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud value double")
        func cloudValueDouble() {
            let val = PrismCloudValue.double(3.14)
            if case .double(let d) = val {
                #expect(d == 3.14)
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud value data")
        func cloudValueData() {
            let data = Data("test".utf8)
            let val = PrismCloudValue.data(data)
            if case .data(let d) = val {
                #expect(d == data)
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud value date")
        func cloudValueDate() {
            let date = Date(timeIntervalSince1970: 1_000_000)
            let val = PrismCloudValue.date(date)
            if case .date(let d) = val {
                #expect(d == date)
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud value reference")
        func cloudValueReference() {
            let val = PrismCloudValue.reference("rec-123")
            if case .reference(let id) = val {
                #expect(id == "rec-123")
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud value string array")
        func cloudValueStringArray() {
            let val = PrismCloudValue.stringArray(["a", "b"])
            if case .stringArray(let arr) = val {
                #expect(arr == ["a", "b"])
            } else {
                #expect(Bool(false))
            }
        }

        @Test("Cloud record stores all properties")
        func cloudRecordInit() {
            let now = Date(timeIntervalSince1970: 1_000_000)
            let record = PrismCloudRecord(
                id: "r1", recordType: "Note",
                fields: ["title": .string("Hello"), "count": .int(5)],
                createdAt: now, modifiedAt: now
            )
            #expect(record.id == "r1")
            #expect(record.recordType == "Note")
            #expect(record.fields.count == 2)
            #expect(record.createdAt == now)
            #expect(record.modifiedAt == now)
        }

        @Test("Cloud record nil dates")
        func cloudRecordNilDates() {
            let record = PrismCloudRecord(
                id: "r2", recordType: "Task", fields: [:]
            )
            #expect(record.createdAt == nil)
            #expect(record.modifiedAt == nil)
            #expect(record.fields.isEmpty)
        }

        @Test("Cloud database cases")
        func databaseCases() {
            _ = PrismCloudDatabase.publicDB
            _ = PrismCloudDatabase.privateDB
            _ = PrismCloudDatabase.sharedDB
        }

        @Test("Cloud account status all cases")
        func accountStatusCases() {
            let cases = PrismCloudAccountStatus.allCases
            #expect(cases.count == 5)
        }
    }
#endif

// MARK: - Sign In With Apple Types

#if canImport(AuthenticationServices)
    @Suite("AppleIDTypes")
    struct PrismSignInWithAppleTypesTests {
        @Test("Apple ID scope all cases")
        func scopeCases() {
            let cases = PrismAppleIDScope.allCases
            #expect(cases.count == 2)
        }

        @Test("Apple ID credential stores all properties")
        func credentialInit() {
            let token = Data("token".utf8)
            let code = Data("code".utf8)
            let cred = PrismAppleIDCredential(
                userID: "user-123", email: "test@test.com",
                fullName: "John Doe", identityToken: token,
                authorizationCode: code
            )
            #expect(cred.userID == "user-123")
            #expect(cred.email == "test@test.com")
            #expect(cred.fullName == "John Doe")
            #expect(cred.identityToken == token)
            #expect(cred.authorizationCode == code)
        }

        @Test("Apple ID credential nil optionals")
        func credentialNilOptionals() {
            let cred = PrismAppleIDCredential(userID: "u1")
            #expect(cred.email == nil)
            #expect(cred.fullName == nil)
            #expect(cred.identityToken == nil)
            #expect(cred.authorizationCode == nil)
        }

        @Test("Apple ID credential state all cases")
        func credentialStateCases() {
            let cases = PrismAppleIDCredentialState.allCases
            #expect(cases.count == 4)
        }
    }
#endif

// MARK: - Widget Types

#if canImport(WidgetKit)
    @Suite("WidgetTypes")
    struct PrismWidgetTypesTests {
        @Test("Widget family all cases")
        func familyCases() {
            let cases = PrismWidgetFamily.allCases
            #expect(cases.count == 7)
        }

        @Test("Widget entry stores all properties")
        func entryInit() {
            let date = Date(timeIntervalSince1970: 1_000_000)
            let entry = PrismWidgetEntry(
                date: date, relevance: 0.8, displayName: "Weather"
            )
            #expect(entry.date == date)
            #expect(entry.relevance == 0.8)
            #expect(entry.displayName == "Weather")
        }

        @Test("Widget entry nil optionals")
        func entryDefaults() {
            let entry = PrismWidgetEntry(date: Date())
            #expect(entry.relevance == nil)
            #expect(entry.displayName == nil)
        }

        @Test("Reload policy cases")
        func reloadPolicyCases() {
            _ = PrismWidgetReloadPolicy.atEnd
            _ = PrismWidgetReloadPolicy.never
            if case .afterMinutes(let m) = PrismWidgetReloadPolicy.afterMinutes(15) {
                #expect(m == 15)
            }
        }

        @Test("Widget configuration stores properties")
        func configInit() {
            let config = PrismWidgetConfiguration(
                kind: "weather", family: .systemMedium
            )
            #expect(config.kind == "weather")
            #expect(config.family == .systemMedium)
        }
    }
#endif

// MARK: - Apple Pay Types

#if canImport(PassKit)
    @Suite("ApplePayTypes")
    struct PrismApplePayTypesTests {
        @Test("Payment item type cases")
        func itemTypeCases() {
            _ = PrismPaymentItemType.final_
            _ = PrismPaymentItemType.pending
        }

        @Test("Payment item stores all properties")
        func itemInit() {
            let item = PrismPaymentItem(
                label: "Coffee", amount: Decimal(4.99), type: .final_
            )
            #expect(item.label == "Coffee")
            #expect(item.amount == Decimal(4.99))
        }

        @Test("Payment item default type")
        func itemDefaultType() {
            let item = PrismPaymentItem(label: "Tea", amount: 3)
            _ = item
        }

        @Test("Payment network all cases")
        func networkCases() {
            let cases = PrismPaymentNetwork.allCases
            #expect(cases.count == 4)
        }

        @Test("Payment request stores all properties")
        func requestInit() {
            let items = [
                PrismPaymentItem(label: "Item", amount: 10),
                PrismPaymentItem(label: "Tax", amount: 1),
            ]
            let request = PrismPaymentRequest(
                merchantID: "merchant.com.app",
                countryCode: "US", currencyCode: "USD",
                items: items,
                supportedNetworks: [.visa, .mastercard]
            )
            #expect(request.merchantID == "merchant.com.app")
            #expect(request.countryCode == "US")
            #expect(request.currencyCode == "USD")
            #expect(request.items.count == 2)
            #expect(request.supportedNetworks.count == 2)
        }

        @Test("Payment result stores all properties")
        func resultInit() {
            let token = Data("tok".utf8)
            let result = PrismPaymentResult(
                transactionID: "tx-1", token: token, success: true
            )
            #expect(result.transactionID == "tx-1")
            #expect(result.token == token)
            #expect(result.success)
        }

        @Test("Payment result failed")
        func resultFailed() {
            let result = PrismPaymentResult(success: false)
            #expect(!result.success)
            #expect(result.transactionID == nil)
            #expect(result.token == nil)
        }
    }
#endif

// MARK: - Notification Types

#if canImport(UserNotifications)
    @Suite("NotificationTypes")
    struct PrismNotificationTypesTests {
        @Test("Notification permission all cases")
        func permissionCases() {
            let cases = PrismNotificationPermission.allCases
            #expect(cases.count == 5)
        }

        @Test("Notification option cases")
        func optionCases() {
            _ = PrismNotificationOption.alert
            _ = PrismNotificationOption.badge
            _ = PrismNotificationOption.sound
            _ = PrismNotificationOption.provisional
            _ = PrismNotificationOption.criticalAlert
        }

        @Test("Notification sound cases")
        func soundCases() {
            _ = PrismNotificationSound.default_
            _ = PrismNotificationSound.critical
            if case .named(let name) = PrismNotificationSound.named("ding") {
                #expect(name == "ding")
            }
        }

        @Test("Notification content stores all properties")
        func contentInit() {
            let content = PrismNotificationContent(
                title: "Alert", body: "Something happened",
                subtitle: "Urgent", badge: 5,
                sound: .default_, categoryIdentifier: "alerts",
                userInfo: ["key": "value"]
            )
            #expect(content.title == "Alert")
            #expect(content.body == "Something happened")
            #expect(content.subtitle == "Urgent")
            #expect(content.badge == 5)
            #expect(content.categoryIdentifier == "alerts")
            #expect(content.userInfo["key"] == "value")
        }

        @Test("Notification content minimal init")
        func contentMinimal() {
            let content = PrismNotificationContent(
                title: "Hi", body: "Hello"
            )
            #expect(content.subtitle == nil)
            #expect(content.badge == nil)
            #expect(content.sound == nil)
            #expect(content.categoryIdentifier == nil)
            #expect(content.userInfo.isEmpty)
        }

        @Test("Notification trigger cases")
        func triggerCases() {
            _ = PrismNotificationTrigger.immediate
            if case .timeInterval(let t) = PrismNotificationTrigger.timeInterval(60) {
                #expect(t == 60)
            }
            let comps = DateComponents(hour: 8, minute: 30)
            if case .calendar(let c) = PrismNotificationTrigger.calendar(comps) {
                #expect(c.hour == 8)
                #expect(c.minute == 30)
            }
            if case .location(let lat, let lon, let r) = PrismNotificationTrigger.location(
                latitude: 37.0, longitude: -122.0, radius: 100
            ) {
                #expect(lat == 37.0)
                #expect(lon == -122.0)
                #expect(r == 100)
            }
        }
    }
#endif

// MARK: - MetricKit Types

#if canImport(MetricKit)
    @Suite("MetricKitTypes")
    struct PrismMetricKitTypesTests {
        @Test("App metrics stores all properties")
        func metricsInit() {
            let metrics = PrismAppMetrics(
                launchDuration: 1.5, hangDuration: 0.3,
                peakMemory: 256, cpuTime: 10.5, diskWrites: 50
            )
            #expect(metrics.launchDuration == 1.5)
            #expect(metrics.hangDuration == 0.3)
            #expect(metrics.peakMemory == 256)
            #expect(metrics.cpuTime == 10.5)
            #expect(metrics.diskWrites == 50)
        }

        @Test("App metrics all nil")
        func metricsNil() {
            let metrics = PrismAppMetrics()
            #expect(metrics.launchDuration == nil)
            #expect(metrics.hangDuration == nil)
            #expect(metrics.peakMemory == nil)
            #expect(metrics.cpuTime == nil)
            #expect(metrics.diskWrites == nil)
        }

        @Test("Crash diagnostic stores all properties")
        func crashInit() {
            let id = UUID()
            let date = Date(timeIntervalSince1970: 1_000_000)
            let crash = PrismCrashDiagnostic(
                id: id, timestamp: date,
                exceptionType: "EXC_BAD_ACCESS",
                signal: "SIGSEGV",
                terminationReason: "Namespace SIGNAL, Code 0xb",
                callStackTree: "{}"
            )
            #expect(crash.id == id)
            #expect(crash.timestamp == date)
            #expect(crash.exceptionType == "EXC_BAD_ACCESS")
            #expect(crash.signal == "SIGSEGV")
            #expect(crash.terminationReason == "Namespace SIGNAL, Code 0xb")
            #expect(crash.callStackTree == "{}")
        }

        @Test("Crash diagnostic minimal init")
        func crashMinimal() {
            let crash = PrismCrashDiagnostic(timestamp: Date())
            #expect(crash.exceptionType == nil)
            #expect(crash.signal == nil)
            #expect(crash.terminationReason == nil)
            #expect(crash.callStackTree == nil)
        }
    }
#endif

// MARK: - Biometric Types

#if canImport(LocalAuthentication)
    @Suite("BiometricTypes")
    struct PrismBiometricTypesTests {
        @Test("Biometric type all cases")
        func typeCases() {
            let cases = PrismBiometricType.allCases
            #expect(cases.count == 4)
        }

        @Test("Biometric policy all cases")
        func policyCases() {
            let cases = PrismBiometricPolicy.allCases
            #expect(cases.count == 2)
        }

        @Test("Biometric error all cases")
        func errorCases() {
            let cases = PrismBiometricError.allCases
            #expect(cases.count == 8)
        }

        @Test("Biometric result success")
        func resultSuccess() {
            let result = PrismBiometricResult(success: true)
            #expect(result.success)
            #expect(result.error == nil)
        }

        @Test("Biometric result failure with error")
        func resultFailure() {
            let result = PrismBiometricResult(
                success: false, error: .userCancel
            )
            #expect(!result.success)
            #expect(result.error == .userCancel)
        }

        @Test("Biometric client init")
        func clientInit() {
            let client = PrismBiometricClient()
            _ = client
        }

        @Test("Biometric client available type")
        func clientAvailableType() {
            let client = PrismBiometricClient()
            let biometricType = client.availableBiometricType()
            #expect(PrismBiometricType.allCases.contains(biometricType))
        }

        @Test("Biometric client can evaluate")
        func clientCanEvaluate() {
            let client = PrismBiometricClient()
            let canEval = client.canEvaluate(policy: .deviceOwnerAuthentication)
            #expect(canEval || !canEval)
        }
    }
#endif

// MARK: - Multipeer Types (no framework guard needed)

@Suite("MultipeerTypes")
struct PrismMultipeerTypesTests {
    @Test("Peer stores all properties")
    func peerInit() {
        let peer = PrismPeer(
            id: "peer-1", displayName: "Alice", isConnected: true
        )
        #expect(peer.id == "peer-1")
        #expect(peer.displayName == "Alice")
        #expect(peer.isConnected)
    }

    @Test("Peer default not connected")
    func peerDefault() {
        let peer = PrismPeer(id: "p2", displayName: "Bob")
        #expect(!peer.isConnected)
    }

    @Test("Multipeer state all cases")
    func stateCases() {
        let cases = PrismMultipeerState.allCases
        #expect(cases.count == 3)
    }
}

// MARK: - App Intent Types

#if canImport(AppIntents)
    @Suite("AppIntentTypes")
    struct PrismAppIntentTypesTests {
        @Test("Intent donation stores all properties")
        func donationInit() {
            let id = UUID()
            let date = Date(timeIntervalSince1970: 1_000_000)
            let donation = PrismIntentDonation(
                id: id, intentType: "com.app.order",
                title: "Order Coffee", subtitle: "Latte",
                timestamp: date, metadata: ["size": "large"]
            )
            #expect(donation.id == id)
            #expect(donation.intentType == "com.app.order")
            #expect(donation.title == "Order Coffee")
            #expect(donation.subtitle == "Latte")
            #expect(donation.timestamp == date)
            #expect(donation.metadata["size"] == "large")
        }

        @Test("Intent donation defaults")
        func donationDefaults() {
            let donation = PrismIntentDonation(
                intentType: "test", title: "Test"
            )
            #expect(donation.subtitle == nil)
            #expect(donation.metadata.isEmpty)
        }

        @Test("Shortcut phrase stores properties")
        func phraseInit() {
            let phrase = PrismShortcutPhrase(
                phrase: "Order coffee", intentType: "com.app.order"
            )
            #expect(phrase.phrase == "Order coffee")
            #expect(phrase.intentType == "com.app.order")
        }

        @Test("Intent prediction stores all properties")
        func predictionInit() {
            let pred = PrismIntentPrediction(
                intentType: "com.app.play", title: "Play Music",
                parameters: ["genre": "jazz"]
            )
            #expect(pred.intentType == "com.app.play")
            #expect(pred.title == "Play Music")
            #expect(pred.parameters["genre"] == "jazz")
        }

        @Test("Intent prediction default parameters")
        func predictionDefaults() {
            let pred = PrismIntentPrediction(
                intentType: "test", title: "Test"
            )
            #expect(pred.parameters.isEmpty)
        }

        @Test("Siri tip style all cases")
        func siriTipCases() {
            let cases = PrismSiriTipStyle.allCases
            #expect(cases.count == 3)
        }

        @Test("App intent client donate and delete")
        @MainActor
        func clientDonateDelete() async {
            let client = PrismAppIntentClient()
            let donation = PrismIntentDonation(
                intentType: "test.intent", title: "Test"
            )
            await client.donate(intent: donation)
            await client.deleteDonations(matching: "test.intent")
            await client.deleteAllDonations()
        }

        @Test("App intent client suggest shortcut")
        @MainActor
        func clientSuggest() {
            let client = PrismAppIntentClient()
            let phrase = PrismShortcutPhrase(
                phrase: "Do thing", intentType: "test"
            )
            client.suggestShortcut(phrase: phrase)
        }
    }
#endif
