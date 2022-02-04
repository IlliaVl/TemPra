//
//  TemPraTests.swift
//  TemPraTests
//
//  Created by Illia Vlasov on 30.01.2022.
//

import XCTest
import Combine
@testable import TemPra

class TemPraTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cancellables = []
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_gettingTomorrowsWeather_success() throws {
        let expectation = XCTestExpectation(description: "Expectation is not fulfilled")
        
        let locationsWeatherViewModel = LocationsWeatherViewModel(weatherFetcher: MetaWeatherAPI())
        locationsWeatherViewModel.$locationsWeather.dropFirst().sink { completion in
            switch completion {
            case .failure(let error):
                print(error)
                XCTFail("Unexpected error")
            case .finished:
                print("Success")
            }
        } receiveValue: { locationWeather in
            XCTAssertEqual(locationWeather!.count, 6)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        locationsWeatherViewModel.refresh()

        wait(for: [expectation], timeout: 10)
    }
}
