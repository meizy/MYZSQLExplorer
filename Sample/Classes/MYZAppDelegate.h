//
//  MMAppDelegate.h
//  MYZSQLEXplorer
//
//  Created by Moshe on 16/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import "MYZManagedStoreController.h"

@interface MYZAppDelegate : UIResponder <UIApplicationDelegate, MMManagedStoreDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
