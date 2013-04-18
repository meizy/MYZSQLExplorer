//
//  MMManagedStoreController.h
//  SQL Explorer
//
//  Created by Moshe on 9/1/13.
//  Copyright (c) 2013 Moshe. All rights reserved.
//

#import "MYZManagedStoreController.h"

#import "MYZManagedStoreState.h"
#import "MYZManagedObjectController.h"

#import "NSMutableArray+StackAdditions.h"
#import "UIView+FrameExtensions.h"

typedef enum {
    kModeStores,
    kModeURL,
    kModeMetaData,
    kModeEntities,
    kModeInstances,
    kModeRelated
} ExplorerModes;

@implementation MYZManagedStoreController
{
    ExplorerModes                   _mode;
    
    NSManagedObjectContext          * _moc;
    NSMutableArray                  * _mocArray;
    NSURL                           * _storesDirectory;
    NSURL                           * _storeURL;

    NSFetchedResultsController      * _fetchedResultsController;
    UIButton                        * _rootButton;
    
    // state variables
    NSString * _entityName;
    NSString * _sortKey;
    NSString * _relatedKey;
    NSManagedObject * _relatedObject;
    NSString * _relatedName;

    NSMutableArray * _states; // a stack of states
    
    NSArray * _keys;
    NSArray * _objects;
    
    id _selectedObject;
    NSString * _selectedRelationName;
    NSString * _selectedDestinationEntity;

    int _selectedRow;
    
    NSDictionary *_relationships;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    // will explore Documents dir
    BOOL ok = [self setup];
    if (!ok) return nil;
    
    return self;
}

- (id)initWithStore:(NSURL *)url
{
    self = [super init];
    if (!self) return nil;
    
    _storeURL = url;

    BOOL ok = [self setup];
    if (!ok) return nil;
    
    
    return self;
}

- (id)initWithDirectory:(NSURL *)url
{
    self = [super init];
    if (!self) return nil;
    
    _storesDirectory = url;
    
    BOOL ok = [self setup];
    if (!ok) return nil;
    
    return self;
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (!self) return nil;
    
    _moc = context;

    [self setup];

    return self;
}

- (id)initWithEntity:(NSString *)entity sortBy:(NSString *) sortKey context:(NSManagedObjectContext *)context
{
    self = [self initWithContext:context];
    if (!self) return nil;
    
    _entityName = entity;
    _sortKey = sortKey;
    
    [self setup];

    return self;
}

- (id)initWithEntity:(NSString *)entity sortBy:(NSString *)sortKey relatedTo:(NSManagedObject *)relatedObject viaKey:(NSString *)relatedKey context:(NSManagedObjectContext *)context
{
    self = [self initWithContext:context];
    if (!self) return nil;
    
    _entityName = entity;
    _sortKey = sortKey;
    _relatedKey = relatedKey;
    _relatedObject = relatedObject;
    
    [self setup];

    return self;
}

#pragma mark - UIView Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _states = [NSMutableArray array];
    
    [self addTableHeader];
    
    // add a gesture recognizer to catch long presses on cells and show their Details
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = nil;
    [self.tableView addGestureRecognizer:lpgr];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

#pragma mark - Setup

- (BOOL) setup
{
    BOOL result = YES;;
    
    if (_relatedKey)
    {
        _mode = kModeRelated;
        [self setupRelated];
    }
    else if (_entityName)
    {
        _mode = kModeInstances;
        [self setupFRC];
    }
    else if (_moc)
    {
        _mode = kModeEntities;
        [self setupEntities];
    }
    else if (_storeURL)
    {
        _mode = kModeURL;
        result = [self setupURL];
    }
    else
    {
        _mode = kModeStores;
        result = [self setupStores];
    }
    
    if (result == YES)
        [self.tableView reloadData];
    
    return result;
}

- (BOOL) setupURL
{
    _moc = [self contextForStore:_storeURL];
    if (!_moc)
        return NO;
    
//    _mode = kModeEntities;
//    [self setupEntities];
    
    return [self setup];
}

