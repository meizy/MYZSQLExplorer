//
//  Employee.h
//  MYZSQLEXplorer
//
//  Created by Moshe on 17/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department;

@interface Employee : NSManagedObject

@property (nonatomic, retain) NSDate * dob;
@property (nonatomic, retain) NSNumber * isManager;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * salary;
@property (nonatomic, retain) Department *department;

@end
