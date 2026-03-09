import SwiftUI

@main
struct DayFlowApp: App {
    @State private var taskStore = TaskStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(taskStore)
                .toastOverlay()
                .preferredColorScheme(.dark)
        }
    }
}
