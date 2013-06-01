//
//  DKMainViewController.m
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKMainViewController.h"
#import "DKStreetMapViewController.h"
#import "DKDataParser.h"
#import "DKStreetEntity+CSV.h"
#import "DKStreetCell.h"

#import <CoreData/CoreData.h>
#import <pthread.h>

#define kDKTableViewCellDefaultHeight 50.0f
#define kDKTableViewSearchBarDefaultHeight 44.0f
#define kDKTableViewSearchBarRightOffset 30.0f

#define kDKTableViewMainBackgroundImageFileName @"background.jpg"
#define kDKTableViewSearchBarBackgroundImageFileName @"search_bar_bg"
#define kDKTableViewSearchFieldBackgroundImageFileName @"search_field"

@interface DKMainViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
    pthread_mutex_t mutex;
    pthread_mutexattr_t attributes;
}

@property (nonatomic) BOOL beganUpdates;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property (nonatomic, strong) UIManagedDocument *streetsDatabase;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *streetFilter;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation DKMainViewController

@synthesize streetsDatabase = _streetsDatabase;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize beganUpdates = _beganUpdates;
@synthesize streetFilter = _streetFilter;
@synthesize searchBar = _searchBar;

- (void)customInit {
    pthread_mutexattr_init (&attributes);
    pthread_mutexattr_settype (&attributes, PTHREAD_MUTEX_DEFAULT);
    pthread_mutex_init (&mutex, &attributes);
}

- (id) init {
    self = [super init];
    
    if (self != nil) {
        [self customInit];
    }
    
    return self;
}

- (id)initWithStyle: (UITableViewStyle)style {
    self = [super initWithStyle: style];
    
    if (self != nil) {
        [self customInit];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Street Browser", nil);
    self.navigationItem.title = self.title;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: kDKTableViewMainBackgroundImageFileName]];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame: self.view.frame];
    bgView.image = [UIImage imageNamed: kDKTableViewMainBackgroundImageFileName];

    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = bgView;

    self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake (0, 0, ScreenWidth - kDKTableViewSearchBarRightOffset,
                                                                     kDKTableViewSearchBarDefaultHeight)];
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage imageNamed: kDKTableViewSearchBarBackgroundImageFileName];
    self.searchBar.placeholder = NSLocalizedString (@"Search for street", nil);
    self.searchBar.tintColor = [UIColor darkGrayColor];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [[UISearchBar appearance] setSearchFieldBackgroundImage: [UIImage imageNamed:kDKTableViewSearchFieldBackgroundImageFileName]
                                                   forState: UIControlStateNormal];

    UIView *searchBarContainer = [[UIView alloc] initWithFrame:CGRectMake (0, 0, ScreenWidth, kDKTableViewSearchBarDefaultHeight)];
    searchBarContainer.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:kDKTableViewSearchBarBackgroundImageFileName]];
    searchBarContainer.contentMode = UIViewContentModeScaleAspectFit;
    
    [searchBarContainer addSubview: self.searchBar];
    
    self.tableView.tableHeaderView = searchBarContainer;    
}

- (void)setStreetFilter: (NSString *)streetFilter {
    if ([_streetFilter isEqualToString: streetFilter] == NO) {
        _streetFilter = streetFilter;
        
        [self setupFetchedResultsController];
    }
}

- (void)scrollViewDidScroll: (UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (void)searchBar: (UISearchBar *)searchBar textDidChange: (NSString *)searchText {
    self.streetFilter = searchText;
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: kDKStreeEntityName];
    
    request.sortDescriptors = [NSArray arrayWithObject: [NSSortDescriptor sortDescriptorWithKey: kDKStreetEntityOrderIdKey
                                                                                      ascending: YES]];
    if (self.streetFilter.length > 0) {
                
        request.predicate = [NSPredicate predicateWithFormat: @"%K like[cd] %@",
                             kDKStreetEntityNameKey,
                             [NSString stringWithFormat: @"*%@*", self.streetFilter]];
    }
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                        managedObjectContext: self.streetsDatabase.managedObjectContext
                                                                          sectionNameKeyPath: kDKStreetEntityGroupIdKey
                                                                                   cacheName: nil];
}

- (void)fetchCSVDataIntoDocument: (UIManagedDocument *)document {
    
    dispatch_queue_t queue = dispatch_queue_create ("CSV Parser Queue", NULL);
    
    dispatch_async (queue, ^{
        
        pthread_mutex_lock (&mutex);

        [[DKDataParser sharedInstance] parseWithCompleteBlock: ^(NSArray *parsedData) {

            NSArray *sortedParsedData = [parsedData sortedArrayUsingComparator: ^NSComparisonResult (NSDictionary *a, NSDictionary *b) {
                return [a[kDKStreetEntityNameKey] compare:b[kDKStreetEntityNameKey]];
            }];
            
            [document.managedObjectContext performBlock: ^{
   
                for (int i = 0; i < sortedParsedData.count; i++) {
                    NSDictionary *parserRowData = sortedParsedData [i];
                    
                    [DKStreetEntity streetWithRawData: parserRowData
                                             andIndex: i
                               inManagedObjectContext: document.managedObjectContext];
                }
                
                [document saveToURL: document.fileURL
                   forSaveOperation: UIDocumentSaveForOverwriting
                  completionHandler: NULL];
            }];
        }];
        
        pthread_mutex_unlock (&mutex);
    });
    
    dispatch_release (queue);
}

