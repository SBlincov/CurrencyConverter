//
//  ViewController.swift
//  Currency converter
//
//  Created by Блинцов Сергей on 09/02/2018.
//  Copyright © 2018 Блинцов Сергей. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currencies = ["RUB", "USD", "EUR"]
    var avalibleCurrencies = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        if Reachability.isConnectedToNetwork() == true {
            self.requestCurrentCurrencyList()
            self.requestCurrentCurrencyRate()
        } else {
            label.text = "No internet connection"
            noInternetConnectionAlert()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Alert
    func noInternetConnectionAlert() -> Void {
        let alert = UIAlertController(title: "No internet connection", message: "Connect to the internet and try again😉", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (cancel) in
            print("Notification got")
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    // Get currency rates from server
    func requestCurrencyRates(baseCurrency : String, parseHandler : @escaping (Data?, Error?) -> Void) {
        if Reachability.isConnectedToNetwork() == true {
            let url = URL(string: "https://api.fixer.io/latest?base=" + baseCurrency)!
            
            let dataTask = URLSession.shared.dataTask(with: url) {
                (dataReceived, response, error) in
                parseHandler(dataReceived, error)
            }
            
            dataTask.resume()
        } else {
            label.text = "No internet connection"
            noInternetConnectionAlert()
        }
    }
    
    // Retrieve currency rate from response
    func retrieveCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String) -> Void) {
        self.requestCurrencyRates(baseCurrency: baseCurrency) { [weak self] (data, error) in
            var string = "No currency retrieved!"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                if let strongSelf = self {
                    string = strongSelf.parseCurrencyRatesResponse(data: data, toCurrency: toCurrency)
                }
            }
            
            completion(string)
        }
    }
    
    // Parse JSON object
    func parseCurrencyRatesResponse(data: Data?, toCurrency: String) -> String {
        var value : String = ""
        
        do{
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                print("\(parsedJSON)")
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double>{
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                    } else {
                        value = "No rate for currency \"\(toCurrency)\" found"
                    }
                } else {
                    value = "No \"rates\" field found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch {
            value = error.localizedDescription
        }
        
        return value
    }
    
// Get currency list
    // Get avaliable rates
    func requestAvalibleRates(parseHandler : @escaping (Data?, Error?) -> Void) {
        if Reachability.isConnectedToNetwork() == true{
            let url = URL(string: "https://api.fixer.io/latest")!
        
            let dataTask = URLSession.shared.dataTask(with: url) {
                (dataReceived, response, error) in
                parseHandler(dataReceived, error)
            }
        
            dataTask.resume()
        } else {
            label.text = "No internet connection"
            noInternetConnectionAlert()
        }
    }
    
    // Retrieve currency list from response
    func retrieveCurrencyList(completion: @escaping (String) -> Void) {
        self.requestAvalibleRates() { [weak self] (data, error) in
            var string = "List of currency didn't retrieved!"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                if let strongSelf = self {
                    string = strongSelf.parseCurrencyListResponse(data: data)
                }
            }
            
            completion(string)
        }
    }
    
    // Parse JSON object with list
    func parseCurrencyListResponse(data: Data?) -> String {
        var value : String = ""
        
        do{
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {

                if let rates = parsedJSON["rates"] as? Dictionary<String, Double>{
                    for (signCurrency, _) in rates{
                            avalibleCurrencies.append(signCurrency)
                    }
                } else {
                    value = "List of currencies not found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch {
            value = error.localizedDescription
        }
        currencies = avalibleCurrencies
        pickerTo.reloadAllComponents()
        pickerFrom.reloadAllComponents()
        return value
    }
    
    // Request currency list
    func requestCurrentCurrencyList() {
        self.retrieveCurrencyList() {[weak self] (value) in
            DispatchQueue.main.async(execute: {
                if let strongSelf = self {
                    strongSelf.label.text = value
                }
            })
        }
    }
    
// END get curency list
    
    
    // Except same currencies in picker
    func currenciesExceptBase() -> [String] {
        var currenciesExceptBase = currencies
        currenciesExceptBase.remove(at: pickerFrom.selectedRow(inComponent: 0))
        
        return currenciesExceptBase
    }
    
    // Request current currency rate
    func requestCurrentCurrencyRate() {
        self.activityIndicator.startAnimating()
        self.label.text = ""
        
        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = self.currencies[baseCurrencyIndex]
        let toCurrency = self.currenciesExceptBase()[toCurrencyIndex]
        
        self.retrieveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) {[weak self] (value) in
            DispatchQueue.main.async(execute: {
                if let strongSelf = self {
                    strongSelf.label.text = value
                    strongSelf.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
// Releases of protocols
    
    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === pickerTo {
            return self.currenciesExceptBase()[row]
        }
 
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === pickerFrom {
            self.pickerTo.reloadAllComponents()
        }
        
        self.requestCurrentCurrencyRate()
    }
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === pickerTo {
           return self.currenciesExceptBase().count
        }
        
        return currencies.count
    }
    
    
}

