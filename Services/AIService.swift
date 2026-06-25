import Foundation

struct AIService {
  private let session: URLSession
  private let endpoint: URL

  init(
    session: URLSession = .shared,
    endpoint: URL = URL(string: "http://192.168.0.103:3000/api/generate")!
  ) {
    self.session = session
    self.endpoint = endpoint
  }

  func generateResponse(for prompt: String) async throws -> String {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    // Encode the user's prompt into the backend contract expected by the API.
    request.httpBody = try JSONEncoder().encode(GenerateRequest(prompt: prompt))

    // Send the request asynchronously and wait for the server response.
    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AIServiceError.invalidResponse
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      throw AIServiceError.requestFailed(statusCode: httpResponse.statusCode)
    }

    do {
      let decodedResponse = try JSONDecoder().decode(GenerateResponse.self, from: data)
      let trimmedResult = decodedResponse.result.trimmingCharacters(in: .whitespacesAndNewlines)

      guard !trimmedResult.isEmpty else {
        throw AIServiceError.emptyResult
      }

      return trimmedResult
    } catch let error as AIServiceError {
      throw error
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
