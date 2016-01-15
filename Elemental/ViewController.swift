//
//  ViewController.swift
//  Elemental
//
//  Created by Gaetano Herman on 26/12/15.
//  Copyright © 2016 Gaetano Herman. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //Variabelen CoreData
    var temp: Int?
    var kansRegen: Int?
    var vochtigheid: Int?
    var info: String?
    
    
    //Elemental UI 
    @IBOutlet weak var huidigeTempLabel: UILabel?
    @IBOutlet weak var huidigeKansOpRegenLabel: UILabel?
    @IBOutlet weak var huidigeVochtigheidLabel: UILabel?
    @IBOutlet weak var huidigeWeerOverzicht: UILabel?
    @IBOutlet weak var refreshButton: UIButton?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    //CoreLocation
    var manager: CLLocationManager!
    var currentLocation: CLLocation!
    
    //APIKey voor API call te kunnen maken
    private let APIKEY = "2dba44c7d9d743c23af9424d598f6fa6"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Wanneer view geladen is maken we aan manager aan voor het regelen van de CoreLocation
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        //CurrentLocatie opvullen met de locatie gevonden door de manager gebruikt bij de API Call
        self.manager.stopUpdatingLocation()
        self.manager.startUpdatingLocation()
        self.currentLocation = self.manager.location
        self.vraagWeerDataOp()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func vraagWeerDataOp(){
        //Variabelen instellen om data te kunnen opvragen aan de hand van eigen positie
        let lat: Double = currentLocation.coordinate.latitude
        let long: Double = currentLocation.coordinate.longitude
        
        //Asynchrone API Call die alle benodigde informatie van de call in huidigWeer steekt
        //Zo kunnen we gemakkelijk de corresponderende textfields aanpassen
        let forecastService = ForecastService(APIKey: APIKEY)
        forecastService.getWeerbericht(lat, long: long){
            (let huidig) in
            if let huidigWeer = huidig {
                dispatch_async(dispatch_get_main_queue()){
                    
                    if let temperatuur = huidigWeer.temperatuur {
                        self.huidigeTempLabel?.text = "\(temperatuur)°"
                        self.temp = temperatuur
                    }
                    
                    if let vochtigheid = huidigWeer.luchtvochtigheid {
                        self.huidigeVochtigheidLabel?.text = "\(vochtigheid)%"
                        self.vochtigheid = vochtigheid
                        
                    }
                    
                    if let regenkans = huidigWeer.kansVoorRegen {
                        self.huidigeKansOpRegenLabel?.text = "\(regenkans)%"
                        self.kansRegen = regenkans
                    }
                    
                    if let overzicht = huidigWeer.info {
                        self.huidigeWeerOverzicht?.text = "Overzicht: \(overzicht)"
                        self.info = overzicht
                    }
                    //Wanneer de call finished is stoppen we met de animatie te tonen
                    self.toggleAnimation(false)
                    
                }
            }
        }
    }
    
    
    @IBAction func saveToCoreData() {
        //Opvragen van AppDelegate
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        //ManagedContext opvragen, dit is nodig om met CoreData te kunnen werken
        let managedContext = appDelegate.managedObjectContext
        
        //Entiteit opvragen aan de hand van de name Weer, met deze entiteit vragen we een Weerobject op
        //waar we gebruik van kunnen maken voor CoreData
        let entity =  NSEntityDescription.entityForName("Weer",
            inManagedObjectContext:managedContext)
        let weer = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //Values die we kregen van de APICall opslaan in het Weerobject
        weer.setValue(self.temp, forKey: "temperatuur")
        weer.setValue(self.kansRegen, forKey: "kansRegen")
        weer.setValue(self.info, forKey: "info")
        weer.setValue(self.vochtigheid, forKey: "vochtigheid")

        //Proberen van object op te slaan aan de hand van de do-catch
        do {
            try managedContext.save()
            print("Weerobject succesvol opgeslaan.")
        } catch let error as NSError  {
            print("Kan WeerObject niet opslaan, meer info te vinden bij deze \(error).")
        }
    }

    //Opnieuw opvragen van de data als gebruiker bv. van locatie verandert
    @IBAction func refreshData() {
        toggleAnimation(true)
        vraagWeerDataOp()
    }
    
    //Toggle animatie voor het refreshen van de data
    func toggleAnimation(on: Bool){
        refreshButton?.hidden = on
        if on {
            activityIndicator?.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
        }
    }
}

