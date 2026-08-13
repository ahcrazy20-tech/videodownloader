import SwiftUI

struct ContentView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var historyManager: HistoryManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DownloadView()
                .tabItem {
                    Label("تحميل", systemImage: "arrow.down.circle.fill")
                }
                .tag(0)
            
            PlayerView()
                .tabItem {
                    Label("مشغل", systemImage: "play.circle.fill")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("السجل", systemImage: "clock.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("إعدادات", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.red)
    }
}

// MARK: - Download View
struct DownloadView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @State private var url = ""
    @State private var selectedQuality = "best"
    @State private var showProgress = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // URL Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔗 رابط الفيديو")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            TextField("الصق الرابط هنا", text: $url)
                                .textFieldStyle(.roundedBorder)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                if let clipboard = UIPasteboard.general.string {
                                    url = clipboard
                                }
                            }) {
                                Image(systemName: "doc.on.clipboard")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Video Info
                    if let info = downloadManager.videoInfo {
                        VideoInfoCard(info: info)
                    }
                    
                    // Quality Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🎯 اختيار الجودة")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Picker("الجودة", selection: $selectedQuality) {
                            Text("🏆 أفضل جودة").tag("best")
                            Text("📱 720p").tag("720p")
                            Text("📱 480p").tag("480p")
                            Text("🎵 صوت فقط").tag("audio")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Progress
                    if showProgress {
                        VStack(spacing: 10) {
                            ProgressView(value: downloadManager.progress)
                                .progressViewStyle(.linear)
                            
                            HStack {
                                Text(downloadManager.statusText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("\(Int(downloadManager.progress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 15) {
                        Button(action: {
                            downloadManager.analyzeURL(url)
                        }) {
                            Label("تحليل", systemImage: "magnifyingglass")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showProgress = true
                            downloadManager.download(url: url, quality: selectedQuality)
                        }) {
                            Label("تحميل", systemImage: "arrow.down.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(url.isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle("📥 التحميل")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

// MARK: - Video Info Card
struct VideoInfoCard: View {
    let info: VideoInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: info.thumbnail)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            
            Text(info.title)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Label(info.uploader, systemImage: "person")
                Spacer()
                Label(info.duration, systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Player View
struct PlayerView: View {
    @State private var videoURL: URL?
    @State private var isPlaying = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let url = videoURL {
                    VideoPlayerView(url: url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "play.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("افتح ملف فيديو للتشغيل")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // فتح ملف
                        }) {
                            Label("اختر ملف", systemImage: "folder")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationTitle("▶️ المشغل")
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyManager.items.filter { 
                    searchText.isEmpty || $0.title.contains(searchText) 
                }) { item in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title)
                            .font(.headline)
                        
                        HStack {
                            Text(item.date)
                            Spacer()
                            Text(item.quality)
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("📋 السجل")
            .toolbar {
                Button(action: {
                    historyManager.clear()
                }) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var downloadPath = ""
    @State private var embedThumbnail = true
    @State private var embedMetadata = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("عام") {
                    TextField("مسار التحميل", text: $downloadPath)
                    
                    Toggle("تضمين الصورة المصغرة", isOn: $embedThumbnail)
                    Toggle("تضمين البيانات الوصفية", isOn: $embedMetadata)
                }
                
                Section("الشبكة") {
                    TextField("بروكسي (اختياري)", text: $settingsManager.proxy)
                }
                
                Section("حول") {
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("⚙️ الإعدادات")
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        playerVC.player?.play()
        return playerVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

import AVKit
