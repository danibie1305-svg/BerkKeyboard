import SwiftUI

@main
struct BerkKeyboardApp: App {
    @AppStorage("theme") private var theme = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(theme == "light" ? .light : theme == "dark" ? .dark : nil)
        }
    }
}
