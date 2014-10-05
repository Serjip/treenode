//
//  ESTableView.m
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESCategoryView.h"
#import "TreeSortAppDelegate.h"
#import "NSManagedObject_Extensions.h"
#import "NSArrayController_Extensions.h"

@implementation ESCategoryView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)awakeFromNib;
{
    // Get the custom NSArrayController for the categoryView
	NSDictionary *bindingInfo = [self infoForBinding:NSContentBinding]; 
	categoryController = [bindingInfo valueForKey:NSObservedObjectKey];
        
    //Set the custom data types for drag and drop and copy and paste
    categoriesPBoardType = @"categoriesPBoardType";
	[self registerForDraggedTypes: [NSArray arrayWithObject:categoriesPBoardType]];
    [self setDraggingSourceOperationMask:(NSDragOperationMove | NSDragOperationCopy) forLocal:YES];

    context = [[NSApp delegate] managedObjectContext];
    
    // Set up a sort order for the entity that depends on the displayOrder attribute
	tableSorter = [[NSSortDescriptor alloc] initWithKey:@"sortIndex"
                                              ascending:YES
                                               selector:@selector(compare:)];
	
    NSArray *sortDescriptors = [NSArray arrayWithObject:tableSorter];
	[categoryController setSortDescriptors:sortDescriptors];
    
    // Set the delegate and dataSource
    [self setDataSource:(id < NSTableViewDataSource >)self];
    [self setDelegate:(id < NSTableViewDelegate >)self];
}


#pragma mark -
#pragma mark Event Handling methods

// Intercept key presses
- (void)keyDown:(NSEvent *)theEvent {
    
 	if(theEvent) {
		switch([[theEvent characters] characterAtIndex:0])
		{
			case NSDeleteCharacter:
                [categoryController removeObjectsAtArrangedObjectIndexes:[categoryController selectionIndexes]]; 
				break;
                
			default:
				[super keyDown:theEvent];
				break;
		}
	}
}


#pragma mark -
#pragma mark Copy and Paste

- (IBAction)copy:(id)sender;
{
    if([[categoryController selectedObjects] count] > 0 ) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [self writeToPasteboard:pasteBoard];
    }
}


- (IBAction)paste:(id)sender;
{
    // The generalPasteboard is used for copy and paste operations
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSUInteger insertionIndex = [categoryController indexForInsertion];
    
    if(![self createObjectsFromPasteboard:pasteBoard atInsertionIndex:insertionIndex]) {
        NSLog(@"Paste unsuccessful. No category property dictionary type found on pasteboard");
        NSBeep();
    }
}


- (IBAction)cut:(id)sender;
{
     if([[categoryController selectedObjects] count] > 0 ) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [self writeToPasteboard:pasteBoard];
    }
    
    [categoryController removeObjectsAtArrangedObjectIndexes:[categoryController selectionIndexes]];
}


- (IBAction)delete:(id)sender;
{
    [categoryController removeObjectsAtArrangedObjectIndexes:[categoryController selectionIndexes]]; 
}


- (void)writeToPasteboard:(NSPasteboard *)pasteBoard
{
    /*  The elected managed objects are found. The properties of each node are then
        read into a dictionary which is inserted into an array.
     */
    
    NSArray *selectedObjects = [categoryController selectedObjects];
    NSMutableArray *selectedObjectProps = [NSMutableArray array]; // Array of selected object properties for archiving
    
    // Return a dictionary of all objects attributes, their name and their relationship data. These will be ordered.
    for(id managedObject in selectedObjects) {
        [selectedObjectProps addObjectsFromArray:[managedObject objectPropertyTreeInContext:context]];
    }
    
	NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:selectedObjectProps];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:categoriesPBoardType, nil] owner:self]; 
    [pasteBoard setData:copyData forType:categoriesPBoardType];
}


- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard atInsertionIndex:(NSUInteger) insertionIndex;
{   
    NSArray *types = [pasteBoard types];
    if([types containsObject:categoriesPBoardType]) {
        NSData  *data = [pasteBoard dataForType:categoriesPBoardType];
        
        /*  The data is archived up as a series of NSDictionaries when copy or drag occurs, so unarchive first
         The objects are created and the URI representation used to set their properties. The properties copied
         include all attributes, the related object URI's and the original indexPaths for treeNode objects
         */
        
        NSArray *copiedProperties;
        if(data) {
            copiedProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            NSMutableDictionary *indexForURI = [NSMutableDictionary dictionary];
            NSUInteger i;
            NSMutableArray *newObjects = [NSMutableArray array];
            
            // Setup lookup dictionary to find related managedObjects, need to do this first so that we can find the base nodes
            for (i = 0; i < [copiedProperties count]; ++i) {
                NSDictionary *copiedDict = [copiedProperties objectAtIndex:i];
                NSURL *selfURI = [copiedDict valueForKey:@"selfURI"];
                [indexForURI setObject:[NSNumber numberWithUnsignedInteger:i] forKey:selfURI];
            }
            
            // Now create new managed objects setting the attributes of each from the copied properties
            for (NSDictionary *copiedDict in copiedProperties) {
                NSString *entityName = [copiedDict valueForKey:@"entityName"];
                NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                
                // Set all the attributes of the object, do this before calling NSTreeController's insert Object method                               
                NSDictionary *attributes = [copiedDict valueForKey:@"attributes"];
                for (NSString *attributeName in attributes) {
                    [newManagedObject setValue:[attributes valueForKey:attributeName] forKey:attributeName];
                }
                
				// Only insert Category objects, comments will automatically get linked
                if ([entityName isEqualToString:@"Category"]) {
	                [categoryController insertObject:newManagedObject atArrangedObjectIndex:insertionIndex];
	                insertionIndex++;
                }				

                [newObjects addObject:newManagedObject];
            }
            
            // Set the relationships of the new objects by using the lookup dictionary.
            for (i = 0; i < [newObjects count]; ++i) {
                NSDictionary *copiedRelationships = [[copiedProperties objectAtIndex:i] valueForKey:@"relationships"];
				NSLog(@"copied relationships are %@", copiedRelationships);
                NSManagedObject *newObject = [newObjects objectAtIndex:i];
                NSString *entityName = [[newObject entity] name];
                NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] relationshipsByName];
                
                for (NSString *relationshipName in [copiedRelationships allKeys]) {
                    NSArray *relatedObjectURIs = [copiedRelationships valueForKey:relationshipName];
                    NSRelationshipDescription *relDescription = [relationships objectForKey:relationshipName];  
                    /*  No need to set to one relationships because the inverse is set automatically by when an object is added
                     The copied base objects also have their parent (to - one) relationship set by insert.
                     the newRelationshipSet points to the original retrieved set and this is what is updated on adding
                     */
                    if([relDescription isToMany]) {
                        NSMutableSet *newRelationshipsSet = [newObject mutableSetValueForKey:relationshipName];
                        for (NSURL *objectURI in relatedObjectURIs) {
                            NSUInteger indexOfObject = [[indexForURI objectForKey:objectURI] unsignedIntegerValue];
                            [newRelationshipsSet addObject:[newObjects objectAtIndex:indexOfObject]];
                        }
                    }                   
                }
            }
            return YES;
        }
    }    
    return NO;
}


#pragma mark -
#pragma mark NSTableView Drag and Drop Delegate Methods

/*
This method is invoked by an tableView after determination that drag
should begin but before the drag has started. Remember to call registerForDraggedTypes
in the tableView to set up dragging.
*/

- (BOOL)tableView:(NSTableView *)categoryTable writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pasteBoard
{
    [self writeToPasteboard:pasteBoard];
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)view
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(int)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{    
    NSDragOperation result = NSDragOperationNone;
    
    if (dropOperation == NSTableViewDropAbove) {       
        // copy if it's not from our view or if the option/alt key is being held down, otherwise move
        if ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)
            result = NSDragOperationCopy;
        else
            result = NSDragOperationMove;
    }
    // Remember to set setDraggingSourceOperationMask: in awakeFromNib to set a dragging source destination mask
    return result;
}


- (BOOL)tableView:(NSTableView*)aTableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(int)row
    dropOperation:(NSTableViewDropOperation)dropOperation
{    
    if ([info draggingSourceOperationMask] == 0 ) //i.e. the dragging source does not permit drags
		return NO;
    
    NSPasteboard  *pasteBoard = [info draggingPasteboard];
    
    // If the drag is a move (not a copy because modifier key not held down)
    // This works because only matching bits will become 1 with the bitwise '&' operator
    if ([info draggingSourceOperationMask] & NSDragOperationMove) {
        // A delete then paste operation. Can't be bothered to do a move here.
        NSArray *selection = [categoryController selectedObjects];
        [self createObjectsFromPasteboard:pasteBoard atInsertionIndex:(NSUInteger) row];
        [categoryController removeObjects:selection];
    }
    else {
        // The modifier key was held down so do a copy
        [self createObjectsFromPasteboard:pasteBoard atInsertionIndex:(NSUInteger) row];
    }
    
    return YES;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
    [tableSorter release];
    [super dealloc];
}

@end
