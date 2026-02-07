import Foundation

protocol LyricsProviding {
    func fetchLyrics(for track: TrackMetadata) async throws -> LRCLibResponse
}

final class LRCLibService: LyricsProviding {
    private let baseURL = URL(string: "https://lrclib.net/api")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchLyrics(for track: TrackMetadata) async throws -> LRCLibResponse {
        do {
            if let exact = try await getLyrics(track: track) {
                return exact
            }

            let searched = try await searchLyrics(track: track)
            guard let first = searched.first else {
                throw LyricsError.notFound
            }
            return first
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw LyricsError.noInternet
        } catch let error as LyricsError {
            throw error
        } catch {
            throw LyricsError.unknown(error.localizedDescription)
        }
    }

    private func getLyrics(track: TrackMetadata) async throws -> LRCLibResponse? {
        var components = URLComponents(url: baseURL.appendingPathComponent("get"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "track_name", value: track.title),
            URLQueryItem(name: "artist_name", value: track.artist),
            URLQueryItem(name: "album_name", value: track.album)
        ]

        guard let url = components?.url else {
            throw LyricsError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw LyricsError.invalidResponse
        }

        if http.statusCode == 404 {
            return nil
        }

        guard (200...299).contains(http.statusCode) else {
            throw LyricsError.invalidResponse
        }

        return try JSONDecoder().decode(LRCLibResponse.self, from: data)
    }

    private func searchLyrics(track: TrackMetadata) async throws -> [LRCLibResponse] {
        var components = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "track_name", value: track.title),
            URLQueryItem(name: "artist_name", value: track.artist)
        ]

        guard let url = components?.url else {
            throw LyricsError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard
            let http = response as? HTTPURLResponse,
            (200...299).contains(http.statusCode)
        else {
            throw LyricsError.invalidResponse
        }

        return try JSONDecoder().decode([LRCLibResponse].self, from: data)
    }
}
