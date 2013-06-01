//
//  DKAppDelegate.m
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKMainViewController.h"

@implementation DKAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions {
    
    // Set Navigation Bar style
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"menu-bar"] forBarMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor: [UIColor clearColor]];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment: 1.0f forBarMetrics: UIBarMetricsDefault];
    
    UIColor *titleColor = [UIColor colorWithRed: 150.0f/255.0f green: 149.0f/255.0f blue: 149.0f/255.0f alpha: 1.0f];
    UIColor* shadowColor = [UIColor colorWithWhite: 1.0 alpha: 1.0];
        
    [[UINavigationBar appearance] setTitleTextAttributes: @{UITextAttributeTextColor: titleColor,
                                                            UITextAttributeFont: [UIFont boldSystemFontOfSize: 23.0f],
                                                            UITextAttributeTextShadowColor: shadowColor,
                                                            UITextAttributeTextShadowOffset: [NSValue valueWithCGSize: CGSizeMake(0.0, 1.0)]}];

    self.window = [[UIWindow alloc] initWithFrame: ScreenRect];

    DKMainViewController *viewController = [[DKMainViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: viewController];

    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save: &error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [Bundle URLForResource: @"DKStreetBrowser" withExtension: @"momd"];

    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];

    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"DKStreetBrowser.sqlite"];
    NSError *error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                   configuration: nil
                                                             URL: storeURL
                                                         options: nil
                                                           error: &error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

@end
