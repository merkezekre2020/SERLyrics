import SwiftUI

@main
struct SERLyricApp: App {
    var body: some Scene {
        WindowGroup {
            LyricsView(viewModel: LyricsViewModel())
        }
    }
}
