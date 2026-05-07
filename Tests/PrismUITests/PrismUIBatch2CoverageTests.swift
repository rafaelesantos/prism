import Foundation
import SwiftUI
import Testing

@testable import PrismUI

// MARK: - Communication: PrismReadReceipt

@Suite("ReadReceiptCov")
struct PrismReadReceiptCoverageTests {
    @Test("init stores properties")
    func initProperties() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let receipt = PrismReadReceipt(userId: "u1", name: "Alice", readAt: date)
        #expect(receipt.userId == "u1")
        #expect(receipt.name == "Alice")
        #expect(receipt.readAt == date)
    }

    @Test("id returns userId")
    func idIsUserId() {
        let receipt = PrismReadReceipt(userId: "abc", name: "Bob")
        #expect(receipt.id == "abc")
    }

    @Test("equatable compares all fields")
    func equatable() {
        let date = Date(timeIntervalSince1970: 500_000)
        let a = PrismReadReceipt(userId: "x", name: "A", readAt: date)
        let b = PrismReadReceipt(userId: "x", name: "A", readAt: date)
        let c = PrismReadReceipt(userId: "y", name: "A", readAt: date)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("default readAt uses now")
    func defaultReadAt() {
        let before = Date()
        let receipt = PrismReadReceipt(userId: "u", name: "N")
        let after = Date()
        #expect(receipt.readAt >= before)
        #expect(receipt.readAt <= after)
    }
}

// MARK: - Communication: PrismMessage & PrismMessageGroup

