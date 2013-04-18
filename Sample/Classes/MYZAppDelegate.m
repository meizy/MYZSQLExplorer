//
//  MMAppDelegate.m
//  MYZSQLEXplorer
//
//  Created by Moshe on 16/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import "MYZAppDelegate.h"

#import "ActionController.h"

#import "Department.h"
#import "Employee.h"

@implementation MYZAppDelegate
{
    ActionController * _actionController;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _actionController = [[ActionController alloc] init];
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:_actionController];
    [[self window] setRootViewController:nav];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url == nil || ![url isFileURL])
        return NO;

    NSString * pathExtension = url.pathExtension;
    
    // if this is a model file - just save it
    if ([pathExtension isEqualToString:@"mom"])
    {
        NSString * message = @"Model is saved. Now \"Open In...\" the sqlite file and you will be exploring its contents";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Model Saved" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    // if this is an sqlite store - keep the URL for later processing
    else if ([pathExtension isEqualToString:@"sqlite"])
        [_actionController handleOpenURL:url];
    else
        return NO;
    
    return YES;
}

#pragma mark - Init Store

- (BOOL) initDB
{
    NSManagedObjectContext * moc = self.managedObjectContext;

    Department * dept, * mother;
    Employee * emp;
    
    dept = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:moc];
    dept.name = @"Dept1";
    
    emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
    emp.name = @"John";
    emp.salary = @(95000);
    emp.dob = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24*356*24)];
    
    emp.department = dept;
    
    emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
    emp.name = @"David";
    emp.salary = @(90000);
    emp.dob = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24*356*34)];
    
    emp.department = dept;
    
    emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
    emp.name = @"Sara";
    emp.salary = @(120000);
    emp.dob = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24*356*44)];
    emp.isManager = @YES;
    
    emp.department = dept;
    
    mother = dept;
    dept = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:moc];
    dept.name = @"Dept2";
    dept.motherDept = mother;
    
    emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
    emp.name = @"Meizy";
    emp.salary = @(85000);
    emp.dob = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24*356*55)];
    
    emp.department = dept;
    
    emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
    emp.name = @"Bela";
    emp.salary = @(75000);
    emp.dob = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24*356*19)];
    
    emp.department = dept;
    
    return [moc save:nil];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SQLEXplorerSample.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
