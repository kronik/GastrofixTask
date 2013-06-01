//
//  DKStreetEntity.h
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DKStreetEntity : NSManagedObject

@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * mapIndex;

@end
