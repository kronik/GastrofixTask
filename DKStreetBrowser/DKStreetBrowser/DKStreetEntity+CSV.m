//
//  DKStreetEntity+CSV.m
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKStreetEntity+CSV.h"

@implementation DKStreetEntity (CSV)

+ (DKStreetEntity *)streetWithRawData: (NSDictionary *)rawData
                             andIndex: (int)index
               inManagedObjectContext: (NSManagedObjectContext *)context {
 
    DKStreetEntity *street = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: kDKStreeEntityName];
    request.predicate = [NSPredicate predicateWithFormat: @"%K = %@",
                         kDKStreetEntityNameKey,
                         rawData [kDKStreetEntityNameKey]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error: &error];
    
    if ((error != nil) || (matches == nil) || (matches.count > 1)) {
        // handle error
        
        if (matches.count > 0) {
            street = matches [0];
        }

    } else if (matches.count == 0) {
        
        street = [NSEntityDescription insertNewObjectForEntityForName:kDKStreeEntityName inManagedObjectContext:context];
        street.orderId = [NSNumber numberWithInt: index];
        street.name = [rawData objectForKey:kDKStreetEntityNameKey];
        street.mapIndex = [rawData objectForKey:kDKStreetEntityMapIndexKey];
        street.groupId = [rawData objectForKey:kDKStreetEntityGroupIdKey];

    } else {
        street = matches.lastObject;
    }
    
    return street;
}

@end