- (BOOL) setupStores
{
    self.title = [NSString stringWithFormat:@"Stores"];
    
    // if directory not provided - default to Documents dir
    if (!_storesDirectory)
        _storesDirectory = [self appDocumentsURL];
    
    // get all files ending with *.sqlite in dir
    NSArray * storeURLs = [self sqlStoresAtURL:_storesDirectory];
    
    // no stores found - alert and return
    if (storeURLs.count == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                         message:@"No sqlite stores found in directory"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    // a single store - convert to Entities mode
    else if (storeURLs.count == 1)
    {
        _storeURL = storeURLs[0];
        return [self setupURL];
        
//        NSURL * storeURL = storeURLs[0];
//        _moc = [self contextForStore:storeURL];
//        _mode = kModeEntities;
//        [self setupEntities];
    }
    
    // multiple stores
    else
    {
        _objects = storeURLs;
        _mocArray = [[NSMutableArray alloc] initWithCapacity:storeURLs.count];
        for(int i = 0; i < storeURLs.count; i++)
            [_mocArray addObject: [NSNull null]];
    }
    
    return YES;
}

// we come here after an error - back to caller
//- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void) setupMetaData
{
    self.title = [NSString stringWithFormat:@"MetaData"];
    
    NSPersistentStoreCoordinator * psc = _moc.persistentStoreCoordinator;
    
    if (psc.persistentStores.count == 0)
        return;
    
    NSPersistentStore * store = psc.persistentStores[0];
    
    _keys = [[store metadata] allKeys];
    _objects = [[store metadata] allValues];
}


- (void) setupEntities
{
    self.title = [NSString stringWithFormat:@"Entities"];

    NSManagedObjectModel * model = _moc.persistentStoreCoordinator.managedObjectModel;
    
    NSArray * entities = [[model entitiesByName] allValues];

    NSMutableArray * concreteEntities = [NSMutableArray array];
    
    for (NSEntityDescription * entity in entities)
    {
        if (!entity.isAbstract)
            [concreteEntities addObject:entity.name];
    }
    
    _objects = concreteEntities;
}

- (void) setupRelated
{
    _fetchedResultsController = nil;
    
    // setup the title
    self.title = [NSString stringWithFormat:@"%@ - %@", _relatedName, _relatedKey];

    // get the destination object/s (toOne or toMany)
    NSDictionary * relationships = [_relatedObject.entity relationshipsByName];
    NSRelationshipDescription * relation = relationships[_relatedKey];
    if (relation.isToMany)
        _objects = [[_relatedObject valueForKey:_relatedKey] allObjects];
    else
    {
        id object = [_relatedObject valueForKey:_relatedKey];
        if (object)
            _objects = [NSArray arrayWithObject:[_relatedObject valueForKey:_relatedKey]];
        else
            _objects = nil;
    }
    
    // get sort key
    if (!_sortKey && relation.isToMany)
        _sortKey = [self getSortKey:NO];

    if (_sortKey)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:_sortKey ascending:YES];
        _objects = [_objects sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
}

- (void) setupFRC
{
    self.title = [NSString stringWithFormat:@"%@ - All", _entityName];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:_entityName];
//    [fetchRequest setFetchBatchSize:100];
    
    if (!_sortKey)
        _sortKey = [self getSortKey:YES];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:_sortKey ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];

    NSError *error = nil;
    
    // Setup fetched results
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetchRequest
                                     managedObjectContext:_moc
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    [_fetchedResultsController setDelegate:self];
    BOOL fetchSuccessful = [_fetchedResultsController performFetch:&error];

    if (!fetchSuccessful)
        NSLog(@"fetch failed for entity: %@", _entityName);
}

- (NSString *) getSortKey:(BOOL)mustHave
{
    // get sort key from delegate
    if ([_delegate respondsToSelector:@selector(sortKeyForEntity:)])
        return [_delegate performSelector:@selector(sortKeyForEntity:) withObject:_entityName];

    // get all attribute names
    NSEntityDescription * description = [NSEntityDescription entityForName:_entityName inManagedObjectContext:_moc];
    NSArray * attributeNames = [[description attributesByName] allKeys];

    // if defaultSort exists
    if (_defaultSortKey && [attributeNames containsObject:_defaultSortKey])
        return _defaultSortKey;

    // if "name" attribute exists - return it
    if ([attributeNames containsObject:@"name"])
        return @"name";

    // if "order" attribute exists - return it
    if (_mode == kModeRelated && [attributeNames containsObject:@"order"])
        return @"order";
    
    // nothing so far? return any key
    if (mustHave)
        return attributeNames.lastObject;
    
    return nil;
}

