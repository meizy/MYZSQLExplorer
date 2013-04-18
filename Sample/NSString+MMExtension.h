//
//  NSString+MMExtension.h
//  MYZSQLExplorer
//
//  Created by Moshe on 18/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MMExtension)

+ (NSString *) concatLines:(NSString *)firstArg, ...
    NS_REQUIRES_NIL_TERMINATION;

@end
