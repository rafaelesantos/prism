import SwiftUI

private struct PrismSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let interactiveDismiss: Bool
    let backgroundStyle: PrismSheetBackground
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents(detents)
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                    .interactiveDismissDisabled(!interactiveDismiss)
                    .modifier(SheetBackgroundModifier(style: backgroundStyle))
            }
    }
}

public enum PrismSheetBackground: Sendable {
    case automatic
    case material
    case clear
}

private struct SheetBackgroundModifier: ViewModifier {
    let style: PrismSheetBackground

    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content
        case .material:
            content
                .presentationBackground(.ultraThinMaterial)
        case .clear:
            content
                .presentationBackground(.clear)
        }
    }
}

private struct PrismItemSheetModifier<Item: Identifiable, SheetContent: View>: ViewModifier {
    @Binding var item: Item?
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let sheetContent: (Item) -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                sheetContent(item)
                    .presentationDetents(detents)
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
            }
    }
}

private struct PrismConfirmationDialogModifier<Actions: View, Message: View>: ViewModifier {
    let title: LocalizedStringKey
    @Binding var isPresented: Bool
    let actions: () -> Actions
    let message: (() -> Message)?

    func body(content: Content) -> some View {
        if let message {
            content
                .confirmationDialog(title, isPresented: $isPresented) {
                    actions()
                } message: {
                    message()
                }
        } else {
            content
                .confirmationDialog(title, isPresented: $isPresented) {
                    actions()
                }
        }
    }
}

private struct PrismInspectorModifier<InspectorContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let inspectorContent: () -> InspectorContent

    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isPresented) {
                inspectorContent()
            }
    }
}

extension View {

    public func prismSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.large],
        showDragIndicator: Bool = true,
        interactiveDismiss: Bool = true,
        background: PrismSheetBackground = .automatic,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            PrismSheetModifier(
                isPresented: isPresented,
                detents: detents,
                showDragIndicator: showDragIndicator,
                interactiveDismiss: interactiveDismiss,
                backgroundStyle: background,
                sheetContent: content
            ))
    }

    public func prismSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.large],
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(
            PrismItemSheetModifier(
                item: item,
                detents: detents,
                showDragIndicator: showDragIndicator,
                sheetContent: content
            ))
    }

    public func prismConfirmationDialog<Actions: View>(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions
    ) -> some View {
        modifier(
            PrismConfirmationDialogModifier(
                title: title,
                isPresented: isPresented,
                actions: actions,
                message: nil as (() -> EmptyView)?
            ))
    }

    public func prismConfirmationDialog<Actions: View, Message: View>(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder message: @escaping () -> Message
    ) -> some View {
        modifier(
            PrismConfirmationDialogModifier(
                title: title,
                isPresented: isPresented,
                actions: actions,
                message: message
            ))
    }

    public func prismInspector<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            PrismInspectorModifier(
                isPresented: isPresented,
                inspectorContent: content
            ))
    }
}
