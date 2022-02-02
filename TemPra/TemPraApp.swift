//
//  TemPraApp.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import SwiftUI

@main
struct TemPraApp: App {
    var body: some Scene {
        WindowGroup {
            LocationsWeatherView(locationsWeatherViewModel: LocationsWeatherViewModel(weatherFetcher: MetaWeatherAPI()))
        }
    }
}
