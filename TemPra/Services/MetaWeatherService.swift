//
//  MetaWeatherService.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import Foundation
import Combine

class MetaWeatherAPI {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - MetaWeatherAPIFetchable

extension MetaWeatherAPI: WeatherAPIFetchable {
    
    func smallImageUrl(imageId: String) -> URL? {
        URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(imageId).png")
    }
    
    func fetchWeather(location: String) -> AnyPublisher<WeatherForecastResponse, WeatherError> {
        var locationUrlComponents = getComponents(path: "search/")
        locationUrlComponents.queryItems = [URLQueryItem(name: "query", value: location)]
        guard let url = locationUrlComponents.url else {
          return Fail(error: WeatherError.network(description: "Couldn't create URL")).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: url)
            .mapError { error in
                WeatherError.network(description: error.localizedDescription)
            }
            .map(\.data)
            .decode(type: LocationResponses.self, decoder: JSONDecoder())
            .mapError { error in
                WeatherError.parsing(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { locationsResponse  in
                return URLSession.shared.dataTaskPublisher(for: self.getComponents(path: "\(locationsResponse[0].woeid)/").url!)
                    .mapError {
                        WeatherError.network(description: $0.localizedDescription)
                    }.eraseToAnyPublisher()
            }
            .map(\.data)
            .decode(type: WeatherForecastResponse.self, decoder: JSONDecoder())
            .mapError { error in
                WeatherError.parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchTomorrowWeather(locations: [String]) -> AnyPublisher<[WeatherForecastResponse], WeatherError> {
        return Publishers.MergeMany(locations.map({ location -> AnyPublisher<WeatherForecastResponse, WeatherError> in
            return fetchWeather(location: location)
        })).collect().eraseToAnyPublisher()
    }
}

// MARK: - URLSession components

private extension MetaWeatherAPI {
    private func getComponents(path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.metaweather.com"
        components.path = "/api/location/\(path)"
        return components
    }
    
    private func makeLocationComponents(city: String) -> URLComponents {
        var components = getComponents(path: "search")
        components.queryItems = [URLQueryItem(name: "query", value: city)]
        return components
    }
    
    private func makeTomorrowWeatherComponents(woeid: Int) -> URLComponents {
        return getComponents(path: "\(woeid)")
    }
}
