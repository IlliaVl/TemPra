//
//  LocationWeatherRowView.swift
//  TemPra
//
//  Created by Illia Vlasov on 02.02.2022.
//

import SwiftUI

struct LocationWeatherRowView: View {
    private let locationWeather: LocationWeather
    
    init(locationWeather: LocationWeather) {
        self.locationWeather = locationWeather
    }
    
    var body: some View {
        NavigationLink(destination: LocationDetailedWeatherView(locationWeather: locationWeather)) {
            ForecastRowContentView(title: locationWeather.title,
                       forecast: locationWeather.tomorrowForecast)
        }
    }
    
}

struct LocationWeatherRowView_Previews: PreviewProvider {
    static var previews: some View {
        LocationWeatherRowView(locationWeather: .mockValue)
    }
}
