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
}

extension URLSessionConfiguration {
    func configure() {
        httpAdditionalHeaders = ["X-Api-Key":"e2502090-b764-406f-885f-c6e9f159bf1b"]
        isDiscretionary = true
        sessionSendsLaunchEvents = true
    }
}

class API: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    
    private var downloadTask : URLSessionDownloadTask?
    private var uploadTask : URLSessionUploadTask?
    private var baseURL = "https://ego-vehicle-api.azurewebsites.net/api/v1/"
    
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
    
    func signals(callback: ((_ signals: VehicleSignals) -> ())?) {
        start(url: "vehicle/signals") { (signals) in
            callback?(signals)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("bytesSent: \(bytesSent) • totalBytesSent: \(totalBytesSent) • totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
    }
    
    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print(response)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error)
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
