//
//  ContentView.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import SwiftUI
import Combine

struct LocationsWeatherView: View {
    
    @ObservedObject var locationsWeatherViewModel: LocationsWeatherViewModel
    
    var body: some View {
        VStack {
            Text("Tomorrow’s Weather Forecast").font(.headline).padding()
            if locationsWeatherViewModel.locationsWeather == nil {
                ProgressView().onAppear(perform: locationsWeatherViewModel.refresh)
            } else {
                List(locationsWeatherViewModel.locationsWeather!) { locationWeather in
                    LocationWeatherRowView(locationWeather: locationWeather)
                }.refreshable {
                    locationsWeatherViewModel.refresh()
                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LocationsWeatherView(locationsWeatherViewModel: LocationsWeatherViewModel(weatherFetcher: MetaWeatherAPI()))
        }
    }
}
