#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

import Foundation

public final class PrismClipboardGuard: @unchecked Sendable {
    private let clearAfter: TimeInterval
    private let lock = NSLock()
    private var clearTask: Task<Void, Never>?

    public init(clearAfter: TimeInterval = 30) {
        self.clearAfter = clearAfter
    }

    deinit {
        lock.withLock { clearTask?.cancel() }
    }

    public func copySecurely(_ string: String) {
        #if canImport(UIKit) && !os(watchOS)
            UIPasteboard.general.string = string
        #elseif canImport(AppKit)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(string, forType: .string)
        #endif
        scheduleClear()
    }

    public func copySecurely(_ data: Data) {
        #if canImport(UIKit) && !os(watchOS)
            UIPasteboard.general.setData(data, forPasteboardType: "public.data")
        #endif
        scheduleClear()
    }

    public func clearNow() {
        lock.withLock { clearTask?.cancel() }
        #if canImport(UIKit) && !os(watchOS)
            UIPasteboard.general.items = []
        #elseif canImport(AppKit)
            NSPasteboard.general.clearContents()
        #endif
    }

    public func cancelClear() {
        lock.withLock { clearTask?.cancel() }
    }

    private func scheduleClear() {
        lock.withLock { clearTask?.cancel() }

        let delay = clearAfter
        let task = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            self?.clearNow()
        }

        lock.withLock { clearTask = task }
    }
}
