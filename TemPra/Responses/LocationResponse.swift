//
//  MetaWeatherResponses.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

//
// To read values from URLs:
//
//   let task = URLSession.shared.welcomeElementTask(with: url) { welcomeElement, response, error in
//     if let welcomeElement = welcomeElement {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - LocationResponse
struct LocationResponse: Codable {
    let title, locationType: String
    let woeid: Int
    let lattLong: String

    enum CodingKeys: String, CodingKey {
        case title
        case locationType = "location_type"
        case woeid
        case lattLong = "latt_long"
    }
}

typealias LocationResponses = [LocationResponse]
