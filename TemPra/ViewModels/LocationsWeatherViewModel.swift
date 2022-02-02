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
    
    private let cities = ["Gothenburg", "Stockholm", "Mountain View", "London", "New York", "Berlin"]
    private let weatherFetcher: WeatherAPIFetchable
    private var disposables = Set<AnyCancellable>()
    
    init(
        weatherFetcher: WeatherAPIFetchable,
        scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
    ) {
        self.weatherFetcher = weatherFetcher
    }
    
    func refresh() {
        weatherFetcher.fetchTomorrowWeather(locations: cities)
            .map { response in
                response.map { [weak self] weatherForecastResponse -> LocationWeather in
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