- (void) addTableHeader
{
    UIView * tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self.view width], 44)];
    tableHeader.backgroundColor = [UIColor lightGrayColor];
    
    // add Back button
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(5, 7, 80, 30);
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [tableHeader addSubview:backButton];
    
    // add Root button
    _rootButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _rootButton.frame = CGRectMake(self.view.frame.size.width - 87, 7, 80, 30);
    [_rootButton setTitle:@"Root" forState:UIControlStateNormal];
    [_rootButton addTarget:self action:@selector(rootAction)
         forControlEvents:UIControlEventTouchUpInside];
    _rootButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [tableHeader addSubview:_rootButton];
    
    self.tableView.tableHeaderView = tableHeader;
}

- (NSFileManager *) fileManager
{
    if (!_fileManager)
        _fileManager = [NSFileManager defaultManager];
    
    return _fileManager;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *) contextForStore:(NSURL *) storeURL
{
    NSManagedObjectModel * model;
    
    // create a model
    NSURL *momURL = [self findModel:storeURL];
    if (momURL)
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    else
        model = [NSManagedObjectModel mergedModelFromBundles:nil];

    if (!model)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                         message:@"Failed to find or init a matching model (.mom file)"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];

        NSLog(@"error creating a model");
        return nil;
    }

    // create a coordinator
    NSError *error = nil;
    NSPersistentStoreCoordinator * coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // request automatic migration
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             [NSNumber numberWithBool:1], NSReadOnlyPersistentStoreOption,
                             nil];

    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Error creating a coordinator with URL: %@", storeURL);
        abort();
    }

    // create a context
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    return context;
}

- (NSURL *) findModel:(NSURL *) storeURL
{
    // search order:
    // 1. same dir and same name as store - with ".mom" extension
    // 2. same dir, any ".mom" file
    // 3. any ".mom" in Documents
    
    NSURL *modelURL;
    
    // look in store dir for a mom file with same name as store name
    NSString * fileName = [storeURL.path lastPathComponent];
    NSString * fileWithoutExtension = [fileName stringByDeletingPathExtension];
    NSString * modelName = [fileWithoutExtension stringByAppendingPathExtension:@"mom"];
    
    NSString *storeFolder = [storeURL.path stringByDeletingLastPathComponent];
    NSString *modelPath = [storeFolder stringByAppendingPathComponent:modelName];
    
    // if exists - return
    if ([self.fileManager fileExistsAtPath:modelPath])
    {
        modelURL = [NSURL fileURLWithPath:modelPath];
        return modelURL;
    }
    
    // look in store dir for any mom file
    NSURL * folderURL = [NSURL fileURLWithPath:storeFolder];
    NSArray * modelURLs = [self contentsOfDirectoryAtURL:folderURL withExtension:@"mom"];
    
    // if one or more exist - return with first one
    if (modelURLs.count > 0)
        return modelURLs[0];
    
    // look in Documents dir for any mom file
    if (![folderURL isEqual:[self appDocumentsURL]])
    {
        NSArray * modelURLs = [self contentsOfDirectoryAtURL:[self appDocumentsURL] withExtension:@"mom"];
        if (modelURLs.count > 0)
            return modelURLs[0];
    }
    
    return nil; // none found
}

#pragma mark - Back and Root Actions

- (void) backAction
{
    if (_states.count == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self popState];
    [self setup];
}

- (void) rootAction
{
    if (!_states || _states.count == 0)
        return;

    MYZManagedStoreState * state;

    state = _states[0];
    _states = [NSMutableArray array];
    
    [self restoreState:state];
    [self setup];
}

#pragma mark - State stack handling

- (void) popState
{
    MYZManagedStoreState * state = [_states pop];
    
    [self restoreState:state];
}

- (void) restoreState:(MYZManagedStoreState *) state
{
    _moc = state.context;
    _entityName = state.entity;
    _sortKey = state.sortKey;
    _relatedKey = state.relatedKey;
    _relatedObject = state.relatedObject;
    _relatedName = state.relatedName;
}

- (void) pushState
{
    // push myself on the stack
    MYZManagedStoreState * state = [MYZManagedStoreState state];
    
    [self saveState:state];
    
    [_states push:state];
}

