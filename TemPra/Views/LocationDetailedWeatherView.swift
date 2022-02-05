//
//  LocationDetailedWeatherView.swift
//  TemPra
//
//  Created by Illia Vlasov on 04.02.2022.
//

import SwiftUI

struct LocationDetailedWeatherView: View {
    private let locationWeather: LocationWeather
    
    init(locationWeather: LocationWeather) {
        self.locationWeather = locationWeather
    }
    
    var body: some View {
        VStack {
            Text("Today").font(.largeTitle.bold())
            HStack {
                AsyncImage(url: locationWeather.dailyForecast[0].weatherStateImageURL)
                Text(locationWeather.dailyForecast[0].stateName).font(.title)
            }
            HStack {
                Spacer()
                Text("Max:")
                Text(locationWeather.dailyForecast[0].maxTempString)
                    .foregroundColor(.red)
                Spacer()
                Text("Min:")
                Text(locationWeather.dailyForecast[0].minTempString)
                    .foregroundColor(.blue)
                Spacer()
            }
            List(locationWeather.dailyForecast) {forecast in
                ForecastRowContentView(title: forecast.stateName, forecast: forecast)
            }
        }
        .navigationBarTitle(Text(locationWeather.title), displayMode: .inline)
    }
}

struct LocationDetailedWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailedWeatherView(locationWeather: LocationWeather.mockValue)
    }
}
