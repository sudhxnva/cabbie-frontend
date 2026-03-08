import Foundation

final class BackendAPI {
    enum BackendAPIError: Error {
        case invalidURL
        case invalidResponse
    }

    private let session: URLSession
    private let baseURL: URL?
    private let useStubResponses: Bool

    init(
        session: URLSession = .shared,
        baseURL: URL? = URL(string: "http://localhost:8080"),
        useStubResponses: Bool = true
    ) {
        self.session = session
        self.baseURL = baseURL
        self.useStubResponses = useStubResponses
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
