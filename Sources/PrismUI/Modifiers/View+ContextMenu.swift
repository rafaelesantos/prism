import SwiftUI

extension View {

    public func prismContextMenu<MenuContent: View, Preview: View>(
        @ViewBuilder menu: @escaping () -> MenuContent,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        contextMenu(menuItems: menu, preview: preview)
    }

    public func prismContextMenu<MenuContent: View>(
        @ViewBuilder menu: @escaping () -> MenuContent
    ) -> some View {
        contextMenu(menuItems: menu)
    }
}
