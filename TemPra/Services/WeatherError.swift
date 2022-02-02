//
//  WeatherError.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import Foundation

enum WeatherError: Error {
  case parsing(description: String)
  case network(description: String)
}
