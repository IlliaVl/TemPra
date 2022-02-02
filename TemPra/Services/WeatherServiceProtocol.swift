//
//  WeatherServiceProtocol.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import Foundation
import Combine

protocol WeatherAPIFetchable {
    func smallImageUrl(imageId: String) -> URL?
    func fetchTomorrowWeather(locations: [String]) -> AnyPublisher<[WeatherForecastResponse], Error>
}
