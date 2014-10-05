//
//  TreeSortAppDelegate.m
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "TreeSortAppDelegate.h"
#import "ESTreeNode.h"
#import "ESCategory.h"
#import "ESComment.h"
#import "OutlineViewController.h"

@implementation TreeSortAppDelegate

@synthesize window;
@synthesize testOutlineView;
@synthesize outlineViewController;
@synthesize categoryController;
@synthesize commentController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // register for a notification when objects are changed in the Managed Object Context
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(objectsChangedInContext:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[self managedObjectContext]];
}

- (void)awakeFromNib;
{
    //Set the custom data types for drag and drop and copy and paste
    categoriesPBoardType = @"categoriesPBoardType";
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "TreeSort" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"TreeSort"];
}


/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TreeSort" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"TreeSort.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    
/** 
    Changed the call to addPersistantStore... to add core data model versioning support as according to
    prag prog book on core data
 */
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    
    if(![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:dict error:&error]) {        
        NSDictionary *ui = [error userInfo];
        if(ui) {
            NSLog(@"%@:%@ %@", [self class], NSStringFromSelector(_cmd), [error localizedDescription]);
            for (NSError *suberror in [ui valueForKey:NSDetailedErrorsKey]) {
                NSLog(@"\t%@", [suberror localizedDescription]); }
        } else {
            NSLog(@"%@:%@ %@", [self class], NSStringFromSelector(_cmd), [error localizedDescription]);
        }
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Unable to load the application database."];
        NSString *msgText = nil;
        msgText = [NSString stringWithFormat:@"The application database %@%@%@\n%@",
                   @"is either corrupt or was created by a newer ", @"version of the application. Please contact ", @"support to assist with this error.\n\nError: ", [error localizedDescription]];
        [alert setInformativeText:msgText]; [alert addButtonWithTitle:@"Quit"]; [alert runModal];
        [alert release];
        
        exit(1);
        
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }
    return __persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext
{
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}


/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window 
{
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction) saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


// undo and redo
-(BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    if ([anItem action] == @selector(undo:)) {
        return [[[self managedObjectContext] undoManager] canUndo];
    } 
    else if ([anItem action] == @selector(redo:)) {
        return [[[self managedObjectContext] undoManager] canRedo];
    }
    return YES;
}

-(IBAction)undo:sender
{
    [[[self managedObjectContext] undoManager] undo];
}


-(IBAction)redo:sender
{
    [[[self managedObjectContext] undoManager] redo];
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [super dealloc];
}


#pragma mark -
#pragma mark Create New Managed Objects

- (IBAction)newCategory:(id)sender;
{
    ESCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
    
    static NSUInteger count = 0;
    category.displayName = [NSString stringWithFormat:@"Category %i",++count];
    NSLog(@"newCategory with name = %@", category.displayName);
    
    [categoryController insertObject:category atArrangedObjectIndex:[[categoryController arrangedObjects] count]];	
}


- (IBAction)newComment:(id)sender;
{
    ESComment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:[self managedObjectContext]];
    
    static NSUInteger count = 0;
    comment.displayName = [NSString stringWithFormat:@"Comment %i",++count];
    NSLog(@"newComment with name = %@", comment.displayName);
    
    [commentController insertObject:comment atArrangedObjectIndex:[[commentController arrangedObjects] count]];
}


#pragma mark -
#pragma mark Handle Context Changes

// Handles posted notifications and is called when objects in the context
// change. Used here to intercept and handle redo/undo

- (void)objectsChangedInContext:(NSNotification *)note
{
	BOOL isESTreeNode;
	
	// Find out if an undo or redo has occured
	NSUndoManager *undoManager = [[self managedObjectContext]  undoManager];
	BOOL isUndoingOrRedoing = [undoManager isUndoing] || [undoManager isRedoing];
	
	// Querry the info dictionary to disover the object(s) undone or redone and
	// find the class these belong to
	NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    
	if ([[updatedObjects anyObject] isKindOfClass:[ESTreeNode class]]) {
		isESTreeNode = YES;
	}			
	
	/*  If undoing or redoing, handle the appropriate model/view changes depending
        on the class of MO
     */
	if(isUndoingOrRedoing) {
		if(isESTreeNode) {
            /*  This restores all expansion states passing root as parent, necessary
                because these are not restored on an undo or redo. Also reordering of the
                controller contents is done because the outlineView is not synched with the 
                model changes in an undo. I first used -reloadData here but this did nothing.
             */;
            
            // Get the treeController
            NSDictionary *bindingInfo = [testOutlineView infoForBinding:NSContentBinding]; 
            treeController = [bindingInfo valueForKey:NSObservedObjectKey];
            
            [treeController rearrangeObjects];
            [outlineViewController restoreExpansionStates];
		}
	}
}

@end
