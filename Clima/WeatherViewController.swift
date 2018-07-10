//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = API()
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        
        
        // Sets "self" as the delegate to handle location information once retrieved (i.e., this app will handle the locaiton information using the variable "locationManager"
        locationManager.delegate = self
        
        // How close to exact location is the "desiredAccuracy" set
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Asks if location can be used when in use. Also has other options for location services as methods.
        // Had to update PList with 3 bits of information before this was possible
        // Used the workaround for getting to HTTP instead of HTTPS sites
        locationManager.requestWhenInUseAuthorization()
        
        // Updates location
        // Asynchronous method, working in the background while the rest of the app loads.
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    // Our created function to get the weather data using Alamofire's built-in request functionality and openweather's API requirements.
    func getWeatherData(url: String, parameters: [String: String]) {
        
        // This function request is Alamofire's set request that it uses to get a JSON file.
        // The 'url' parameter is the url that we are requesting, i.e., WEATHER_URL at the top.
        // The '.get' method is an HTTP request to retrieve information.
        // The 'parameters' paramater are those parameters that are set by API that we are getting information from, i.e., WEATHER_URL
        // The '.responseJSON' refers to the fact that the response is going to be a JSON file, and makes a closure after it.
        // *** The 'request' is asynchronous, i.e., in the background, instead of freezing up the app until it is done.
        // *** When the 'request' is done, the 'responseJSON' is run.
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                // The JSON() conversion is part of the SwiftyJSON file, not Swift itself.
                let weatherJSON: JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                // Alamofire's automatic error description
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
            
        }
        
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON) {
        
        // SwiftyJSON uses [] as sections of its dictionary results.
        // Conversion from JSON not an array or dictionary as in Swift, but the JSON structure DEFINED in SwiftyJSON, instead.
        // .double and .string conversion part of SwiftyJSON, as well.
        
        // Converted from Kelvin to Celcius
        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            if let city = json["name"].string {
                weatherDataModel.city = city
            }
            
            if let condition = json["weather"][0]["id"].int {
                weatherDataModel.condition = condition
            }
            
            let iconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            weatherDataModel.weatherIconName = iconName
            
            updateUIWithWeatherData()
            
        } else {
            cityLabel.text = "Weather unavailable."
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        cityLabel.text = weatherDataModel.city
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //*** Write the didUpdateLocations method here:

    // Runs when the location could be found.
    // The [CLLocation] array is an array of locations that the function gets when finding the location. It starts off general, with a rough estimate, and then gets narrower and narrower, resulting in the final location result being the most accurate. Hence, then last CLLocation item in the array is the most accurate (the last index is what we want).
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        let location = locations[locations.count - 1]
        
        // Checks to make sure that there is a valid radius in a circle range of results that the location has found. If it is 0, then that means that there is no radius, and therefore no information.
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            // Just printed out to check to see if it works
            // print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)

            let longitude = String(location.coordinate.longitude)
            
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID.id]
            
            // Calling the created getWeatherData function we defined ourselves above.
            // Used with the openweather API and the parameters it requires, i.e., a dictionary called 'params'
            // These are passed to our function
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }
        
    }
    
    
    //*** Write the didFailWithError method here:
    
    // Runs when there is an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
//    func userEnteredANewCityName(city: String) {
//
//        let params: [String: String] = ["q" : city, "appid": APP_ID.id]
//
//        getWeatherData(url: WEATHER_URL, parameters: params)
//
//        print("Feces")
//
//    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
//            let destinationVC = segue.destination as! ChangeCityViewController
            
//            destinationVC.anus = self
            
        }
        
    }
    
    
    
    
}


