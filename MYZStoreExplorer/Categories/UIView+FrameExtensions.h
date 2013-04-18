//
//  UIView+FrameExtensions.h
//  MYZSQLEXplorer
//
//  Created by Moshe on 16/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
// 

#import <UIKit/UIKit.h>

@interface UIView (FrameExtensions)

- (CGFloat) x;
- (CGFloat) y;
- (CGFloat) width;
- (CGFloat) height;

- (void) setHeight:(CGFloat)height;
- (void) setWidth:(CGFloat)width;
- (void) setX:(CGFloat)x;
- (void) setY:(CGFloat)y;

- (void) setHeight:(CGFloat)height animated:(BOOL) animated;

@end
