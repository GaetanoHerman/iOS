//
//  Service.swift
//  Elemental
//
//  Created by Gaetano Herman on 26/12/15.
//  Copyright © 2016 Gaetano Herman. All rights reserved.
//

import Foundation

class Service {
    
    //Variabelen nodig voor de request te completen
    lazy var session: NSURLSession = NSURLSession(configuration: self.config)
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let url: NSURL
    
    //Init methode van de klasse Service
    init(url : NSURL){
        self.url = url
    }
    
    //Downloaden van de JSON
    func downloadTask(completion: ([String: AnyObject]?) -> Void){
        
        //Maken van de URL waar we de request mee gaan uitvoeren
        let forecastRequest: NSURLRequest = NSURLRequest(URL: url)
        //Task aanmaken met de NSURLSession deze methode returnt data, response en error
        let task  = session.dataTaskWithRequest(forecastRequest) {
            (let data, let response, let error) in
            //als er een response is gaan we kijken naar de request code van de response
            if let httpResponse = response as? NSHTTPURLResponse {
                //We switchen dus op de statusCode van de HTTPResponse, als de 200 is, is de task goed uitgevoerd en hebben we dus data teruggekregen, als dit niet zo is throwen we een error
                switch(httpResponse.statusCode){
                case 200:
                    do {
                        //De dictionary ophalen aan de hand van de JSONSerialization, data kan ook soms nil zijn daarom dat we do-catch uitvoeren
                        let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
                        completion(dictionary)
                    } catch let error {
                        print("Error: \(error)")
                    }
                default:
                print("Cannot make HTTP Request, make sure you have internet!")
                }
            } else {
                print("Cannot make HTTP Request")
            }
        }
        //Task resumen 
        task.resume()
    }
    
}
