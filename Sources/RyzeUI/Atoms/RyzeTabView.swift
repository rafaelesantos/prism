//
//  RyzeTabView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/07/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeTabView<SelectionValue: Hashable>: RyzeView {
    @Binding var selection: SelectionValue
    var searchText: Binding<String>?
    var searchPrompt: RyzeResourceString?
    @ViewBuilder let content: any View
    let accessoryView: (any View)?

    public init(
        selection: Binding<SelectionValue>,
        searchText: Binding<String>? = nil,
        searchPrompt: RyzeResourceString? = nil,
        accessoryView: (() -> any View)? = nil,
        @ViewBuilder content: () -> any View,
    ) {
        self._selection = selection
        self.searchText = searchText
        self.searchPrompt = searchPrompt
        self.content = content()
        self.accessoryView = accessoryView?()
    }

    public var body: some View {
        tabView
    }

    @ViewBuilder
    var tabView: some View {
        #if os(iOS)
            TabView(selection: $selection) {
                AnyView(content)
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                if let accessoryView {
                    AnyView(accessoryView)
                }
            }
            .ryze(item: searchText) {
                searchable(
                    view: $0,
                    searchText: $1
                )
            }
            .searchToolbarBehavior(.minimize)
            .ryze(tint: .primary)
        #endif
    }

    @ViewBuilder
    func searchable(view: some View, searchText: Binding<String>) -> some View {
        if let searchPrompt {
            view.searchable(
                text: searchText,
                prompt: searchPrompt.value
            )
        } else {
            view.searchable(text: searchText)
        }
    }

    public static func mocked() -> some View {
        RyzeTabView<Int>(
            selection: .constant(1),
            searchText: .constant(""),
            searchPrompt: RyzeUIString.ryzePreviewTitle,
            accessoryView: nil
        ) {
            ForEach((1...3).map { $0 }, id: \.self) { index in
                RyzeList.mocked()
                    .searchable(text: .constant(""))
                    .tabItem {
                        RyzeLabel.mocked()
                    }
            }
        }
    }
}

#Preview {
    RyzeTabView<Int>.mocked()
}
