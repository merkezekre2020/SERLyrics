import Foundation
import Combine

@MainActor
final class LyricsViewModel: ObservableObject {
    @Published private(set) var track: TrackMetadata?
    @Published private(set) var lyrics: [LRCLine] = []
    @Published private(set) var activeLineID: UUID?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let nowPlayingService: NowPlayingProviding
    private let lyricsService: LyricsProviding
    private var metadataTimer: Timer?
    private var syncTimer: Timer?
    private var lastFetchedTrackKey: String?
    private var playbackStartTime: Date?
    private var baseElapsed: TimeInterval = 0
    private var playbackRate: Float = 0

    init(
        nowPlayingService: NowPlayingProviding = NowPlayingService(),
        lyricsService: LyricsProviding = LRCLibService()
    ) {
        self.nowPlayingService = nowPlayingService
        self.lyricsService = lyricsService
        startMetadataPolling()
        startSyncTimer()
    }

    deinit {
        metadataTimer?.invalidate()
        syncTimer?.invalidate()
    }

    func refresh() {
        Task {
            await updateTrackAndLyrics(forceFetch: true)
        }
    }

    private func startMetadataPolling() {
        metadataTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateTrackAndLyrics(forceFetch: false)
            }
        }
    }

    private func startSyncTimer() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateActiveLine()
            }
        }
    }

    private func updateTrackAndLyrics(forceFetch: Bool) async {
        guard let current = nowPlayingService.currentTrack() else {
            track = nil
            lyrics = []
            activeLineID = nil
            errorMessage = LyricsError.notPlaying.localizedDescription
            lastFetchedTrackKey = nil
            return
        }

        track = current
        baseElapsed = current.elapsedPlaybackTime
        playbackRate = current.playbackRate
        playbackStartTime = current.timestamp ?? Date()
        errorMessage = nil

        let key = "\(current.artist.lowercased())-\(current.title.lowercased())"
        guard forceFetch || key != lastFetchedTrackKey else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await lyricsService.fetchLyrics(for: current)
            let synced = response.syncedLyrics ?? ""
            let parsed = LRCParser.parse(synced)

            if parsed.isEmpty {
                throw LyricsError.notFound
            }

            lyrics = parsed
            lastFetchedTrackKey = key
            updateActiveLine()
        } catch let error as LyricsError {
            lyrics = []
            activeLineID = nil
            errorMessage = error.localizedDescription
        } catch {
            lyrics = []
            activeLineID = nil
            errorMessage = LyricsError.unknown(error.localizedDescription).localizedDescription
        }
    }

    private func updateActiveLine() {
        guard !lyrics.isEmpty else {
            activeLineID = nil
            return
        }

        let currentTime = currentPlaybackTime()
        if let index = lyrics.lastIndex(where: { $0.time <= currentTime }) {
            activeLineID = lyrics[index].id
        } else {
            activeLineID = lyrics.first?.id
        }
    }

    private func currentPlaybackTime() -> TimeInterval {
        guard playbackRate > 0, let start = playbackStartTime else {
            return baseElapsed
        }

        let delta = Date().timeIntervalSince(start) * Double(playbackRate)
        return max(0, baseElapsed + delta)
    }
}
