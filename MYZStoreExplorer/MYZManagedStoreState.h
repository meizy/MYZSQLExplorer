//
//  MMManagedTableState.h
//  SQL Explorer
//
//  Created by Moshe on 13/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYZManagedStoreState : NSObject

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSString * entity;
@property (nonatomic, strong) NSString * sortKey;
@property (nonatomic, strong) NSString * relatedKey;
@property (nonatomic, strong) NSManagedObject * relatedObject;
@property (nonatomic, strong) NSString * relatedName;

//@property (nonatomic, strong) NSString * title;

+ (MYZManagedStoreState *) state;

@end