- (void) saveState:(MYZManagedStoreState *) state
{
    state.context = _moc;
    state.entity = _entityName;
    state.sortKey = _sortKey;
    state.relatedKey = _relatedKey;
    state.relatedObject = _relatedObject;
    state.relatedName = _relatedName;
}

- (void) drillDown
{
    [self pushState];

    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
    _relatedName = cell.textLabel.text;

    _entityName = _selectedDestinationEntity;
    _relatedKey = _selectedRelationName;
    _relatedObject = _selectedObject;
    _sortKey = nil;
    
    [self setup];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (_mode == kModeInstances)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else
        return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (nil == cell)
        cell = [self getCell];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *) getCell
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellID"];
    
    /*
     UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];

     UILabel * label;
    CGFloat width = [cell.contentView width];
    
    // text
    label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, width - 20, 32.0)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.tag = 1;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [cell.contentView addSubview:label];
    
    // detailText
    label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, width - 20, 32.0)];
    label.tag = 2;
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = UITextAlignmentRight;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.lineBreakMode = UILineBreakModeMiddleTruncation;
    [cell.contentView addSubview:label];
*/
    return cell;
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UILabel * textLabel = cell.textLabel;
    UILabel * detailTextLabel = cell.detailTextLabel;
    textLabel.textColor = [UIColor blackColor];

    id object = [self selectedObject:indexPath];

    // format store rows
    if (_mode == kModeStores)
    {
        NSURL * storeURL = object;
        textLabel.text = [storeURL lastPathComponent];
        detailTextLabel.text = nil;
    }
    
    // format metadata rows
    else if (_mode == kModeMetaData)
    {
        NSString * key = _keys[indexPath.row];
        textLabel.text = key;
        
        if ([object respondsToSelector:@selector(description)])
            detailTextLabel.text = [object description];
        else
            detailTextLabel.text = nil;
    }
    
    // format entity rows
    else if (_mode == kModeEntities)
    {
        NSString * entityName = object;
        textLabel.text = entityName;
        
        int numInstances = [self numberOfInstances:entityName];
        detailTextLabel.text = [NSString stringWithFormat:@"%d instances", numInstances];
        
        if (numInstances == 0)
            textLabel.textColor = [UIColor grayColor];
    }
    
    // format managed object rows
    else
    {
        // if delegate responds - let it format
        NSNumber * done = @NO;
        if ([_delegate respondsToSelector:@selector(configureCell:withObject:)])
            done = [_delegate performSelector:@selector(configureCell:withObject:) withObject:cell withObject:object];
        
        if ([done isEqualToNumber:@NO])
        {
            if ([object respondsToSelector:@selector(name)])
                textLabel.text = (NSString *) [object valueForKey:@"name"];
            else if ([object respondsToSelector:@selector(MMDescription)])
                textLabel.text = (NSString *) [object valueForKey:@"MMDescription"];
            else
                textLabel.text = @"???";
            
            detailTextLabel.text = ((NSManagedObject *)object).objectID.URIRepresentation.absoluteString;
        }
    }

    // accessory icon
    if (_mode == kModeStores || _mode == kModeInstances || _mode == kModeRelated)
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    // adjust label frames
//    CGFloat cellWidth = [cell width];
//    CGFloat textSize = [textLabel.text sizeWithFont:textLabel.font].width;
//
//    if (cell.accessoryType == UITableViewCellAccessoryNone)
//    {
//        textLabel.frame = CGRectMake(10.0, 5.0, cellWidth - 20, 32.0);
//        detailTextLabel.frame = CGRectMake(textSize + 10, 5.0, cellWidth - textSize - 20, 32.0);
//    }
//    else
//    {
//        textLabel.frame = CGRectMake(10.0, 5.0, cellWidth - 50, 32.0);
//        detailTextLabel.frame = CGRectMake(textSize + 10, 5.0, cellWidth - textSize - 50, 32.0);
//    }
}

#pragma mark NSFetchedResultsControllerDelegate methods

