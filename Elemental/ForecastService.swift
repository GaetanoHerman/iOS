//
//  ForecastService.swift
//  Elemental
//
//  Created by Gaetano Herman on 26/12/15.
//  Copyright © 2016 Gaetano Herman. All rights reserved.
//

import Foundation

struct ForecastService {
    
    //Variabelen
    let apiKey : String
    let url: NSURL?
    
    //Init methode die gebruikt wordt in de ViewController, maakt gebruik van de API key om de URL te maken waarmee we de calls gaan uitvoeren
    init(APIKey : String){
        self.apiKey = APIKey
        url = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
    }
    
    //GetWeerbericht die aan de service downloadTask zal aanroepen aan de hand van de ForecastURL waar we nu de latitude en longitude hebben ingestoken voor het opzoeken van het weerbericht voor een specifieke locatie
    func getWeerbericht(lat: Double, long: Double, completion: (Weer? -> Void)){
        if let forecastUrl = NSURL(string: "\(lat),\(long)", relativeToURL: url){
            
            let service = Service(url: forecastUrl)
            service.downloadTask {
                (let JSONDictionary) in
                let huidigWeer = self.huidigWeerVanJSON(JSONDictionary)
                completion(huidigWeer) 
            }
            
        } else {
            print("Error, weerbericht kan niet worden opgehaald, dit kan aan de APIKey liggen.")
        }
    }
    
    func huidigWeerVanJSON(jsonDictionary : [String: AnyObject]?) -> Weer? {
        //Indien er huidig weer beschikbaar is steek dit in de Dictionary anders geef een fout en return nil
        if let huidigWeerDictionary = jsonDictionary?["currently"] as? [String: AnyObject] {
            return Weer(weerData: huidigWeerDictionary)
        } else {
            print("Geen weerbericht gevonden voor huidig tijdstip...")
            return nil
        }
    }
}

