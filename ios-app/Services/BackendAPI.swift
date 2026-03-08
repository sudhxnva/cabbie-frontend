import Foundation

struct AppConfig {
    let backendBaseURL: URL?
    let useStubBackend: Bool
    let useStubElevenLabs: Bool
    let elevenLabsAPIKey: String?
    let elevenLabsAgentID: String?
    let elevenLabsSignedURLEndpoint: URL?

    static let current = AppConfig()

    init(
        backendBaseURL: URL? = AppConfig.readURL("BACKEND_BASE_URL", fallback: "http://localhost:8080"),
        useStubBackend: Bool = AppConfig.readBool("USE_STUB_BACKEND", defaultValue: true),
        useStubElevenLabs: Bool = AppConfig.readBool("USE_STUB_ELEVENLABS", defaultValue: true),
        elevenLabsAPIKey: String? = AppConfig.readString("ELEVENLABS_API_KEY"),
        elevenLabsAgentID: String? = AppConfig.readString("ELEVENLABS_AGENT_ID"),
        elevenLabsSignedURLEndpoint: URL? = AppConfig.readURL("ELEVENLABS_SIGNED_URL_ENDPOINT")
    ) {
        self.backendBaseURL = backendBaseURL
        self.useStubBackend = useStubBackend
        self.useStubElevenLabs = useStubElevenLabs
        self.elevenLabsAPIKey = elevenLabsAPIKey
        self.elevenLabsAgentID = elevenLabsAgentID
        self.elevenLabsSignedURLEndpoint = elevenLabsSignedURLEndpoint
    }

    var hasPublicAgentConfig: Bool {
        elevenLabsAgentID?.isEmpty == false
    }

    var hasPrivateAgentConfig: Bool {
        elevenLabsSignedURLEndpoint != nil
    }

    var shouldUseRealElevenLabs: Bool {
        !useStubElevenLabs && (hasPublicAgentConfig || hasPrivateAgentConfig)
    }

    private static func readString(_ key: String) -> String? {
        let environmentValue = ProcessInfo.processInfo.environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let environmentValue, !environmentValue.isEmpty {
            return environmentValue
        }

        if let plistValue = Bundle.main.object(forInfoDictionaryKey: key) as? String {
            let trimmed = plistValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        return nil
    }

    private static func readBool(_ key: String, defaultValue: Bool) -> Bool {
        if let environmentValue = ProcessInfo.processInfo.environment[key]?.lowercased() {
            if ["1", "true", "yes", "on"].contains(environmentValue) { return true }
            if ["0", "false", "no", "off"].contains(environmentValue) { return false }
        }

        if let plistValue = Bundle.main.object(forInfoDictionaryKey: key) as? String {
            let normalized = plistValue.lowercased()
            if ["1", "true", "yes", "on"].contains(normalized) { return true }
            if ["0", "false", "no", "off"].contains(normalized) { return false }
        }

        if let plistBool = Bundle.main.object(forInfoDictionaryKey: key) as? Bool {
            return plistBool
        }

        return defaultValue
    }

    private static func readURL(_ key: String, fallback: String? = nil) -> URL? {
        if let value = readString(key), let url = URL(string: value) {
            return url
        }
        if let fallback, let url = URL(string: fallback) {
            return url
        }
        return nil
    }
}

final class BackendAPI {
    enum BackendAPIError: Error {
        case invalidURL
        case invalidResponse
    }

    private let session: URLSession
    private let baseURL: URL?
    private let useStubResponses: Bool

    init(
        config: AppConfig = .current,
        session: URLSession = .shared,
        baseURL: URL? = nil,
        useStubResponses: Bool? = nil
    ) {
        self.session = session
        self.baseURL = baseURL ?? config.backendBaseURL
        self.useStubResponses = useStubResponses ?? config.useStubBackend
    }

    func requestBooking(_ request: BookingRequest) async throws -> BookingSearchResponse {
        if useStubResponses {
            return BookingSearchResponse(options: CabOption.sampleData, status: "searching")
        }

        return try await sendRequest(
            path: "/booking/request",
            method: "POST",
            body: request,
            responseType: BookingSearchResponse.self
        )
    }

    func confirmBooking(_ request: BookingConfirmRequest) async throws -> BookingConfirmation {
        if useStubResponses {
            let selected = CabOption.sampleData.first { $0.id == request.optionId } ?? CabOption.sampleData[0]
            return BookingConfirmation.sample(for: selected)
        }

        return try await sendRequest(
            path: "/booking/confirm",
            method: "POST",
            body: request,
            responseType: BookingConfirmation.self
        )
    }

    func health() async throws -> HealthResponse {
        if useStubResponses {
            return HealthResponse(status: "ok")
        }

        return try await sendRequest(
            path: "/health",
            method: "GET",
            body: Optional<String>.none,
            responseType: HealthResponse.self
        )
    }

    private func sendRequest<Body: Encodable, Response: Decodable>(
        path: String,
        method: String,
        body: Body?,
        responseType: Response.Type
    ) async throws -> Response {
        guard let baseURL else { throw BackendAPIError.invalidURL }
        let url = baseURL.appending(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, urlResponse) = try await session.data(for: request)
        guard let httpResponse = urlResponse as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw BackendAPIError.invalidResponse
        }

        return try JSONDecoder().decode(responseType, from: data)
    }
}
