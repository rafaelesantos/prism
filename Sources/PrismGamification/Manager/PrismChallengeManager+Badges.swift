#if canImport(SwiftData)
    import Foundation
    import SwiftData

    extension PrismChallengeManager {

        // MARK: - Badge Registration

        public func registerBadges<B: PrismBadge>(_ badgeType: B.Type) throws {
            for badge in B.allCases {
                let id = badge.rawValue
                let descriptor = FetchDescriptor<PrismBadgeProgress>(
                    predicate: #Predicate { $0.badgeID == id }
                )
                let existing = try modelContext.fetch(descriptor)
                if existing.isEmpty {
                    let record = PrismBadgeProgress(
                        badgeID: id,
                        tierRawValue: badge.tier.rawValue
                    )
                    modelContext.insert(record)
                }
            }
            try modelContext.save()
        }

        // MARK: - Unlock

        @discardableResult
        public func unlockBadge<B: PrismBadge>(_ badge: B) throws -> PrismBadgeSnapshot {
            let record = try fetchBadgeProgress(for: badge.rawValue)

            guard !record.isUnlocked else {
                throw PrismGamificationError.badgeAlreadyUnlocked(badge.rawValue)
            }

            record.isUnlocked = true
            record.unlockedAt = .now

            eventContinuation.yield(.badgeUnlocked(badgeID: badge.rawValue, tier: badge.tier.rawValue))
            try modelContext.save()
            return record.snapshot
        }

        // MARK: - Query

        public func isBadgeUnlocked<B: PrismBadge>(_ badge: B) throws -> Bool {
            try fetchBadgeProgress(for: badge.rawValue).isUnlocked
        }

        public func badgeProgress<B: PrismBadge>(for badge: B) throws -> PrismBadgeSnapshot {
            try fetchBadgeProgress(for: badge.rawValue).snapshot
        }

        public func allBadges() throws -> [PrismBadgeSnapshot] {
            let descriptor = FetchDescriptor<PrismBadgeProgress>(
                sortBy: [SortDescriptor(\.createdAt)]
            )
            return try modelContext.fetch(descriptor).map(\.snapshot)
        }

        // MARK: - Evaluate

        @discardableResult
        public func evaluateBadges<B: PrismBadge>(
            _ badgeType: B.Type,
            currentPoints: Int
        ) throws -> [PrismBadgeSnapshot] {
            var unlocked: [PrismBadgeSnapshot] = []

            for badge in B.allCases {
                let record = try fetchBadgeProgress(for: badge.rawValue)
                guard !record.isUnlocked else { continue }

                let conditionMet: Bool
                switch badge.condition {
                case .challengeCompleted(let challengeID):
                    conditionMet = try evaluateChallengeCompleted(challengeID)
                case .pointsReached(let threshold):
                    conditionMet = currentPoints >= threshold
                case .streakReached(let streakID, let days):
                    conditionMet = try evaluateStreakReached(streakID: streakID, days: days)
                case .custom:
                    conditionMet = false
                }

                if conditionMet {
                    record.isUnlocked = true
                    record.unlockedAt = .now
                    eventContinuation.yield(.badgeUnlocked(badgeID: badge.rawValue, tier: badge.tier.rawValue))
                    unlocked.append(record.snapshot)
                }
            }

            if !unlocked.isEmpty {
                try modelContext.save()
            }

            return unlocked
        }

        // MARK: - Private Helpers

        private func fetchBadgeProgress(for badgeID: String) throws -> PrismBadgeProgress {
            let descriptor = FetchDescriptor<PrismBadgeProgress>(
                predicate: #Predicate { $0.badgeID == badgeID }
            )
            guard let record = try modelContext.fetch(descriptor).first else {
                throw PrismGamificationError.badgeNotFound(badgeID)
            }
            return record
        }

        private func evaluateChallengeCompleted(_ challengeID: String) throws -> Bool {
            let descriptor = FetchDescriptor<PrismChallengeProgress>(
                predicate: #Predicate { $0.challengeID == challengeID }
            )
            guard let record = try modelContext.fetch(descriptor).first else {
                return false
            }
            return record.isCompleted
        }

        private func evaluateStreakReached(streakID: String, days: Int) throws -> Bool {
            let descriptor = FetchDescriptor<PrismStreakRecord>(
                predicate: #Predicate { $0.streakID == streakID }
            )
            guard let record = try modelContext.fetch(descriptor).first else {
                return false
            }
            return record.currentStreak >= days
        }
    }
#endif
