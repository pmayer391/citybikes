//
//  CoreDataController.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/6/21.
//

import Foundation
import CoreData

class CoreDataController {

    //MARK: - Variables
    static let shared = CoreDataController()
    
    private let networksEntity = "CDNetworks"

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CityBikes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("DB Path:", storeDescription.url?.absoluteString ?? "")
            
//            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            print(paths[0])
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var backgroundContext: NSManagedObjectContext = {
        return CoreDataController.shared.persistentContainer.newBackgroundContext()
    }()
    
    
    //MARK: - Functions
    func fetchNetworksOnBackground(mainThread: Bool, completion: @escaping NetworksCoreDataHandler){
        backgroundContext.perform{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.networksEntity)
            do {
                let manageObj = try self.backgroundContext.fetch(fetchRequest)
                if let cdNetworks = manageObj as? [CDNetworks]{
                    if mainThread{
                        completion(self.getNetworkObjFromCDNetworkForMainThread(cdNetworks), nil)
                    } else{
                        completion(nil, cdNetworks)
                    }
                } else{
                    completion(nil, nil)
                }
            } catch let error as NSError{
                debugPrint("Could Not Fetch Core Data: \(error), \(error.userInfo)")
                completion(nil, nil)
            }
        }
    }
    
    func refreshNetworksOnBackground(_ networks: [Networks]){
        fetchNetworksOnBackground(mainThread: false) { (nil, cdNetworks) in
            for cdNetwork in cdNetworks ?? [] {
                self.backgroundContext.delete(cdNetwork)
            }
            self.saveNetworksOnBackground(networks)
        }
    }
    
    private func saveNetworksOnBackground(_ networks: [Networks]){
        self.backgroundContext.perform{
            self.backgroundContext.reset()
            for network in networks{
                let cdNetwork = CDNetworks(context: self.backgroundContext)
                cdNetwork.href = network.href
                cdNetwork.id = network.id
                cdNetwork.name = network.name
                let cdLocation = CDLocation(context: self.backgroundContext)
                cdLocation.city = network.location?.city
                cdLocation.country = network.location?.country
                cdLocation.latitude = network.location?.latitude ?? 0.0
                cdLocation.longitude = network.location?.longitude ?? 0.0
                cdNetwork.location = cdLocation
            }
            if self.backgroundContext.hasChanges{
                do {
                    try self.backgroundContext.save()
                } catch let error as NSError{
                    debugPrint("Could Not Save Core Data: \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    private func getNetworkObjFromCDNetworkForMainThread(_ cdNetworks: [CDNetworks]) -> [Networks]{
        var networks: [Networks] = []
        for network in cdNetworks{
            let cdObj = CoreDataController.shared.persistentContainer.viewContext.object(with: network.objectID) as? CDNetworks
            let networkObj = Networks()
            networkObj.href = cdObj?.id
            networkObj.id = cdObj?.id
            networkObj.name = cdObj?.name
            let locationObj = Location()
            locationObj.city = cdObj?.location?.city
            locationObj.country = cdObj?.location?.country
            locationObj.latitude = cdObj?.location?.latitude
            locationObj.longitude = cdObj?.location?.longitude
            networkObj.location = locationObj
            networks.append(networkObj)
        }
        return networks
    }
}







