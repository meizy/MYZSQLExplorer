//
//  NSMutableArray+StackAdditions.m
//  MMManagedObjectMerge
//
//  Created by Moshe on 13/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import "NSMutableArray+StackAdditions.h"

@implementation NSMutableArray (StackAdditions)

- (id)pop
{
    id lastObject = [self lastObject];

    if (lastObject)
        [self removeLastObject];

    return lastObject;
}

- (void)push:(id)obj
{
    [self addObject: obj];
}

@end
