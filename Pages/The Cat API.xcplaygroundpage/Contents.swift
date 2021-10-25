//: [Previous](@previous)

import Foundation

/*
 [
	 {
	 "id":"abys",
	 "name":"Abyssinian",
	 "temperament":"Active, Energetic, Independent, Intelligent, Gentle",
	 "origin":"Egypt",
	 "description":"The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
	 "life_span":"14 - 15",
	 "hairless":0,
	 "wikipedia_url":"https://en.wikipedia.org/wiki/Abyssinian_(cat)",
	 "hypoallergenic":0,
	 "reference_image_id":"0XYvRd7oD",
	 "image": {
		 "id":"0XYvRd7oD",
		 "width":1204,
		 "height":1445,
		 "url":"https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"
		 }
	 }
 ]
*/


struct Breed: Codable, CustomStringConvertible {
	let id: String
	let name: String
	let temperament: String?
	let origin: String?
	let wikipediaLink: URL?
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

let url = URL(string: "https://api.thecatapi.com/v1/breeds?limit=1")!

let request = URLSession.shared.dataTask(with: url) { data, response, error in
	if let data = data, let breed = try? JSONDecoder().decode([Breed].self, from: data) {
		print(breed)
	}
}
request.resume()

//: [Next](@next)