@Suite("MessageCov")
struct PrismMessageCoverageTests {
    @Test("message init stores all properties")
    func messageInit() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let id = UUID()
        let msg = PrismMessage(
            id: id, text: "hello", sender: "Alice",
            timestamp: date, isOutgoing: true, status: .delivered
        )
        #expect(msg.id == id)
        #expect(msg.text == "hello")
        #expect(msg.sender == "Alice")
        #expect(msg.timestamp == date)
        #expect(msg.isOutgoing == true)
        #expect(msg.status == .delivered)
    }

    @Test("message defaults")
    func messageDefaults() {
        let msg = PrismMessage(text: "hi", sender: "Bob")
        #expect(msg.isOutgoing == false)
        #expect(msg.status == .sent)
        #expect(!msg.text.isEmpty)
    }

    @Test("message equatable same id and fields")
    func messageEquatable() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 100)
        let a = PrismMessage(id: id, text: "t", sender: "s", timestamp: date)
        let b = PrismMessage(id: id, text: "t", sender: "s", timestamp: date)
        #expect(a == b)
    }

    @Test("message equatable different text")
    func messageNotEqual() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 100)
        let a = PrismMessage(id: id, text: "a", sender: "s", timestamp: date)
        let b = PrismMessage(id: id, text: "b", sender: "s", timestamp: date)
        #expect(a != b)
    }

    @Test("message group stores properties")
    func groupInit() {
        let msg = PrismMessage(
            text: "hi", sender: "A",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let group = PrismMessageGroup(
            sender: "A", isOutgoing: false, messages: [msg]
        )
        #expect(group.sender == "A")
        #expect(group.isOutgoing == false)
        #expect(group.messages.count == 1)
    }

    @Test("message group id uses first message id")
    func groupId() {
        let msg = PrismMessage(
            text: "hi", sender: "A",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let group = PrismMessageGroup(
            sender: "A", isOutgoing: false, messages: [msg]
        )
        #expect(group.id == msg.id)
    }

    @Test("empty message group id is valid UUID")
    func emptyGroupId() {
        let group = PrismMessageGroup(
            sender: "A", isOutgoing: false, messages: []
        )
        _ = group.id
    }
}

// MARK: - Communication: PrismReaction

@Suite("ReactionCov")
struct PrismReactionCoverageTests {
    @Test("reaction init stores properties")
    func reactionInit() {
        let r = PrismReaction(emoji: "👍", count: 5, isSelected: true)
        #expect(r.emoji == "👍")
        #expect(r.count == 5)
        #expect(r.isSelected == true)
        #expect(r.id == "👍")
    }

    @Test("reaction defaults")
    func reactionDefaults() {
        let r = PrismReaction(emoji: "❤️")
        #expect(r.count == 0)
        #expect(r.isSelected == false)
    }

    @Test("reaction equatable")
    func reactionEquatable() {
        let a = PrismReaction(emoji: "😂", count: 3, isSelected: false)
        let b = PrismReaction(emoji: "😂", count: 3, isSelected: false)
        let c = PrismReaction(emoji: "😂", count: 4, isSelected: false)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("reaction is mutable")
    func reactionMutable() {
        var r = PrismReaction(emoji: "🙏", count: 1)
        r.count = 10
        r.isSelected = true
        #expect(r.count == 10)
        #expect(r.isSelected == true)
    }
}

// MARK: - Communication: PrismThread

@Suite("ThreadCov")
struct PrismThreadCoverageTests {
    @Test("thread init with replies")
    func threadInit() {
        let root = PrismMessage(
            text: "root", sender: "A",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let reply = PrismMessage(
            text: "reply", sender: "B",
            timestamp: Date(timeIntervalSince1970: 200)
        )
        let thread = PrismThread(rootMessage: root, replies: [reply])
        #expect(thread.rootMessage == root)
        #expect(thread.replies.count == 1)
        #expect(thread.replyCount == 1)
    }

    @Test("thread custom replyCount overrides")
    func threadCustomReplyCount() {
        let root = PrismMessage(
            text: "root", sender: "A",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let thread = PrismThread(rootMessage: root, replies: [], replyCount: 42)
        #expect(thread.replyCount == 42)
        #expect(thread.replies.isEmpty)
    }

    @Test("thread equatable")
    func threadEquatable() {
        let id = UUID()
        let root = PrismMessage(
            text: "r", sender: "A",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let a = PrismThread(id: id, rootMessage: root)
        let b = PrismThread(id: id, rootMessage: root)
        #expect(a == b)
    }

    @Test("thread default empty replies")
    func threadDefaultReplies() {
        let root = PrismMessage(
            text: "msg", sender: "X",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let thread = PrismThread(rootMessage: root)
        #expect(thread.replies.isEmpty)
        #expect(thread.replyCount == 0)
    }
}

// MARK: - Dashboard: PrismTrend

@Suite("TrendCov")
struct PrismTrendCoverageTests {
    @Test("trend has three cases")
    func trendCases() {
        #expect(PrismTrend.allCases.count == 3)
    }

    @Test("trend raw values")
    func trendRawValues() {
        #expect(PrismTrend.up.rawValue == "up")
        #expect(PrismTrend.down.rawValue == "down")
        #expect(PrismTrend.flat.rawValue == "flat")
    }

    @Test("trend color tokens")
    func trendColorTokens() {
        #expect(PrismTrend.up.colorToken == .success)
        #expect(PrismTrend.down.colorToken == .error)
        #expect(PrismTrend.flat.colorToken == .onBackgroundSecondary)
    }

    @Test("trend system images")
    func trendSystemImages() {
        #expect(PrismTrend.up.systemImage == "arrow.up.right")
        #expect(PrismTrend.down.systemImage == "arrow.down.right")
        #expect(PrismTrend.flat.systemImage == "arrow.right")
    }
}

// MARK: - Dashboard: PrismKPISize

@Suite("KPISizeCov")
struct PrismKPISizeCoverageTests {
    @Test("kpi size cases")
    func kpiSizeCases() {
        let compact: PrismKPISize = .compact
        let expanded: PrismKPISize = .expanded
        _ = compact
        _ = expanded
    }
}

// MARK: - Dashboard: PrismEventStatus

@Suite("EventStatusCov")
struct PrismEventStatusCoverageTests {
    @Test("event status has four cases")
    func statusCases() {
        #expect(PrismEventStatus.allCases.count == 4)
    }

    @Test("event status raw values")
    func statusRawValues() {
        #expect(PrismEventStatus.completed.rawValue == "completed")
        #expect(PrismEventStatus.current.rawValue == "current")
        #expect(PrismEventStatus.upcoming.rawValue == "upcoming")
        #expect(PrismEventStatus.failed.rawValue == "failed")
    }

    @Test("event status color tokens")
    func statusColorTokens() {
        #expect(PrismEventStatus.completed.colorToken == .success)
        #expect(PrismEventStatus.current.colorToken == .interactive)
        #expect(PrismEventStatus.upcoming.colorToken == .onBackgroundTertiary)
        #expect(PrismEventStatus.failed.colorToken == .error)
    }

    @Test("event status system images")
    func statusSystemImages() {
        #expect(PrismEventStatus.completed.systemImage == "checkmark.circle.fill")
        #expect(PrismEventStatus.current.systemImage == "circle.fill")
        #expect(PrismEventStatus.upcoming.systemImage == "circle")
        #expect(PrismEventStatus.failed.systemImage == "xmark.circle.fill")
    }
}

// MARK: - Dashboard: PrismTimelineEvent

@Suite("TimelineEventCov")
struct PrismTimelineEventCoverageTests {
    @Test("event init with all params")
    func eventInit() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let id = UUID()
        let event = PrismTimelineEvent(
            id: id, title: "Deploy", description: "v2.0",
            date: date, status: .completed, icon: "rocket"
        )
        #expect(event.id == id)
        #expect(event.title == "Deploy")
        #expect(event.description == "v2.0")
        #expect(event.date == date)
        #expect(event.status == .completed)
        #expect(event.icon == "rocket")
    }

    @Test("event defaults")
    func eventDefaults() {
        let event = PrismTimelineEvent(
            title: "Test", date: Date(timeIntervalSince1970: 100),
            status: .upcoming
        )
        #expect(event.description == nil)
        #expect(event.icon == nil)
    }
}

// MARK: - Dashboard: PrismActivity & PrismActivityGroup

@Suite("ActivityCov")
struct PrismActivityCoverageTests {
    @Test("activity init stores properties")
    func activityInit() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let id = UUID()
        let activity = PrismActivity(
            id: id, user: "Alice", action: "merged",
            target: "PR #42", timestamp: date, icon: "merge"
        )
        #expect(activity.id == id)
        #expect(activity.user == "Alice")
        #expect(activity.action == "merged")
        #expect(activity.target == "PR #42")
        #expect(activity.timestamp == date)
        #expect(activity.icon == "merge")
    }

    @Test("activity defaults")
    func activityDefaults() {
        let activity = PrismActivity(
            user: "Bob", action: "created", target: "Issue",
            timestamp: Date(timeIntervalSince1970: 100)
        )
        #expect(activity.icon == nil)
    }

    @Test("activity group groups by date")
    func groupByDate() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let activities = [
            PrismActivity(
                user: "A", action: "did", target: "X", timestamp: today
            ),
            PrismActivity(
                user: "B", action: "did", target: "Y", timestamp: yesterday
            ),
        ]
        let groups = PrismActivityGroup.group(activities)
        #expect(groups.count == 2)
        #expect(groups[0].title == "Today")
        #expect(groups[1].title == "Yesterday")
    }

    @Test("activity group single day")
    func groupSingleDay() {
        let now = Date()
        let activities = [
            PrismActivity(
                user: "A", action: "a", target: "t", timestamp: now
            ),
            PrismActivity(
                user: "B", action: "b", target: "t", timestamp: now
            ),
        ]
        let groups = PrismActivityGroup.group(activities)
        #expect(groups.count == 1)
        #expect(groups[0].activities.count == 2)
    }

    @Test("activity group empty input")
    func groupEmpty() {
        let groups = PrismActivityGroup.group([])
        #expect(groups.isEmpty)
    }

    @Test("activity group older date uses formatter")
    func groupOlderDate() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let activities = [
            PrismActivity(
                user: "A", action: "a", target: "t", timestamp: oldDate
            )
        ]
        let groups = PrismActivityGroup.group(activities)
        #expect(groups.count == 1)
        #expect(groups[0].title != "Today")
        #expect(groups[0].title != "Yesterday")
        #expect(!groups[0].title.isEmpty)
    }
}

// MARK: - Dashboard: PrismStatItem

@Suite("StatItemCov")
struct PrismStatItemCoverageTests {
    @Test("stat item init stores properties")
    func statItemInit() {
        let item = PrismStatItem(
            label: "Revenue", value: "$1.2M",
            icon: "dollarsign.circle", trend: .up
        )
        #expect(item.label == "Revenue")
        #expect(item.value == "$1.2M")
        #expect(item.icon == "dollarsign.circle")
        #expect(item.trend == .up)
    }

    @Test("stat item defaults")
    func statItemDefaults() {
        let item = PrismStatItem(label: "Users", value: "1000")
        #expect(item.icon == nil)
        #expect(item.trend == nil)
    }
}

// MARK: - Dashboard: PrismFeatureValue & PrismComparisonFeature

@Suite("ComparisonCov")
struct PrismComparisonCoverageTests {
    @Test("feature value cases")
    func featureValueCases() {
        let check: PrismFeatureValue = .check
        let cross: PrismFeatureValue = .cross
        let text: PrismFeatureValue = .text("unlimited")
        let number: PrismFeatureValue = .number(99.9)
        _ = check
        _ = cross
        _ = text
        _ = number
    }

    @Test("comparison column init")
    func comparisonColumnInit() {
        let col = PrismComparisonColumn(
            header: "Pro", values: ["Yes", "No"]
        )
        #expect(col.header == "Pro")
        #expect(col.values.count == 2)
    }

    @Test("comparison feature init")
    func comparisonFeatureInit() {
        let feature = PrismComparisonFeature(
            name: "Storage", values: [.text("10GB"), .text("100GB")]
        )
        #expect(feature.name == "Storage")
        #expect(feature.values.count == 2)
    }
}

// MARK: - Composites: PrismNotificationBanner.Content

@Suite("NotifBannerCov")
struct PrismNotificationBannerCoverageTests {
    @Test("content init with defaults")
    func contentDefaults() {
        let content = PrismNotificationBanner.Content("Alert")
        #expect(content.icon == "bell.fill")
        #expect(content.duration == 4)
    }

    @Test("content init with custom values")
    func contentCustom() {
        let content = PrismNotificationBanner.Content(
            "Error", message: "Something failed",
            icon: "exclamationmark.triangle", style: .error, duration: 8
        )
        #expect(content.icon == "exclamationmark.triangle")
        #expect(content.duration == 8)
    }

    @Test("content style cases")
    func contentStyleCases() {
        let info: PrismNotificationBanner.Content.Style = .info
        let success: PrismNotificationBanner.Content.Style = .success
        let warning: PrismNotificationBanner.Content.Style = .warning
        let error: PrismNotificationBanner.Content.Style = .error
        _ = info
        _ = success
        _ = warning
        _ = error
    }
}

// MARK: - Composites: PrismOnboarding.Page

@Suite("OnboardingPageCov")
struct PrismOnboardingPageCoverageTests {
    @Test("page init stores properties")
    func pageInit() {
        let page = PrismOnboarding.Page(
            icon: "star.fill", title: "Welcome", message: "Get started"
        )
        #expect(page.icon == "star.fill")
    }
}

// MARK: - Composites: PrismMenu.MenuItem

@Suite("MenuItemCov")
struct PrismMenuItemCoverageTests {
    @Test("button item")
    func buttonItem() {
        var called = false
        let item = PrismMenu<Text>.MenuItem.button(
            "Edit", icon: "pencil", role: nil
        ) { called = true }
        if case .button(_, let icon, let role, let action) = item {
            #expect(icon == "pencil")
            #expect(role == nil)
            action()
            #expect(called)
        }
    }

    @Test("destructive item")
    func destructiveItem() {
        var called = false
        let item = PrismMenu<Text>.MenuItem.destructive("Delete", icon: "trash") {
            called = true
        }
        if case .button(_, _, let role, let action) = item {
            #expect(role == .destructive)
            action()
            #expect(called)
        }
    }

    @Test("section item")
    func sectionItem() {
        let item = PrismMenu<Text>.MenuItem.section(
            "Group",
            items: [
                .button("A", action: {}),
                .divider,
            ])
        if case .section(_, let items) = item {
            #expect(items.count == 2)
        }
    }

    @Test("divider item")
    func dividerItem() {
        let item = PrismMenu<Text>.MenuItem.divider
        if case .divider = item {
            // pass
        } else {
            #expect(Bool(false))
        }
    }
}

// MARK: - Primitives: PrismAvatar.Size

@Suite("AvatarSizeCov")
struct PrismAvatarSizeCoverageTests {
    @Test("size dimensions")
    func sizeDimensions() {
        #expect(PrismAvatar.Size.small.dimension == 32)
        #expect(PrismAvatar.Size.medium.dimension == 40)
        #expect(PrismAvatar.Size.large.dimension == 56)
        #expect(PrismAvatar.Size.xLarge.dimension == 80)
        #expect(PrismAvatar.Size.custom(100).dimension == 100)
    }

    @Test("size status sizes")
    func sizeStatusSizes() {
        #expect(PrismAvatar.Size.small.statusSize == 10)
        #expect(PrismAvatar.Size.medium.statusSize == 12)
        #expect(PrismAvatar.Size.large.statusSize == 14)
        #expect(PrismAvatar.Size.xLarge.statusSize == 18)
        #expect(PrismAvatar.Size.custom(100).statusSize == 25)
    }
}

// MARK: - Primitives: PrismAvatar.Status

@Suite("AvatarStatusCov")
struct PrismAvatarStatusCoverageTests {
    @Test("status cases exist")
    func statusCases() {
        let online: PrismAvatar.Status = .online
        let offline: PrismAvatar.Status = .offline
        let busy: PrismAvatar.Status = .busy
        let away: PrismAvatar.Status = .away
        _ = online
        _ = offline
        _ = busy
        _ = away
    }
}

// MARK: - Primitives: PrismButtonVariant & PrismButtonHaptic

@Suite("ButtonTypesCov")
struct PrismButtonTypesCoverageTests {
    @Test("button variant cases")
    func variantCases() {
        let filled: PrismButtonVariant = .filled
        let tinted: PrismButtonVariant = .tinted
        let bordered: PrismButtonVariant = .bordered
        let plain: PrismButtonVariant = .plain
        let glass: PrismButtonVariant = .glass
        let glassProminent: PrismButtonVariant = .glassProminent
        _ = filled
        _ = tinted
        _ = bordered
        _ = plain
        _ = glass
        _ = glassProminent
    }

    @Test("button haptic cases")
    func hapticCases() {
        let none: PrismButtonHaptic = .none
        let light: PrismButtonHaptic = .light
        let medium: PrismButtonHaptic = .medium
        let heavy: PrismButtonHaptic = .heavy
        _ = none
        _ = light
        _ = medium
        _ = heavy
    }
}

// MARK: - Primitives: PrismLoadingState.State

@Suite("LoadingStateCov")
struct PrismLoadingStateCoverageTests {
    @Test("loading state cases")
    func loadingStateCases() {
        let loading: PrismLoadingState.State = .loading
        let empty: PrismLoadingState.State = .empty(
            title: "No data", message: "Try again", icon: "tray"
        )
        let error: PrismLoadingState.State = .error("Failed", retry: nil)
        _ = loading
        _ = empty
        _ = error
    }

    @Test("empty state with nil optionals")
    func emptyStateNils() {
        let state: PrismLoadingState.State = .empty(
            title: "Empty", message: nil, icon: nil
        )
        _ = state
    }

    @Test("error state with retry closure")
    func errorWithRetry() {
        var called = false
        let state: PrismLoadingState.State = .error("Oops") { called = true }
        if case .error(_, let retry) = state {
            retry?()
            #expect(called)
        }
    }
}

// MARK: - Internationalization: PrismMultiLocalePreview

@Suite("LocalePreviewCov")
@MainActor
struct PrismLocalePreviewCoverageTests {
    @Test("default locales has 6 entries")
    func defaultLocales() {
        let locales = PrismMultiLocalePreview<Text>.defaultLocales
        #expect(locales.count == 6)
    }

    @Test("default locales includes en and ar")
    func defaultLocalesContents() {
        let locales = PrismMultiLocalePreview<Text>.defaultLocales
        let identifiers = locales.map(\.identifier)
        #expect(identifiers.contains("en"))
        #expect(identifiers.contains("ar"))
    }

    @Test("custom locales accepted")
    func customLocales() {
        let custom = [Locale(identifier: "pt-BR"), Locale(identifier: "fr")]
        let preview = PrismMultiLocalePreview(locales: custom) {
            Text("test")
        }
        _ = preview
    }
}

// MARK: - Dashboard: PrismComparisonColumn identifiable

@Suite("ComparisonColumnIdCov")
struct PrismComparisonColumnIdTests {
    @Test("comparison column is identifiable")
    func columnIdentifiable() {
        let a = PrismComparisonColumn(header: "A", values: [])
        let b = PrismComparisonColumn(header: "A", values: [])
        #expect(a.id != b.id)
    }
}

// MARK: - Dashboard: PrismComparisonFeature identifiable

@Suite("ComparisonFeatureIdCov")
struct PrismComparisonFeatureIdTests {
    @Test("comparison feature is identifiable")
    func featureIdentifiable() {
        let a = PrismComparisonFeature(name: "X", values: [])
        let b = PrismComparisonFeature(name: "X", values: [])
        #expect(a.id != b.id)
    }
}

// MARK: - Communication: PrismBubbleStyle exhaustive

@Suite("BubbleStyleCov")
struct PrismBubbleStyleCoverageTests {
    @Test("all bubble styles are CaseIterable")
    func allCases() {
        let cases = PrismBubbleStyle.allCases
        #expect(cases.contains(.filled))
        #expect(cases.contains(.outlined))
        #expect(cases.contains(.glass))
    }
}

// MARK: - Communication: PrismMessageStatus exhaustive

@Suite("MsgStatusCov")
struct PrismMessageStatusCoverageTests {
    @Test("all statuses iterable")
    func allStatuses() {
        let all = PrismMessageStatus.allCases
        #expect(all.count == 5)
    }
}

// MARK: - PrismColorWell defaults

@Suite("ColorWellCov")
@MainActor
struct PrismColorWellCoverageTests {
    @Test("default presets exist")
    func defaultPresets() {
        let presets = PrismColorWell.defaultPresets
        #expect(!presets.isEmpty)
    }
}
