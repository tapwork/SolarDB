//
//  API.swift
//  SolarDBeGO
//
//  Created by StuFF mc on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import Foundation

struct VehicleSignals: Codable {
    var batteryLoadingCapacity: Double // i.e. 3.6 kW (one phase 16 A)
    var batteryTotalKwhCapacity: Double // i.e. 24 kWh (Battery size)
    var batteryStateOfCharge: Int // Latest battery level in percent
    var batteryCharging: String
}

extension URLSessionConfiguration {
    func configure() {
        httpAdditionalHeaders = ["X-Api-Key":"e2502090-b764-406f-885f-c6e9f159bf1b"]
        isDiscretionary = true
        sessionSendsLaunchEvents = true
    }
}

// https://ego-vehicle-api.azurewebsites.net
class API: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    static let shared = API()

    private var downloadTask : URLSessionDownloadTask?
    private var uploadTask : URLSessionUploadTask?
    private var dataTask : URLSessionDataTask?
    private let baseURL = "https://ego-vehicle-api.azurewebsites.net/api/v1/"
    
    var signals = VehicleSignals(batteryLoadingCapacity: 0, batteryTotalKwhCapacity: 0, batteryStateOfCharge: 0, batteryCharging: "no")
    
    var callback: ((_ signals: VehicleSignals) -> ())?
    
    private func urlSession(with configuration: URLSessionConfiguration) -> URLSession {
        configuration.configure()
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
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
        let configuration = URLSessionConfiguration.background(withIdentifier: "MySession")
        downloadTask = urlSession(with: configuration).downloadTask(with: url)
        downloadTask?.resume()
    }
    
    func upload(url: String, with data: Data) {
        guard let url = URL(string: "\(baseURL)\(url)") else {
            print("Couldn't find JSON!")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("image/png", forHTTPHeaderField: "Content-Type")
        let configuration = URLSessionConfiguration.default
        uploadTask = urlSession(with: configuration).uploadTask(with: request, from: data)
        uploadTask?.resume()
    }
    
    func data(url: String, stateOfCharge: Double, charging: Bool) {
        guard let url = URL(string: "\(baseURL)\(url)") else {
            print("Couldn't find JSON!")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let signals = VehicleSignals(batteryLoadingCapacity: API.shared.signals.batteryLoadingCapacity, batteryTotalKwhCapacity: API.shared.signals.batteryTotalKwhCapacity, batteryStateOfCharge: Int(stateOfCharge), batteryCharging: charging ? "yes" : "no")
        print(signals)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(signals)
        let configuration = URLSessionConfiguration.default
        dataTask = urlSession(with: configuration).dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("ERROR API: \(error)")
            }
        })
        dataTask?.resume()
    }
    
    func updateStateOfCharge(_ stateOfCharge: Double, charging: Bool) {
        data(url: "vehicle/signals", stateOfCharge: stateOfCharge, charging: charging)
    }
    
    func updateSignals(callback: ((_ signals: VehicleSignals) -> ())?) {
        start(url: "vehicle/signals") {
            callback?($0)
            self.signals = $0
        }
    }
    
    func updateInfotainment(with data: Data) {
        upload(url: "vehicle/infotainment", with: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("meth: \(String(describing: task.currentRequest?.httpMethod)) • task: \(String(describing: task.currentRequest?.url?.absoluteString)) • bytesSent: \(bytesSent) • totalBytesSent: \(totalBytesSent) • totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
    }
    
    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print(response)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("ERROR API: \(error)")
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
            callback?(signals)
            print("JSON error: \(error)")
            callback?(signals)
        }
    }
}
