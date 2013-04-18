//
//  Department.h
//  MYZSQLExplorer
//
//  Created by Moshe on 17/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department, Employee;

@interface Department : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *employees;
@property (nonatomic, retain) Department *motherDept;
@property (nonatomic, retain) NSSet *childDepts;
@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addEmployeesObject:(Employee *)value;
- (void)removeEmployeesObject:(Employee *)value;
- (void)addEmployees:(NSSet *)values;
- (void)removeEmployees:(NSSet *)values;

- (void)addChildDeptsObject:(Department *)value;
- (void)removeChildDeptsObject:(Department *)value;
- (void)addChildDepts:(NSSet *)values;
- (void)removeChildDepts:(NSSet *)values;

@end
