import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Calls the real Anthropic Messages API to generate a ``FollowUp``.
///
/// - Endpoint: `https://api.anthropic.com/v1/messages`
/// - Auth header: `x-api-key`
/// - Version header: `anthropic-version: 2023-06-01`
///
/// The API key is read from the environment variable `ANTHROPIC_API_KEY` and is
/// never hardcoded. Response parsing is robust: the model is asked for raw JSON,
/// but the provider also recovers JSON embedded in prose or code fences and, as
/// a last resort, wraps the raw text in a usable ``FollowUp``.
public struct ClaudeProvider: AIProvider {
    /// A current Claude model. Verified against the Anthropic models list; can be
    /// overridden at init time.
    public static let defaultModel = "claude-sonnet-4-5-20250929"

    public let apiKey: String
    public let model: String
    public let maxTokens: Int

    private let session: URLSession
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    /// - Parameters:
    ///   - apiKey: Anthropic API key. Defaults to the `ANTHROPIC_API_KEY` env var.
    ///   - model: Claude model id.
    ///   - session: Injected for testing; defaults to `.shared`.
    public init(
        apiKey: String? = nil,
        model: String = ClaudeProvider.defaultModel,
        maxTokens: Int = 2048,
        session: URLSession = .shared
    ) throws {
        guard let key = apiKey ?? ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"],
              !key.isEmpty else {
            throw AfterpartyError.missingAPIKey
        }
        self.apiKey = key
        self.model = model
        self.maxTokens = maxTokens
        self.session = session
    }

    public func generateFollowUp(for request: FollowUpRequest) async throws -> FollowUp {
        guard !request.note.isEmpty else { throw AfterpartyError.emptyInput }

        let body = MessagesRequest(
            model: model,
            maxTokens: maxTokens,
            system: PromptBuilder.systemPrompt,
            messages: [.init(role: "user", content: PromptBuilder.userPrompt(for: request))]
        )

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await Self.send(urlRequest, using: session)

        guard let http = response as? HTTPURLResponse else {
            throw AfterpartyError.network("No HTTP response")
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "<no body>"
            throw AfterpartyError.http(status: http.statusCode, message: message)
        }

        let text = try Self.extractText(from: data)
        return try Self.parseFollowUp(from: text, fallbackName: InputParser.parse(request.note).name)
    }

    // MARK: - Networking (portable async wrapper)

    static func send(_ request: URLRequest, using session: URLSession) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: AfterpartyError.network(error.localizedDescription))
                    return
                }
                guard let data, let response else {
                    continuation.resume(throwing: AfterpartyError.network("Empty response"))
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    // MARK: - Response parsing (pure, unit-tested without network)

    /// Pulls the concatenated text out of an Anthropic Messages API response.
    static func extractText(from data: Data) throws -> String {
        let decoded: MessagesResponse
        do {
            decoded = try JSONDecoder().decode(MessagesResponse.self, from: data)
        } catch {
            throw AfterpartyError.decoding("Unexpected response shape: \(error)")
        }
        let text = decoded.content
            .filter { $0.type == "text" }
            .map { $0.text ?? "" }
            .joined()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AfterpartyError.decoding("Response contained no text content")
        }
        return text
    }

    /// Decodes model text into a ``FollowUp``, recovering JSON from prose/code
    /// fences and falling back to a wrapped raw message when no JSON is present.
    static func parseFollowUp(from text: String, fallbackName: String?) throws -> FollowUp {
        if let json = extractJSONObject(from: text),
           let data = json.data(using: .utf8),
           let followUp = try? JSONDecoder().decode(FollowUp.self, from: data) {
            return followUp
        }
        // Graceful fallback: still hand the user something usable.
        return FollowUp.fallback(rawText: text, name: fallbackName)
    }

    /// Returns the first balanced `{ ... }` block in a string, ignoring braces
    /// inside string literals. Handles fenced and prose-wrapped JSON.
    static func extractJSONObject(from text: String) -> String? {
        let chars = Array(text)
        var depth = 0
        var start: Int?
        var inString = false
        var escaped = false

        for (index, ch) in chars.enumerated() {
            if inString {
                if escaped {
                    escaped = false
                } else if ch == "\\" {
                    escaped = true
                } else if ch == "\"" {
                    inString = false
                }
                continue
            }
            switch ch {
            case "\"":
                inString = true
            case "{":
                if depth == 0 { start = index }
                depth += 1
            case "}":
                depth -= 1
                if depth == 0, let s = start {
                    return String(chars[s...index])
                }
            default:
                break
            }
        }
        return nil
    }
}

// MARK: - Anthropic wire models

struct MessagesRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [Message]

    struct Message: Encodable {
        let role: String
        let content: String
    }

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

struct MessagesResponse: Decodable {
    let content: [Block]

    struct Block: Decodable {
        let type: String
        let text: String?
    }
}
