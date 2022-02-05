//
//  ForecastRowContentView.swift
//  TemPra
//
//  Created by Illia Vlasov on 05.02.2022.
//

import SwiftUI

struct ForecastRowContentView: View {
    private let title: String
    private let forecast: Forecast

    init(title: String, forecast: Forecast) {
        self.title = title
        self.forecast = forecast
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if (forecast.weatherStateImageURL != nil) {
                HStack {
                    AsyncImage(url: forecast.weatherStateImageURL)
                    Text(title).font(.title)
                }
            } else {
                Text(title).font(.title)
            }
            
            HStack {
                Text("Max temperature:")
                Spacer()
                Text(forecast.maxTempString)
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("Min temperature:")
                Spacer()
                Text(forecast.minTempString)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ForecastRowContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastRowContentView(title: "London", forecast: .mockValue)
    }
}
