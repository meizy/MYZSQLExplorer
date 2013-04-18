//
//  NSString+MMExtension.m
//  MYZSQLExplorer
//
//  Created by Moshe on 18/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import "NSString+MMExtension.h"

@implementation NSString (MMExtension)

+ (NSString *) concatLines:(NSString *)firstArg, ...
{
    static NSString * newLine = @"\n";
    
    NSMutableString *newString = [NSMutableString string];
    va_list args;
    va_start(args, firstArg);
    for (NSString *arg = firstArg; arg != nil; arg = va_arg(args, NSString*))
    {
        [newString appendString:arg];
        [newString appendString:newLine];
    }
    va_end(args);
    
    return newString;
}

@end
