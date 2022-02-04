//
//  LocationsTomorrowWeatherViewModel.swift
//  TemPra
//
//  Created by Illia Vlasov on 01.02.2022.
//

import Foundation
import Combine

class LocationsWeatherViewModel: ObservableObject {
    @Published var locationsWeather: [LocationWeather]?
    @Published var weatherError: WeatherError?

    private let cities = ["Gothenburg", "Stockholm", "Mountain View", "London", "New York", "Berlin"]
    private let weatherFetcher: WeatherAPIFetchable
    private var disposables = Set<AnyCancellable>()
    
    init(
        weatherFetcher: WeatherAPIFetchable,
        scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
    ) {
        self.weatherFetcher = weatherFetcher
    }
    
    private func mapWeatherForecastResponseToLocationWeather(response: [WeatherForecastResponse]) -> [LocationWeather] {
        return response.map { [weak self] weatherForecastResponse -> LocationWeather in
            let weather = weatherForecastResponse.consolidatedWeather[1]
            return LocationWeather(
                id: weather.id,
                weatherStateImageURL: self?.weatherFetcher.smallImageUrl(imageId: weather.weatherStateAbbr),
                title: weatherForecastResponse.title,
                minTemp: weather.minTemp,
                minTempString: weather.minTemp.toCelsius(),
                maxTemp: weather.maxTemp,
                maxTempString: weather.maxTemp.toCelsius()
            )
        }
    }
    
    func refresh() {
        weatherFetcher.fetchTomorrowWeather(locations: cities)
            .map(mapWeatherForecastResponseToLocationWeather)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    self?.locationsWeather = []
                    self?.weatherError = .network(description: error.localizedDescription)
                case .finished:
                    print("Success")
                    if self?.weatherError != nil {
                        self?.weatherError = nil
                    }
                }
            } receiveValue: { [weak self] locationsTomorrowWeather in
                self?.locationsWeather = locationsTomorrowWeather
            }
            .store(in: &disposables)
    }
    
}

struct LocationWeather: Identifiable {
    var id: Int
    
    var weatherStateImageURL: URL?
    
    var title: String
    var minTemp: Double
    var minTempString: String
    var maxTemp: Double
    var maxTempString: String
}

extension Double {
    func toCelsius() -> String {
        String(format: "%.2f", self) + "°C"
    }
}
