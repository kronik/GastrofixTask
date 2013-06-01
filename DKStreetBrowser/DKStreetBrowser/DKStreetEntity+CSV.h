//
//  DKStreetEntity+CSV.h
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKStreetEntity.h"

#define kDKStreetEntityNameKey @"name"
#define kDKStreetEntityOrderIdKey @"orderId"
#define kDKStreetEntityMapIndexKey @"mapIndex"
#define kDKStreetEntityGroupIdKey @"groupId"

#define kDKStreeEntityName @"DKStreetEntity"

@interface DKStreetEntity (CSV)

+ (DKStreetEntity *)streetWithRawData: (NSDictionary *)rawData
                             andIndex: (int)index
               inManagedObjectContext: (NSManagedObjectContext *)context;
@end
