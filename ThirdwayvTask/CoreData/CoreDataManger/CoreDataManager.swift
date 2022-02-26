//
//  CoreDataManager.swift
//  ThirdwayvTask
//
//  Created by Ibrahim Mo Gedami on 26/02/2022.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    func prepare(dataForSaving: [ProductData])
    var managedObjectContext : NSManagedObjectContext  { get }
}

class CoreDataManager: NSObject , CoreDataManagerProtocol{
    
    private override init() {
        super.init()
        applicationLibraryDirectory()
    }
    
    // Get the location where the core data DB is stored
    private lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1])
        return urls[urls.count-1]
    }()
    
    
    private func applicationLibraryDirectory() {
        print(applicationDocumentsDirectory)
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
    
    // MARK: - Core Data stack
    
    // Get the managed Object Context
    lazy var managedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    // Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "ThirdwayvTask")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func prepare(dataForSaving: [ProductData]){
        
        _ = dataForSaving.map{self.createEntityFrom(product: $0)}
        saveData()
    }
    
    private func createEntityFrom(product: ProductData?) -> ProductItem?{
        
        // Create relationship
        let productItemEntity = ProductItem(context: managedObjectContext)
        let productImageEntity = ProductItem(context: managedObjectContext)
        productImageEntity.image = productItemEntity
        productImageEntity.myProduct
        
        // Add Image to product
        productItemEntity.addToMyProduct(productImageEntity)
        
        // Check for all values
        guard let description = product?.productDescription,let price = product?.price,let image = product?.image else {return nil}
        
        // Convert
        let productItem = ProductItem(context: self.managedObjectContext)
        productItem.price = Int32(price)
        productItem.descrption = description
        productItem.image = image as! NSObject?
        
        return productItem
        
    }
    // Save the data in Database
    func saveData(){
        
        let context = self.managedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Save Data in background
    func saveDataInBackground() {
        
        persistentContainer.performBackgroundTask { (context) in
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
