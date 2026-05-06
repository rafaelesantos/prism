import SwiftUI

#if canImport(PhotosUI)
    import PhotosUI

    public struct PrismPhotoPicker<Label: View & Sendable>: View {
        @Environment(\.prismTheme) private var theme

        @Binding private var selection: PhotosPickerItem?
        private let matching: PHPickerFilter
        private let label: Label

        public init(
            selection: Binding<PhotosPickerItem?>,
            matching filter: PHPickerFilter = .images,
            @ViewBuilder label: () -> Label
        ) {
            self._selection = selection
            self.matching = filter
            self.label = label()
        }

        public var body: some View {
            let content = label
            PhotosPicker(selection: $selection, matching: matching) {
                content
            }
            .tint(theme.color(.interactive))
        }
    }

    extension PrismPhotoPicker where Label == SwiftUI.Label<Text, Image> {

        public init(
            _ title: LocalizedStringKey,
            systemImage: String = "photo.on.rectangle",
            selection: Binding<PhotosPickerItem?>,
            matching filter: PHPickerFilter = .images
        ) {
            self._selection = selection
            self.matching = filter
            self.label = SwiftUI.Label(title, systemImage: systemImage)
        }
    }

    public struct PrismMultiPhotoPicker<Label: View & Sendable>: View {
        @Environment(\.prismTheme) private var theme

        @Binding private var selection: [PhotosPickerItem]
        private let maxCount: Int
        private let matching: PHPickerFilter
        private let label: Label

        public init(
            selection: Binding<[PhotosPickerItem]>,
            maxSelectionCount: Int = 0,
            matching filter: PHPickerFilter = .images,
            @ViewBuilder label: () -> Label
        ) {
            self._selection = selection
            self.maxCount = maxSelectionCount
            self.matching = filter
            self.label = label()
        }

        public var body: some View {
            let content = label
            PhotosPicker(
                selection: $selection,
                maxSelectionCount: maxCount > 0 ? maxCount : nil,
                matching: matching
            ) {
                content
            }
            .tint(theme.color(.interactive))
        }
    }
#endif
