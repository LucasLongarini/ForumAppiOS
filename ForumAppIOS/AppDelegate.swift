//
//  AppDelegate.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-10.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    var userHelper: UserHelper = UserHelper()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().shadowImage = UIImage()
        application.statusBarStyle = .lightContent // .default
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var loggedIN: Bool = false
        var jwt: String = ""
        var userId:Int?
        //check if we have a jwt
        let managedObjectContext:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let jwtRequest:NSFetchRequest<Token> = Token.fetchRequest()
        
        let group = DispatchGroup()
        group.enter()
        do{
            let results = try managedObjectContext.fetch(jwtRequest)
            //none saved
            if results.count < 1{
                loggedIN = false
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginPage")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
                return true
                
            }
            //one saved
            else if results.count == 1{
                userHelper.checkedLogin(jwt: results[0].token!) { (loggedIn, userID) in
                    if loggedIn{
                        loggedIN = true
                        jwt = results[0].token!
                        userId = userID
                        group.leave()
                    }
                    else{
                        loggedIN = false
                        //delete invalid jwt
                        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
                        let deleteRequst = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                        do{try managedObjectContext.execute(deleteRequst)
                            try managedObjectContext.save()
                        }catch{print("error deleting all jwt's:\(error.localizedDescription)")}
                        group.leave()
                    }
                }
                
            }
            
            //more than one saved (should not happen) delete all
            else{
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Token")
                let deleteRequst = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                do{try managedObjectContext.execute(deleteRequst)
                    try managedObjectContext.save()
                }catch{print("error deleting all jwt's:\(error.localizedDescription)")}
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginPage")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
                return true
            }
        }
        catch{print("error getting jwt: \(error.localizedDescription)")}
        
        group.wait()
        if(loggedIN){
            //get personal user data
            userHelper.getUser(jwt: jwt, userId: userId!) { (result) in
                if let user = result{
                    PersonalUserSingleton.shared.updateUser(user: user)
                    PersonalUserSingleton.shared.jwt = jwt
                    if let url = user.pictureUrl{
                        PersonalUserSingleton.shared.updateImage(imageURL: url)
                    }
                }
            }
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainPage")
            let mainPageViewController = (((initialViewController as? UITabBarController)?.viewControllers![0] as? UINavigationController)?.viewControllers[0] as? MainPageViewController)
            mainPageViewController?.jwt = jwt
            mainPageViewController?.userId = userId
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else{
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginPage")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        return true

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ForumAppIOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isEqual(tabBarController.viewControllers?[1]){
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "CreatePostNav") as? UINavigationController {
                (newVC.viewControllers[0] as! CreatePostViewController).delegate = (tabBarController.viewControllers![0] as! UINavigationController).viewControllers[0] as! MainPageViewController
                tabBarController.present(newVC, animated: true)
                return false
            }
        }
        return true
    }

}

