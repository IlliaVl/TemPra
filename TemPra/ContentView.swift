//
//  ContentView.swift
//  TemPra
//
//  Created by Illia Vlasov on 30.01.2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var viewModel: LocationsTomorrowWeatherViewModel
    
    var body: some View {
        if viewModel.locationTomorrowWeather == nil {
            ProgressView().onAppear(perform: viewModel.refresh)
        } else {
            List(viewModel.locationTomorrowWeather!) { locationTomorrowWeather in
                CurrentWeatherRow(viewModel: locationTomorrowWeather)
            }.refreshable {
                viewModel.refresh()
            }
            
        }
//        VStack {
//            ProgressView()
//            List(viewModel.locationTomorrowWeather!) { locationTomorrowWeather in
//                CurrentWeatherRow(viewModel: locationTomorrowWeather)
//            }
//            .onAppear(perform: viewModel.refresh)
//        }
        //        List(content: content)
        //            .onAppear(perform: viewModel.refresh)
        //            .listStyle(GroupedListStyle())
        
        //        Text("Hello, world!")
        //            .padding().onAppear {
        //                viewModel.refresh()
        ////                _ = MetaWeatherAPI().fetchLocation(city: "London").sink {value in
        ////                    switch value {
        ////                    case .failure:
        //////                        self.dataSource = nil
        ////                        break
        ////                    case .finished: break
        ////                    }
        ////                } receiveValue: { response in
        ////                    print(String(describing: response))
        ////                }
        //            }
    }
}

//private extension ContentView {
//    func content() -> some View {
//        if let viewModel = viewModel.locationTomorrowWeather {
//            return AnyView(details(for: viewModel))
//        } else {
//            return AnyView(loading)
//        }
//    }
//
//    func details(for viewModel: LocationTomorrowWeather) -> some View {
//        CurrentWeatherRow(viewModel: viewModel)
//    }
//
//    var loading: some View {
//        Text("Loading weather...")
//            .foregroundColor(.gray)
//    }
//}

struct CurrentWeatherRow: View {
    private let viewModel: LocationTomorrowWeather
    
    init(viewModel: LocationTomorrowWeather) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            //      MapView(coordinate: viewModel.coordinate)
            //        .cornerRadius(25)
            //        .frame(height: 300)
            //        .disabled(true)
            
            //      VStack(alignment: .leading) {
            //        HStack {
            //          Text("☀️ Temperature:")
            //          Text("\(viewModel.temperature)°")
            //            .foregroundColor(.gray)
            //        }
            
            HStack {
                AsyncImage(url: viewModel.weatherStateImageURL)
                Text(viewModel.title).font(.title)
            }
            
            HStack {
                Text("📈 Max temperature:")
                Text("\(viewModel.maxTemp)°")
                    .foregroundColor(.gray)
            }

            HStack {
                Text("📉 Min temperature:")
                Text("\(viewModel.minTemp)°")
                    .foregroundColor(.gray)
            }
            
            //        HStack {
            //          Text("💧 Humidity:")
            //          Text(viewModel.humidity)
            //            .foregroundColor(.gray)
            //        }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: LocationsTomorrowWeatherViewModel(weatherFetcher: MetaWeatherAPI()))
    }
}
