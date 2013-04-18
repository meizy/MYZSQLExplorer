//
//  ViewController.m
//  RKTRy
//
//  Created by Moshe on 8/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import "ActionController.h"

#import "Employee.h"

#import "NSString+MMExtension.h"

@implementation ActionController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"SQL Explorer";
}

#pragma mark - Explore Model

// called from appDelegate
- (void)handleOpenURL:(NSURL *)url
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    MYZManagedStoreController * vc = [[MYZManagedStoreController alloc] initWithStore:url];
    vc.delegate = self;
    
    if (vc)
        [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)exploreFolderAction:(id)sender
{
    // ask the user to provide a folder name (under Documents)
    UIAlertView * getFolder = [[UIAlertView alloc] initWithTitle:@"Specify Folder Name"
                                                         message:@"Specify the name of a folder (under Documents) for sql Stores"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
    getFolder.alertViewStyle = UIAlertViewStylePlainTextInput;

    [getFolder show];
}

// back with folder name (?)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if Cancel - do nothing
    if (buttonIndex == alertView.cancelButtonIndex)
        return;

    NSString * inputFolder = [alertView textFieldAtIndex:0].text;
    NSURL * folderURL = [[self appDocumentsURL] URLByAppendingPathComponent:inputFolder];
    
    MYZManagedStoreController * vc = [[MYZManagedStoreController alloc] initWithDirectory:folderURL];
    vc.delegate = self;
    
    if (vc)
        [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)exploreDocumentsAction:(id)sender
{
    MYZManagedStoreController * vc = [[MYZManagedStoreController alloc] initWithDirectory:[self appDocumentsURL]];
    vc.delegate = self;
    
    if (vc)
        [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)exploreBundleAction:(id)sender
{
    NSURL * bundleURL = [[NSBundle mainBundle] bundleURL];

    MYZManagedStoreController * vc = [[MYZManagedStoreController alloc] initWithDirectory:bundleURL];
    vc.delegate = self;
    
    if (vc)
        [self.navigationController pushViewController:vc animated:YES];
}

- (NSURL *)appDocumentsURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (IBAction) usageTipsAction:(id)sender
{
    NSString * usageText = [NSString concatLines:
                            @"Tips:",
                            @"- Tap a cell to drill down to the next level, or follow its relations.",
                            @"- Tapping a cell has a different effect than tapping the Accessory.",
                            @"- A Long Press on a cell displays the Details field in a pop-up window.",
                            @"- If the Sample is installed on an iDevice, you can \"Open In...\" sqlite files. Before that, you should \"Open In...\" the model file (.mom). Just email both files to yourself",
                            @"- ...Or you can put both files in the app Documents directory using iTunes File Sharing, or using the Finder - when working with the Simulator",
                            @"- The search order for the model (.mom) file: same dir, same-name.mom as the sqlite file; same dir, any .mom file; Documents dir; inside the bundle",
                            @"- The sqlfile will not be changed, it is opened in readOnly mode",
                            @"- Enjoy...",
                            nil];

    UIAlertView * showTips = [[UIAlertView alloc] initWithTitle:@"Usage Tips"
                                                         message:usageText
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    
    [showTips show];
}

#pragma mark - MMManagedStoreDelegate

// format the Employee object 
- (NSNumber *) configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object
{
    NSNumber * done = @NO;
    
    static NSDateFormatter * dateFormatter;
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    // text label - name
    if ([object isKindOfClass:[Employee class]])
    {
        Employee * emp = (Employee *)object;
        cell.textLabel.text = emp.name;
        cell.detailTextLabel.text = [dateFormatter stringFromDate:emp.dob];
        
        done = @YES;
    }
    return done;
}


@end
