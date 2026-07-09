import Foundation

struct PivotPersistenceService {
  private let session: URLSession
  private let endpoint: URL

  init(
    session: URLSession = .shared,
    endpoint: URL = URL(string: "http://192.168.0.103:3000/api/pivots")!
  ) {
    self.session = session
    self.endpoint = endpoint
  }

  func fetchPivots() async throws -> PivotDocument {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw PivotPersistenceError.invalidResponse
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      throw try parseRequestFailure(from: data, statusCode: httpResponse.statusCode)
    }

    do {
      return try JSONDecoder().decode(PivotDocument.self, from: data)
    } catch {
      throw PivotPersistenceError.decodingFailed
    }
  }

  func savePivots(_ document: PivotDocument) async throws -> PivotDocument {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      request.httpBody = try JSONEncoder().encode(document)
    } catch {
      throw PivotPersistenceError.encodingFailed
    }

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw PivotPersistenceError.invalidResponse
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      throw try parseRequestFailure(from: data, statusCode: httpResponse.statusCode)
    }

    do {
      return try JSONDecoder().decode(PivotDocument.self, from: data)
    } catch {
      throw PivotPersistenceError.decodingFailed
    }
  }

  func deletePivots() async throws {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw PivotPersistenceError.invalidResponse
    }

    guard 200 ..< 300 ~= httpResponse.statusCode else {
      throw try parseRequestFailure(from: data, statusCode: httpResponse.statusCode)
    }
  }

  private func parseRequestFailure(from data: Data, statusCode: Int) throws -> PivotPersistenceError {
    if let serverMessage = try? JSONDecoder().decode(PivotServerErrorResponse.self, from: data),
       !serverMessage.error.isEmpty {
      return .serverError(message: serverMessage.error, statusCode: statusCode)
    }

    return .requestFailed(statusCode: statusCode)
  }
}

enum PivotPersistenceError: LocalizedError {
  case invalidResponse
  case requestFailed(statusCode: Int)
  case serverError(message: String, statusCode: Int)
  case decodingFailed
  case encodingFailed

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "The server returned an invalid response."
    case .requestFailed(let statusCode):
      return "The request failed with status code \(statusCode)."
    case .serverError(let message, _):
      return message
    case .decodingFailed:
      return "The app could not read the saved pivots."
    case .encodingFailed:
      return "The app could not prepare the pivots for saving."
    }
  }
}

private struct PivotServerErrorResponse: Decodable {
  var error: String
}
