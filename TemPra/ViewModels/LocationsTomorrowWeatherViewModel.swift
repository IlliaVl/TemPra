//
//  LocationsTomorrowWeatherViewModel.swift
//  TemPra
//
//  Created by Illia Vlasov on 01.02.2022.
//

import Foundation
import Combine

class LocationsTomorrowWeatherViewModel: ObservableObject {
    @Published var locationTomorrowWeather: [LocationTomorrowWeather]?
    
    private let cities = ["Gothenburg", "Stockholm", "Mountain View", "London", "New York", "Berlin"]
    private let weatherFetcher: MetaWeatherAPIFetchable
    private var disposables = Set<AnyCancellable>()
    
    // 1
    init(
        weatherFetcher: MetaWeatherAPIFetchable,
        scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
    ) {
        self.weatherFetcher = weatherFetcher
    }
    
    func refresh() {
        weatherFetcher.fetchTomorrowWeather(locations: cities)
            .map { response in
                response.map { weatherForecastResponse -> LocationTomorrowWeather in
                    let weather = weatherForecastResponse.consolidatedWeather[1]
                    let weatherStateImageURL = URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(weather.weatherStateAbbr).png")
//                    print("Location: \(weatherForecastResponse.title), min: \(weather.minTemp), max: \(weather.maxTemp)")
                    return LocationTomorrowWeather(id: weather.id, weatherStateImageURL: weatherStateImageURL!, title: weatherForecastResponse.title, minTemp: weather.minTemp, maxTemp: weather.maxTemp)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Success1")
                }
            } receiveValue: { [weak self] locationsTomorrowWeather in
                print(String(describing: locationsTomorrowWeather))
                self?.locationTomorrowWeather = locationsTomorrowWeather
            }
            .store(in: &disposables)
        
    }
    
}

struct LocationTomorrowWeather: Identifiable {
    var id: Int
    
    var weatherStateImageURL: URL
    
    var title: String
    var minTemp: Double
    var maxTemp: Double
}
