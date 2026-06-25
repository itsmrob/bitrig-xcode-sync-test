import Foundation

struct AIService {
  private let session: URLSession
  private let generateEndpoint: URL
  private let bomAutofillEndpoint: URL

  init(
    session: URLSession = .shared,
    generateEndpoint: URL = URL(string: "http://192.168.0.103:3000/api/generate")!,
    bomAutofillEndpoint: URL = URL(string: "http://192.168.0.103:3000/api/bom-autofill")!
  ) {
    self.session = session
    self.generateEndpoint = generateEndpoint
    self.bomAutofillEndpoint = bomAutofillEndpoint
  }

  func generateResponse(for prompt: String) async throws -> String {
    let decodedResponse: GenerateResponse = try await performJSONRequest(
      to: generateEndpoint,
      body: GenerateRequest(prompt: prompt)
    )

    let trimmedResult = decodedResponse.result.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedResult.isEmpty else {
      throw AIServiceError.emptyResult
    }

    return trimmedResult
  }

  func generateBOMAutofill(prompt: String) async throws -> BOMAutofillResponse {
    // This endpoint turns one business description into all category items for both Current and Options.
    try await performJSONRequest(
      to: bomAutofillEndpoint,
      body: BOMAutofillRequest(prompt: prompt)
    )
  }

  private func performJSONRequest<Response: Decodable, Request: Encodable>(
    to endpoint: URL,
    body: Request
  ) async throws -> Response {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AIServiceError.invalidResponse
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      throw AIServiceError.requestFailed(statusCode: httpResponse.statusCode)
    }

    do {
      return try JSONDecoder().decode(Response.self, from: data)
    } catch {
      throw AIServiceError.decodingFailed
    }
  }
}

enum AIServiceError: LocalizedError {
  case invalidResponse
  case requestFailed(statusCode: Int)
  case decodingFailed
  case emptyResult

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "The server returned an invalid response."
    case .requestFailed(let statusCode):
      return "The request failed with status code \(statusCode)."
    case .decodingFailed:
      return "The app could not read the server response."
    case .emptyResult:
      return "The server returned an empty result."
    }
  }
}

private struct GenerateRequest: Encodable {
  var prompt: String
}

private struct GenerateResponse: Decodable {
  var result: String
}
