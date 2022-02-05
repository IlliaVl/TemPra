//
//  Extensions.swift
//  TemPra
//
//  Created by Illia Vlasov on 05.02.2022.
//

import Foundation


extension Double {
    func toCelsius() -> String {
        String(format: "%.2f", self) + "°C"
    }
}
