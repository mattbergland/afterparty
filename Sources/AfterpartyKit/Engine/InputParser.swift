import Foundation

/// Lightweight, dependency-free hints extracted from a free-form note.
///
/// These are best-effort guesses used to personalize the deterministic
/// ``MockProvider`` output and to enrich the prompt sent to Claude. Every field
/// is optional and the parser never throws.
public struct ParsedNote: Equatable, Sendable {
    public var name: String?
    public var company: String?
    public var role: String?
    public var topics: [String]
    public var rawText: String

    public init(
        name: String? = nil,
        company: String? = nil,
        role: String? = nil,
        topics: [String] = [],
        rawText: String = ""
    ) {
        self.name = name
        self.company = company
        self.role = role
        self.topics = topics
        self.rawText = rawText
    }
}

/// A small, deterministic heuristic parser. It intentionally avoids regular
/// expressions so behaviour is identical across macOS, iOS, and Linux.
public enum InputParser {
    private static let introVerbs: Set<String> = ["met", "meet", "with", "saw", "introduced"]
    private static let roleVerbs: Set<String> = ["runs", "run", "leads", "lead", "heads", "head", "does", "manages", "manage", "owns"]
    private static let topicCues: [String] = ["talked about", "chatted about", "discussed", "spoke about", "about"]
    private static let stopWords: Set<String> = ["the", "a", "an", "this", "that", "some", "our", "their", "his", "her", "my", "your"]

    public static func parse(_ note: PersonNote) -> ParsedNote {
        let raw = note.trimmed
        var parsed = ParsedNote(rawText: raw)
        guard !raw.isEmpty else { return parsed }

        let words = raw.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).map(String.init)

        parsed.name = extractName(from: words)
        parsed.company = extractCompany(from: words)
        parsed.role = extractRole(from: raw)
        parsed.topics = extractTopics(from: raw)
        return parsed
    }

    // MARK: - Helpers

    private static func cleaned(_ token: String) -> String {
        token.trimmingCharacters(in: CharacterSet(charactersIn: ".,;:!?()\"'"))
    }

    private static func isCapitalized(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        return first.isUppercase && first.isLetter
    }

    /// Name = the first capitalized token immediately following an intro verb
    /// ("met", "with", ...). Falls back to `nil` when nothing fits.
    private static func extractName(from words: [String]) -> String? {
        for index in words.indices.dropLast() {
            let word = cleaned(words[index]).lowercased()
            if introVerbs.contains(word) {
                let candidate = cleaned(words[index + 1])
                if isCapitalized(candidate), !stopWords.contains(candidate.lowercased()) {
                    return candidate
                }
            }
        }
        return nil
    }

    /// Company = the capitalized token following the *last* "at" in the note.
    /// This favours "...marketing at Datadog" over "...at the AI dinner".
    private static func extractCompany(from words: [String]) -> String? {
        var company: String?
        for index in words.indices.dropLast() {
            if cleaned(words[index]).lowercased() == "at" {
                let candidate = cleaned(words[index + 1])
                if isCapitalized(candidate), !stopWords.contains(candidate.lowercased()) {
                    company = candidate
                }
            }
        }
        return company
    }

    /// Role = the words between a role verb ("runs", "leads", ...) and the next
    /// "at" / sentence boundary, e.g. "runs developer marketing at Datadog".
    private static func extractRole(from raw: String) -> String? {
        let lower = raw.lowercased()
        for verb in roleVerbs {
            guard let verbRange = lower.range(of: " \(verb) ") else { continue }
            let afterVerb = raw[verbRange.upperBound...]
            // Stop at " at ", a period, or the end of the string.
            var end = afterVerb.endIndex
            if let atRange = afterVerb.range(of: " at ") {
                end = atRange.lowerBound
            }
            if let dotRange = afterVerb.range(of: ".") {
                end = min(end, dotRange.lowerBound)
            }
            let role = afterVerb[..<end].trimmingCharacters(in: .whitespacesAndNewlines)
            if !role.isEmpty, role.count < 60 {
                return role
            }
        }
        return nil
    }

    /// Topics = the clause following a topic cue ("talked about", "discussed", ...),
    /// split on commas and the word "and".
    private static func extractTopics(from raw: String) -> [String] {
        let lower = raw.lowercased()
        for cue in topicCues {
            guard let cueRange = lower.range(of: cue) else { continue }
            let after = raw[cueRange.upperBound...]
            var end = after.endIndex
            if let dotRange = after.range(of: ".") {
                end = dotRange.lowerBound
            }
            let clause = String(after[..<end])
            let pieces = clause
                .replacingOccurrences(of: " and ", with: ",")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count < 60 }
            if !pieces.isEmpty {
                return Array(pieces.prefix(4))
            }
        }
        return []
    }
}
