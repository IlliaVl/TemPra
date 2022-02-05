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
        NavigationView {
            List(locationsWeatherViewModel.locationsWeather ?? []) { locationWeather in
                LocationWeatherRowView(locationWeather: locationWeather)
            }.refreshable {
                locationsWeatherViewModel.refresh()
            }
            .navigationTitle("Forecast")
        }
        .onAppear(perform: locationsWeatherViewModel.refresh)
        .alert("Something went wrong. Try later, please.", isPresented: Binding<Bool>(get: {locationsWeatherViewModel.weatherError != nil},set: {_ in}), actions: {
        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LocationsWeatherView(locationsWeatherViewModel: LocationsWeatherViewModel(weatherFetcher: MetaWeatherAPI()))
        }
    }
}
