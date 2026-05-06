import SwiftUI

public struct PrismDebugInfo: Sendable {
    public let componentName: String
    public var renderCount: Int
    public var frameSize: CGSize
    public var accessibilityLabel: String?

    public init(
        componentName: String,
        renderCount: Int = 1,
        frameSize: CGSize = .zero,
        accessibilityLabel: String? = nil
    ) {
        self.componentName = componentName
        self.renderCount = renderCount
        self.frameSize = frameSize
        self.accessibilityLabel = accessibilityLabel
    }
}

@Observable
@MainActor
public final class PrismComponentDebugger {
    public private(set) var components: [PrismDebugInfo] = []

    public init() {}

    public func register(component name: String, size: CGSize, label: String? = nil) {
        if let index = components.firstIndex(where: { $0.componentName == name }) {
            components[index].renderCount += 1
            components[index].frameSize = size
            components[index].accessibilityLabel = label
        } else {
            components.append(
                PrismDebugInfo(
                    componentName: name,
                    renderCount: 1,
                    frameSize: size,
                    accessibilityLabel: label
                )
            )
        }
    }

    public func reset() {
        components.removeAll()
    }
}

// MARK: - Debug View Modifier

private struct PrismDebugModifier: ViewModifier {
    let debugger: PrismComponentDebugger
    let name: String

    func body(content: Content) -> some View {
        #if DEBUG
            content
                .overlay(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                debugger.register(component: name, size: geometry.size)
                            }
                            .onChange(of: geometry.size) { _, newSize in
                                debugger.register(component: name, size: newSize)
                            }
                    }
                )
                .overlay(alignment: .topLeading) {
                    Text(name)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.red.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                        .allowsHitTesting(false)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(.red, lineWidth: 1)
                        .allowsHitTesting(false)
                )
        #else
            content
        #endif
    }
}

extension View {
    public func prismDebug(debugger: PrismComponentDebugger, name: String) -> some View {
        modifier(PrismDebugModifier(debugger: debugger, name: name))
    }
}

// MARK: - Debug Overlay View

public struct PrismDebugOverlay: View {
    let debugger: PrismComponentDebugger

    public init(debugger: PrismComponentDebugger) {
        self.debugger = debugger
    }

    public var body: some View {
        List {
            Section("Registered Components (\(debugger.components.count))") {
                ForEach(debugger.components, id: \.componentName) { info in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(info.componentName)
                            .font(.system(.body, design: .monospaced, weight: .semibold))
                        HStack(spacing: SpacingToken.md.rawValue) {
                            Label(
                                "\(info.renderCount)x",
                                systemImage: "arrow.clockwise"
                            )
                            Label(
                                "\(Int(info.frameSize.width))x\(Int(info.frameSize.height))",
                                systemImage: "rectangle"
                            )
                            if let label = info.accessibilityLabel {
                                Label(label, systemImage: "accessibility")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "\(info.componentName), rendered \(info.renderCount) times"
                    )
                }
            }
        }
    }
}
