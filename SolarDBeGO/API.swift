//
//  API.swift
//  SolarDBeGO
//
//  Created by StuFF mc on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation

struct VehicleSignals: Codable {
    var batteryLoadingCapacity: Double
    var batteryTotalKwhCapacity: Double
    var batteryStateOfCharge: Int
}

class API: NSObject, URLSessionDownloadDelegate {
    
    private var backgroundTask : URLSessionDownloadTask?
    private var baseURL = "https://ego-vehicle-api.azurewebsites.net/api/v1/"
    
    var callback: ((_ signals: VehicleSignals) -> ())?
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MySession")
        config.httpAdditionalHeaders = ["X-Api-Key":"e2502090-b764-406f-885f-c6e9f159bf1b"]
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func start(url: String, callback: ((_ signals: VehicleSignals) -> ())?) {
        guard let url = URL(string: "\(baseURL)\(url)") else {
            print("Couldn't find JSON!")
            return
        }
        guard let callback = callback else {
            print("Callback needed!")
            return
        }
        self.callback = callback
        backgroundTask = urlSession.downloadTask(with: url)
        backgroundTask?.resume()
    }
    
    func signals(callback: ((_ signals: VehicleSignals) -> ())?) {
        start(url: "vehicle/signals") { (signals) in
            callback?(signals)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let signals = try decoder.decode(VehicleSignals.self, from: data)
            callback?(signals)
        } catch {
            print("JSON error: \(error)")
        }
    }
}
