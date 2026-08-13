import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let url: String
    let filename: String
    let quality: String
    let date: String
    let filesize: Int
    
    init(title: String, url: String, filename: String, quality: String, filesize: Int) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.filename = filename
        self.quality = quality
        self.date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        self.filesize = filesize
    }
}

class HistoryManager: ObservableObject {
    @Published var items: [HistoryItem] = []
    
    private let fileURL: URL
    
    init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documentsURL.appendingPathComponent("history.json")
        load()
    }
    
    func add(_ item: HistoryItem) {
        items.insert(item, at: 0)
        save()
    }
    
    func clear() {
        items.removeAll()
        save()
    }
    
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL)
        } catch {
            print("Error saving history: \(error)")
        }
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([HistoryItem].self, from: data)
        } catch {
            print("Error loading history: \(error)")
        }
    }
}
