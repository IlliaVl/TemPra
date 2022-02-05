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
            let forecasts = weatherForecastResponse.consolidatedWeather.map { weather in
                Forecast(
                    id: weather.id,
                    stateName: weather.weatherStateName,
                    weatherStateImageURL: self?.weatherFetcher.smallImageUrl(imageId: weather.weatherStateAbbr),
                    minTemp: weather.minTemp,
                    minTempString: weather.minTemp.toCelsius(),
                    maxTemp: weather.maxTemp,
                    maxTempString: weather.maxTemp.toCelsius()
                )
            }
            return LocationWeather(
                id: weatherForecastResponse.woeid,
                dailyForecast: forecasts,
                title: weatherForecastResponse.title,
                tomorrowForecast: forecasts[1]
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
    var dailyForecast: [Forecast]
    var title: String
    var tomorrowForecast: Forecast
    static var mockValue = LocationWeather(
        id: 1,
        dailyForecast: [.mockValue, .mockValue, .mockValue, .mockValue],
        title: "London",
        tomorrowForecast: .mockValue
    )
}

struct Forecast: Identifiable {
    var id: Int
    var stateName: String
    var weatherStateImageURL: URL?
    var minTemp: Double
    var minTempString: String
    var maxTemp: Double
    var maxTempString: String
    
    static var mockValue = Forecast(
        id: 1,
        stateName: "Showers",
        weatherStateImageURL: URL(string: "https://www.metaweather.com/static/img/weather/png/64/s.png"),
        minTemp: 11.11,
        minTempString: "11.11°C",
        maxTemp: 22.22,
        maxTempString: "22.22°C"
    )
}
