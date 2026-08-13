import Foundation

class SettingsManager: ObservableObject {
    @Published var downloadPath: String {
        didSet { save() }
    }
    @Published var proxy: String {
        didSet { save() }
    }
    @Published var embedThumbnail: Bool {
        didSet { save() }
    }
    @Published var embedMetadata: Bool {
        didSet { save() }
    }
    
    private let defaults = UserDefaults.standard
    
    init() {
        self.downloadPath = defaults.string(forKey: "downloadPath") ?? ""
        self.proxy = defaults.string(forKey: "proxy") ?? ""
        self.embedThumbnail = defaults.bool(forKey: "embedThumbnail")
        self.embedMetadata = defaults.bool(forKey: "embedMetadata")
    }
    
    private func save() {
        defaults.set(downloadPath, forKey: "downloadPath")
        defaults.set(proxy, forKey: "proxy")
        defaults.set(embedThumbnail, forKey: "embedThumbnail")
        defaults.set(embedMetadata, forKey: "embedMetadata")
    }
}
