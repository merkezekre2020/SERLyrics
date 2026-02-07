import Foundation

struct TrackMetadata: Equatable {
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval?
    let elapsedPlaybackTime: TimeInterval
    let playbackRate: Float
    let timestamp: Date?
}

struct LRCLine: Identifiable, Equatable {
    let id = UUID()
    let time: TimeInterval
    let text: String
}

struct LRCLibResponse: Decodable {
    let id: Int?
    let trackName: String?
    let artistName: String?
    let albumName: String?
    let duration: Double?
    let plainLyrics: String?
    let syncedLyrics: String?
}

enum LyricsError: LocalizedError, Equatable {
    case notPlaying
    case notFound
    case noInternet
    case invalidResponse
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notPlaying:
            return "Cihazda çalan bir şarkı bulunamadı."
        case .notFound:
            return "Şarkı sözleri bulunamadı."
        case .noInternet:
            return "İnternet bağlantısı yok."
        case .invalidResponse:
            return "Sunucudan geçersiz bir yanıt alındı."
        case .unknown(let message):
            return message
        }
    }
}
