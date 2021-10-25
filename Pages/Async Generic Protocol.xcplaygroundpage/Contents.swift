import Foundation


enum APIError: Error {

	case requestFailed(description: String)
	case jsonConversionFailure(description: String)
	case invalidData
	case responseUnsuccessful(description: String)
	case jsonParsingFailure
	case noInternet
	case failedSerialization

	var customDescription: String {
		switch self {
			case let .requestFailed(description): return "Request Failed error -> \(description)"
			case .invalidData: return "Invalid Data error"
			case let .responseUnsuccessful(description): return "Response Unsuccessful error -> \(description)"
			case .jsonParsingFailure: return "JSON Parsing Failure error"
			case let .jsonConversionFailure(description): return "JSON Conversion Failure -> \(description)"
			case .noInternet: return "No internet connection"
			case .failedSerialization: return "serialization print for debug failed."
		}
	}
}

protocol AsyncGenericAPI {
	var session: URLSession { get }
	func fetch<T: Decodable>(type: T.Type, with request: URLRequest) async throws -> T
}

extension AsyncGenericAPI {

	func fetch<T: Decodable>(type: T.Type, with request: URLRequest) async throws -> T { // 1

		// 2
		let (data, response) = try await session.data(for: request)

		guard let httpResponse = response as? HTTPURLResponse else {
			throw APIError.requestFailed(description: "unvalid response")
		}

		guard httpResponse.statusCode == 200 else {
			throw APIError.responseUnsuccessful(description: "status code \(httpResponse.statusCode)")
		}
		do {
			let decoder = JSONDecoder()
			// 3
			return try decoder.decode(type, from: data)
		} catch {
			// 4
			throw APIError.jsonConversionFailure(description: error.localizedDescription)
		}
	}
}
