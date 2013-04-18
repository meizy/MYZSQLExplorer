//
//  NSMutableArray+StackAdditions.h
//  MMManagedObjectMerge
//
//  Created by Moshe on 13/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (StackAdditions)

- (id)pop;
- (void)push:(id)obj;

@end
