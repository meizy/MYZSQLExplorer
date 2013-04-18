//
//  UIView+FrameExtensions.m
//  MYZSQLEXplorer
//
//  Created by Moshe on 16/4/13.
//  Copyright (c) 2013 Meizy. All rights reserved.
//

#import "UIView+FrameExtensions.h"

@implementation UIView (FrameExtensions)

- (CGFloat) x
{
    return self.frame.origin.x;
}

- (CGFloat) y
{
    return self.frame.origin.y;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setHeight:(CGFloat)height
{
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (void) setWidth:(CGFloat)width
{
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (void) setX:(CGFloat)x
{
    CGRect f = self.frame;
    f.origin.x = x;
    self.frame = f;
}

- (void) setY:(CGFloat)y
{
    CGRect f = self.frame;
    f.origin.y = y;
    self.frame = f;
}

- (void) setHeight:(CGFloat)height animated:(BOOL) animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
    }
    
    [self setHeight:height];
    
    if (animated) {
        [UIView commitAnimations];
    }
}



@end
