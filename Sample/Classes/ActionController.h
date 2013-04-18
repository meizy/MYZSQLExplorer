//
//  ViewController.h
//  RKTRy
//
//  Created by Moshe on 8/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import "MYZManagedStoreController.h"

@interface ActionController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate,  MMManagedStoreDelegate>

@property (nonatomic, retain) NSURL * storeURL;

- (void) handleOpenURL:(NSURL *) url;

- (IBAction)exploreBundleAction:(id)sender;
- (IBAction)exploreDocumentsAction:(id)sender;
- (IBAction)exploreFolderAction:(id)sender;

- (IBAction)usageTipsAction:(id)sender;

@end
