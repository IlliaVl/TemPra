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
    
    func fetchWeather(location: String) -> AnyPublisher<WeatherForecastResponse, Error> {
        var locationUrlComponents = getComponents(path: "search/")
        locationUrlComponents.queryItems = [URLQueryItem(name: "query", value: location)]
        return URLSession.shared.dataTaskPublisher(for: locationUrlComponents.url!)
            .map(\.data)
            .decode(type: LocationResponses.self, decoder: JSONDecoder()).flatMap(maxPublishers: .max(1)) { locationsResponse -> Publishers.MapError<URLSession.DataTaskPublisher, Error> in
                print("locationsResponse[0]: \(locationsResponse[0])")
                return URLSession.shared.dataTaskPublisher(for: self.getComponents(path: "\(locationsResponse[0].woeid)/").url!)
                    .mapError { $0 as Error }
            }
            .map(\.data)
            .decode(type: WeatherForecastResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchTomorrowWeather(locations: [String]) -> AnyPublisher<[WeatherForecastResponse], Error> {
        return Publishers.MergeMany(locations.map({ location -> AnyPublisher<WeatherForecastResponse, Error> in
            print(location)
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
    
    func makeLocationComponents(city: String) -> URLComponents {
        var components = getComponents(path: "search")
        components.queryItems = [URLQueryItem(name: "query", value: city)]
        return components
    }
    
    func makeTomorrowWeatherComponents(woeid: Int) -> URLComponents {
        return getComponents(path: "\(woeid)")
    }
}
