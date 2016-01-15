//
//  Weer.swift
//  Elemental
//
//  Created by Gaetano Herman on 26/12/15.
//  Copyright © 2016 Gaetano Herman. All rights reserved.
//

import Foundation
import UIKit

struct Weer {
    
    //Variabelen
    let temperatuur : Int?
    let kansVoorRegen : Int?
    let luchtvochtigheid : Int?
    let info : String?
    
    //Init methode van de Struct Weer, hier krijgen we dus een Dictionary van terug en gaan we de verschillende variabelen hieraan gelijkstellen
    init(weerData : [String:AnyObject]){
        temperatuur = weerData["temperature"] as? Int
        //Omvormen van Double naar Integers, zorgde voor compilatieproblemen
        if let luchtvochtigheidFloat = weerData["humidity"] as? Double {
            luchtvochtigheid = Int(luchtvochtigheidFloat * 100)
        } else {
            luchtvochtigheid = nil
        }
        if let kansVoorRegenFloat = weerData["precipProbability"] as? Double {
            kansVoorRegen = Int(kansVoorRegenFloat * 100)
        } else {
            kansVoorRegen = nil
        }
        info = weerData["summary"] as? String
    }
}