// in case we got the context (initWithContext/Entity...) and the caller made changes - make sure we update our data
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == kModeMetaData)
        return nil;
    else
        return indexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _selectedObject = [self selectedObject:indexPath];
    _selectedRow = indexPath.row;

    // for stores - accessory tap shows metadata
    if (_mode == kModeStores)
    {
        [self pushState];
        _mode = kModeMetaData;
        _moc = [self contextForRow:_selectedRow];
        [self setupMetaData];
        [self.tableView reloadData];
    }
    
    // for managed objects - accessory tap shows object attributes
    else
    {
        MYZManagedObjectController * detailsController = [[MYZManagedObjectController alloc]
                                                         initWithObject:_selectedObject];
        [self.navigationController pushViewController:detailsController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedObject = [self selectedObject:indexPath];
    _selectedRow = indexPath.row;
    
    // store selected - show entities
    if (_mode == kModeStores)
    {
        [self pushState];
        _moc = [self contextForRow:_selectedRow];
        [self setup];
    }
    
    // entity selected - show objects
    else if (_mode == kModeEntities)
    {
        [self pushState];
        _entityName = (NSString *)_selectedObject;
        [self setup];
    }
    
    // object selected - show relations
    else
    {
        BOOL gotRelation = [self selectedRelation];
        if (!gotRelation)
            return;
        
        [self drillDown];
    }
}

// lazy init of moc
- (NSManagedObjectContext *) contextForRow:(int) row
{
    if ([_mocArray[_selectedRow] isEqual: [NSNull null]])
    {
        NSManagedObjectContext * context = [self contextForStore:_selectedObject];
        [_mocArray replaceObjectAtIndex:_selectedRow withObject:context];
    }
    return _mocArray[_selectedRow];
}

- (id) selectedObject:(NSIndexPath *)indexPath
{
    if (_mode == kModeInstances)
        return [_fetchedResultsController objectAtIndexPath:indexPath];
    else
        return _objects[indexPath.row];
}

- (BOOL) selectedRelation
{
    // get all relations for this entity
    NSEntityDescription * entity = ((NSManagedObject *)_selectedObject).entity;
    _relationships = [entity relationshipsByName];

    if (_relationships.count == 0)
        return NO;

    // if one relation only - drill down 
    if (_relationships.count == 1)
    {
        NSRelationshipDescription * relationDescription = [[_relationships allValues] objectAtIndex:0];
        _selectedRelationName = relationDescription.name;
        _selectedDestinationEntity = relationDescription.destinationEntity.name;
        return YES;
    }
    
    // if multiple relationships - ask the user which one to follow
    NSArray * relations = [_relationships allValues];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Relationship"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];

    // loop over relationships, add a button with instance count for each, e.g. "Patients (28)"
    for (NSRelationshipDescription * relation in relations)
    {
        NSString * title = relation.name;
        int relationCount;
        if (relation.isToMany)
             relationCount = [[_selectedObject valueForKey:relation.name] count];
        else
            relationCount = [_selectedObject valueForKey:relation.name] ? 1 : 0;
        title = [title stringByAppendingFormat:@" (%d)", relationCount];
        
        [actionSheet addButtonWithTitle:title];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = relations.count;

    [actionSheet showInView:self.view];
    
    return NO;
}

// back from selecting a relation to follow
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;

    _selectedRelationName = [[_relationships allKeys] objectAtIndex:buttonIndex];
    NSRelationshipDescription * relationDescription = [_relationships objectForKey:_selectedRelationName];
    _selectedDestinationEntity = relationDescription.destinationEntity.name;

    [self drillDown];
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

#pragma mark - utils

- (int) numberOfInstances:(NSString *) entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:_moc]];
    
    NSError *err;
    NSUInteger count = [_moc countForFetchRequest:request error:&err];
    if(count == NSNotFound)
        count = 0;
    
    return count;
}

- (NSArray *) sqlStoresAtURL:(NSURL *)url
{
    return [self contentsOfDirectoryAtURL:url withExtension:@"sqlite"];
}

- (NSArray *) contentsOfDirectoryAtURL:(NSURL *)url withExtension:(NSString *)extension
{
    
    NSArray *dirContents = [self.fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:nil];
    NSPredicate *byExtension = [NSPredicate predicateWithFormat:@"pathExtension == %@", extension];
    NSArray *storesURLs = [dirContents filteredArrayUsingPredicate:byExtension];
    
    return storesURLs;
}

- (NSURL *)appDocumentsURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
