import Foundation
import SwiftUI
import Combine

final class ColorViewModel: ObservableObject {
    @Published var allThemes: [ColorTheme] = ColorTheme.allThemes
    @Published var selectedIndex: Int = 0
    @Published var selectedTheme: ColorTheme
    @Published var showingConfirmation: Bool = false

    init() {
        self.selectedTheme = ColorTheme.allThemes[0]
    }

    var canGoBack: Bool {
        true
    }

    func confirmSelection() {
        selectedTheme = allThemes[selectedIndex]
        showingConfirmation = true
    }

    func goToColorPicker() {
        showingConfirmation = false
    }

    func nextColor() {
        selectedIndex = (selectedIndex + 1) % allThemes.count
        selectedTheme = allThemes[selectedIndex]
    }

    func previousColor() {
        selectedIndex = (selectedIndex - 1 + allThemes.count) % allThemes.count
        selectedTheme = allThemes[selectedIndex]
    }
}