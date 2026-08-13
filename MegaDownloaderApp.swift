import SwiftUI

@main
struct MegaDownloaderApp: App {
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var historyManager = HistoryManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(downloadManager)
                .environmentObject(historyManager)
                .environmentObject(settingsManager)
                .preferredColorScheme(.dark)
        }
    }
}
