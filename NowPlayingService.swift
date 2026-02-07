import Foundation
import MediaPlayer

protocol NowPlayingProviding {
    func currentTrack() -> TrackMetadata?
}

final class NowPlayingService: NowPlayingProviding {
    func currentTrack() -> TrackMetadata? {
        let nowPlaying = MPNowPlayingInfoCenter.default().nowPlayingInfo
        let item = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem

        let title = (nowPlaying?[MPMediaItemPropertyTitle] as? String) ?? item?.title
        let artist = (nowPlaying?[MPMediaItemPropertyArtist] as? String) ?? item?.artist
        let album = (nowPlaying?[MPMediaItemPropertyAlbumTitle] as? String) ?? item?.albumTitle
        let duration = (nowPlaying?[MPMediaItemPropertyPlaybackDuration] as? Double) ?? item?.playbackDuration
        let elapsed = (nowPlaying?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? Double) ?? 0
        let rate = (nowPlaying?[MPNowPlayingInfoPropertyPlaybackRate] as? Float) ?? 0
        let timestamp = nowPlaying?[MPNowPlayingInfoPropertyElapsedPlaybackTime] != nil ? Date() : nil

        guard let safeTitle = title, !safeTitle.isEmpty, let safeArtist = artist, !safeArtist.isEmpty else {
            return nil
        }

        return TrackMetadata(
            title: safeTitle,
            artist: safeArtist,
            album: album,
            duration: duration,
            elapsedPlaybackTime: elapsed,
            playbackRate: rate,
            timestamp: timestamp
        )
    }
}