- (void)dealloc {
    pthread_mutexattr_destroy (&attributes);
    pthread_mutex_destroy (&mutex);
}

- (void)useDocument {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: [self.streetsDatabase.fileURL path]] == NO) {
        
        // does not exist on disk, so create it
        [self.streetsDatabase saveToURL: self.streetsDatabase.fileURL
                       forSaveOperation: UIDocumentSaveForCreating
                      completionHandler: ^(BOOL success) {
                          
            [self setupFetchedResultsController];
            [self fetchCSVDataIntoDocument: self.streetsDatabase];
        }];
        
    } else if (self.streetsDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.streetsDatabase openWithCompletionHandler: ^(BOOL success) {
            [self setupFetchedResultsController];
        }];
        
    } else if (self.streetsDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self setupFetchedResultsController];
    }
}

- (void)setStreetsDatabase: (UIManagedDocument *)streetsDatabase {
    if (_streetsDatabase != streetsDatabase) {
        _streetsDatabase = streetsDatabase;
        
        [self useDocument];
    }
}

- (void)viewWillAppear: (BOOL)animated {
    
    if (self.streetsDatabase == nil) {
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                             inDomains: NSUserDomainMask] lastObject];
        
        url = [url URLByAppendingPathComponent: @"Default Streets Database"];

        self.streetsDatabase = [[UIManagedDocument alloc] initWithFileURL: url];
    }
}

- (void)performFetch {
    if (self.fetchedResultsController != nil) {
        NSError *error = nil;
        [self.fetchedResultsController performFetch: &error];
    }
    [self.tableView reloadData];
}

- (void)setFetchedResultsController: (NSFetchedResultsController *)newfrc {
    
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        
        if (newfrc) {
            [self performFetch];
        } else {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    return [self.fetchedResultsController.sections [section] numberOfObjects];
}

- (NSString *)tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
	return [self.fetchedResultsController.sections [section] name];
}

- (NSInteger)tableView: (UITableView *)tableView sectionForSectionIndexTitle: (NSString *)title
               atIndex: (NSInteger)index {
	return [self.fetchedResultsController sectionForSectionIndexTitle: title atIndex: index];
}

- (NSArray *)sectionIndexTitlesForTableView: (UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Street Cell Id";
    
    DKStreetCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil) {
        cell = [[DKStreetCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                   reuseIdentifier: CellIdentifier];
    }
    
    DKStreetEntity *street = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = street.name;
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [street.orderId intValue]];
    cell.mapIndexLabel.text = street.mapIndex;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    [self.searchBar resignFirstResponder];

    DKStreetEntity *street = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DKStreetMapViewController *mapViewController = [[DKStreetMapViewController alloc] init];
    
    mapViewController.title = street.name;
    
    [self.navigationController pushViewController: mapViewController animated: YES];
    
    [mapViewController showLocations: street.mapIndex];
}

- (float)tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
    return kDKTableViewCellDefaultHeight;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent: (NSFetchedResultsController *)controller {
    if (self.suspendAutomaticTrackingOfChangesInManagedObjectContext == NO) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller: (NSFetchedResultsController *)controller
  didChangeSection: (id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex: (NSUInteger)sectionIndex
	 forChangeType: (NSFetchedResultsChangeType)type {
    
    if (self.suspendAutomaticTrackingOfChangesInManagedObjectContext == NO) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections: [NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation: UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex]
                              withRowAnimation: UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controller: (NSFetchedResultsController *)controller
   didChangeObject: (id)anObject
	   atIndexPath: (NSIndexPath *)indexPath
	 forChangeType: (NSFetchedResultsChangeType)type
	  newIndexPath: (NSIndexPath *)newIndexPath {
    
    if (self.suspendAutomaticTrackingOfChangesInManagedObjectContext == NO) {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath]
                                      withRowAnimation: UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject:indexPath]
                                      withRowAnimation: UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:indexPath]
                                      withRowAnimation: UITableViewRowAnimationFade];
                
                [self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation: UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent: (NSFetchedResultsController *)controller {
    if (self.beganUpdates == YES) {
        [self.tableView endUpdates];
        
        self.beganUpdates = NO;
    }
}

- (void)endSuspensionOfUpdatesDueToContextChanges {
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext: (BOOL)suspend {
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector: @selector(endSuspensionOfUpdatesDueToContextChanges)
                   withObject: 0
                   afterDelay: 0];
    }
}

@end
