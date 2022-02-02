//
//  MetaWeatherService.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import Foundation
import Combine

protocol MetaWeatherAPIFetchable {
    func fetchLocation(city: String) -> AnyPublisher<LocationResponse, WeatherError>
    func fetchTomorrowWeather(woeid: Int) -> AnyPublisher<WeatherForecastResponse, WeatherError>
    func fetchTomorrowWeather(locations: [String]) -> AnyPublisher<[WeatherForecastResponse], Error>
}

class MetaWeatherAPI {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - MetaWeatherAPIFetchable

extension MetaWeatherAPI: MetaWeatherAPIFetchable {
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
    
    func fetchLocation(city: String) -> AnyPublisher<LocationResponse, WeatherError> {
        return forecast(with: makeLocationComponents(city: city))
    }
    
    func fetchTomorrowWeather(woeid: Int) -> AnyPublisher<WeatherForecastResponse, WeatherError> {
        return forecast(with: makeTomorrowWeatherComponents(woeid: woeid))
    }
    
    private func forecast<T>(
        with components: URLComponents
    ) -> AnyPublisher<T, WeatherError> where T: Decodable {
        // 1
        guard let url = components.url else {
            let error = WeatherError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // 2
        return session.dataTaskPublisher(for: URLRequest(url: url))
        // 3
            .mapError { error in
            .network(description: error.localizedDescription)
            }
        // 4
            .flatMap(maxPublishers: .max(1)) { pair in
                self.decode(pair.data)
            }
        // 5
            .eraseToAnyPublisher()
    }
    
    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, WeatherError> {
        let justTest = Just(data).eraseToAnyPublisher()
        //            .decode(type: T.self, decoder: decoder)
        //            .mapError { error in
        //            .parsing(description: error.localizedDescription)
        //            }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
            .parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
    
    func welcomeTask(with url: URL, completionHandler: @escaping (WeatherForecastResponse?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}


// MARK: - URLSession components

private extension MetaWeatherAPI {
    //https://www.metaweather.com/api/location/search/?query=london
    //https://www.metaweather.com/api/location/44418/
    
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
