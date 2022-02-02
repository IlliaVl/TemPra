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
        VStack(alignment: .leading) {
            if (locationWeather.weatherStateImageURL != nil) {
                HStack {
                    AsyncImage(url: locationWeather.weatherStateImageURL)
                    Text(locationWeather.title).font(.title)
                }
            } else {
                Text(locationWeather.title).font(.title)
            }
            
            HStack {
                Text("Max temperature:")
                Spacer()
                Text(locationWeather.maxTempString)
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("Min temperature:")
                Spacer()
                Text(locationWeather.minTempString)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct LocationWeatherRowView_Previews: PreviewProvider {
    static var previews: some View {
        LocationWeatherRowView(locationWeather: LocationWeather(
            id: 1,
            //            weatherStateImageURL: URL(string: "https://www.metaweather.com/static/img/weather/png/64/s.png"),
            title: "London",
            minTemp: 11.11,
            minTempString: "11.11°C",
            maxTemp: 22.22,
            maxTempString: "22.22°C"
        ))
    }
}
