import Foundation

enum LRCParser {
    static func parse(_ lrc: String) -> [LRCLine] {
        let lines = lrc.split(separator: "\n")
        var parsed: [LRCLine] = []

        for raw in lines {
            let line = String(raw)
            let matches = timestamps(in: line)
            let lyricText = textPart(in: line)

            for timestamp in matches {
                parsed.append(LRCLine(time: timestamp, text: lyricText))
            }
        }

        return parsed.sorted { $0.time < $1.time }
    }

    private static func timestamps(in line: String) -> [TimeInterval] {
        let pattern = #"\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let nsrange = NSRange(line.startIndex..<line.endIndex, in: line)
        return regex.matches(in: line, options: [], range: nsrange).compactMap { match in
            guard
                let minutesRange = Range(match.range(at: 1), in: line),
                let secondsRange = Range(match.range(at: 2), in: line)
            else {
                return nil
            }

            let minutes = Double(line[minutesRange]) ?? 0
            let seconds = Double(line[secondsRange]) ?? 0
            var milliseconds = 0.0

            if let fractionRange = Range(match.range(at: 3), in: line) {
                let fraction = String(line[fractionRange])
                if fraction.count == 2 {
                    milliseconds = (Double(fraction) ?? 0) / 100
                } else {
                    milliseconds = (Double(fraction) ?? 0) / 1000
                }
            }

            return (minutes * 60) + seconds + milliseconds
        }
    }

    private static func textPart(in line: String) -> String {
        let pattern = #"(?:\[\d{1,2}:\d{2}(?:\.\d{1,3})?\])+"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let nsrange = NSRange(line.startIndex..<line.endIndex, in: line)
        let cleaned = regex.stringByReplacingMatches(in: line, options: [], range: nsrange, withTemplate: "")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
