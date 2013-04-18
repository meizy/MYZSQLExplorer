//
//  MMManagedDetailsController.m
//  SQL Explorer
//
//  Created by Moshe on 13/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import "MYZManagedObjectController.h"

@implementation MYZManagedObjectController
{
    NSManagedObject * _object;
    
    NSArray * _attributeKeys;
    NSArray * _attributeDescriptions;
}

- (id)initWithObject:(NSManagedObject *)object
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
    _object = object;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _attributeKeys = [[_object.entity attributesByName] allKeys];
    _attributeDescriptions = [[_object.entity attributesByName] allValues];
    
    // add a gesture recognizer to catch long presses on cells and show their Details
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:lpgr];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _attributeKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = _attributeKeys[indexPath.row];
    NSAttributeType type = [_attributeDescriptions[indexPath.row] attributeType];

    cell.textLabel.text = key;

    // format the value
    id value = [_object valueForKey:key];

    NSString * valueString;
    
    switch (type) {
        case NSStringAttributeType:
            valueString = value;
            break;

        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            valueString = ((NSNumber *)value).stringValue;
            break;

        case NSBooleanAttributeType:
            valueString = ((NSNumber *)value).intValue == 0 ? @"NO" : @"YES";
            break;

        case NSDateAttributeType:
            valueString = [(NSDate *)value description];
            break;

        default:
            valueString = @"...";
            break;
    }
    
    cell.detailTextLabel.text = valueString;
}

// on long press - show the detailText value in a pop-up alert view
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    // get the indexpath of the press
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath != nil)
        [self showDetails:indexPath];
}

- (void) showDetails:(NSIndexPath *) indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString * details = cell.detailTextLabel.text;
    if (details.length == 0) return;
    
    UIAlertView * showDetails = [[UIAlertView alloc] initWithTitle:@"Details" message:details delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [showDetails show];
}


@end
