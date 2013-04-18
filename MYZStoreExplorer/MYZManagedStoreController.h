//
//  MMManagedStoreController.h
//  SQL Explorer
//
//  Created by Moshe on 9/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

@protocol MMManagedStoreDelegate <NSObject>

@optional
- (NSString *) sortKeyForEntity:(NSString *) entityName;
- (NSNumber *) configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object;

@end

@interface MYZManagedStoreController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property(nonatomic, assign) id <MMManagedStoreDelegate> delegate;
@property(nonatomic, retain) NSFileManager * fileManager;

// if specified, this will be the default sort key for all entities
@property(nonatomic, retain) NSString * defaultSortKey;

- (id)initWithStore:(NSURL *)url;
- (id)initWithDirectory:(NSURL *)url;
- (id)initWithContext:(NSManagedObjectContext *)context;
- (id)initWithEntity:(NSString *)entity sortBy:(NSString *)sortKey context:(NSManagedObjectContext *)context;
- (id)initWithEntity:(NSString *)entity sortBy:(NSString *)sortKey relatedTo:(NSManagedObject *)relatedObject viaKey:(NSString *)relatedKey context:(NSManagedObjectContext *)context;

@end
