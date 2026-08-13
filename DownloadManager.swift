import Foundation
import Combine

struct VideoInfo: Codable {
    let title: String
    let uploader: String
    let duration: String
    let thumbnail: String
    let formats: [Format]
}

struct Format: Codable {
    let format_id: String
    let ext: String
    let resolution: String
    let filesize: Int?
}

class DownloadManager: ObservableObject {
    @Published var videoInfo: VideoInfo?
    @Published var progress: Double = 0.0
    @Published var statusText = "جاهز"
    @Published var isDownloading = false
    
    private var ytdlpPath: String {
        Bundle.main.path(forResource: "yt-dlp", ofType: nil) ?? "yt-dlp"
    }
    
    func analyzeURL(_ urlString: String) {
        statusText = "جاري التحليل..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.ytdlpPath)
            process.arguments = [
                "--dump-json",
                "--no-download",
                urlString
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let info = VideoInfo(
                        title: json["title"] as? String ?? "غير معروف",
                        uploader: json["uploader"] as? String ?? "غير معروف",
                        duration: self.formatDuration(json["duration"] as? Double ?? 0),
                        thumbnail: json["thumbnail"] as? String ?? "",
                        formats: []
                    )
                    
                    DispatchQueue.main.async {
                        self.videoInfo = info
                        self.statusText = "تم التحليل ✅"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusText = "خطأ: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func download(url: String, quality: String) {
        isDownloading = true
        statusText = "جاري التحميل..."
        progress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.ytdlpPath)
            
            var formatArg = "best"
            switch quality {
            case "720p":
                formatArg = "bestvideo[height<=720]+bestaudio/best"
            case "480p":
                formatArg = "bestvideo[height<=480]+bestaudio/best"
            case "audio":
                formatArg = "bestaudio"
            default:
                formatArg = "best"
            }
            
            let downloadDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            process.arguments = [
                "-f", formatArg,
                "-o", "\(downloadDir.path)/%(title)s.%(ext)s",
                "--newline",
                url
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            
            pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if let output = String(data: data, encoding: .utf8) {
                    // تحليل التقدم من output
                    if output.contains("[download]") {
                        if let range = output.range(of: "[download]\\s+([\\d.]+)%", options: .regularExpression) {
                            let percentStr = output[range].replacingOccurrences(of: "[download]", with: "")
                                .trimmingCharacters(in: .whitespaces)
                                .replacingOccurrences(of: "%", with: "")
                            if let percent = Double(percentStr) {
                                DispatchQueue.main.async {
                                    self.progress = percent / 100.0
                                    self.statusText = "تحميل: \(Int(percent))%"
                                }
                            }
                        }
                    }
                }
            }
            
            do {
                try process.run()
                process.waitUntilExit()
                
                DispatchQueue.main.async {
                    self.isDownloading = false
                    self.progress = 1.0
                    self.statusText = "اكتمل التحميل ✅"
                }
            } catch {
                DispatchQueue.main.async {
                    self.isDownloading = false
                    self.statusText = "خطأ: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}
