import Foundation
import _Concurrency


enum APIError: Error {
	
	case noInternet
	case invalidData
	case jsonParsingFailure
	case failedSerialization
	case invalidURL(url: URL)
	case requestFailed(description: String)
	case responseUnsuccessful(description: String)
	case jsonConversionFailure(description: String)
	
	var customDescription: String {
		switch self {
			case .invalidURL(let url): return "Invalid URL: \(url)"
			case .invalidData: return "Invalid Data error"
			case .noInternet: return "No internet connection"
			case .jsonParsingFailure: return "JSON Parsing Failure error"
			case .failedSerialization: return "serialization print for debug failed."
			case .requestFailed(let description): return "Request Failed error -> \(description)"
			case .jsonConversionFailure(let description): return "JSON Conversion Failure -> \(description)"
			case .responseUnsuccessful(let description): return "Response Unsuccessful error -> \(description)"
		}
	}
}

struct Breed: Codable, CustomStringConvertible {
	let id: String
	let name: String
	let origin: String?
	let wikipediaLink: URL?
	let temperament: String?
	let breedExplaining: String
	let hairless: Bool
	let image: BreedImage
	
	var description: String {
		"Breed \(name) with ID: \(id)\n\(image.url)"
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		// From `CodingKeys`
		id = try values.decode(String.self, forKey: .id)
		name = try values.decode(String.self, forKey: .name)
		temperament = try values.decode(String?.self, forKey: .temperament)
		origin = try values.decode(String?.self, forKey: .origin)
		wikipediaLink = try values.decode(URL?.self, forKey: .wikipediaLink)
		breedExplaining = try values.decode(String.self, forKey: .wikipediaLink)
		image = try values.decode(BreedImage.self, forKey: .image)
		
		
		let isHairless = try values.decode(Int.self, forKey: .hairless)
		hairless = isHairless == 1
	}
}

extension Breed {
	struct BreedImage: Codable {
		let url: URL
	}
	
	enum CodingKeys: String, CodingKey {
		case id, name,temperament, origin
		case wikipediaLink = "wikipedia_url"
		case breedExplaining = "description"
		case hairless, image
	}
}

func getBreeds(from url: URL) async throws -> [Breed] {
	guard let url = URL(string: url.absoluteString) else {
		throw APIError.invalidURL(url: url)
	}
	
	let (data, response) = try await URLSession.shared.data(from: url)
	
	guard let httpResponse = response as? HTTPURLResponse else {
		throw APIError.requestFailed(description: "unvalid response")
	}
	
	guard httpResponse.statusCode == 200 else {
		throw APIError.responseUnsuccessful(description: "status code \(httpResponse.statusCode)")
	}
	
	do {
		let decoder = JSONDecoder()
		let result = try decoder.decode([Breed].self, from: data)
		return result
	} catch {
		throw APIError.jsonConversionFailure(description: error.localizedDescription)
	}
}


Task {
	let url = URL(string: "https://api.thecatapi.com/v1/breeds?limit=1")!
	let printable = try await getBreeds(from: url)
	print(printable)
}
