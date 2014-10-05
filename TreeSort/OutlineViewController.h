//
//  OutlineViewController.h
//  TreeSort
//
//  Created by Newlands Russell on 10/10/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESTreeController;
@class ESOutlineView;

@interface OutlineViewController : NSObject <NSOutlineViewDelegate>
{
 @private
    NSManagedObjectContext *context;
    ESTreeController *treeController;
    
    NSString *treeNodeIndexPathPBoardType;
    NSString *outlineViewPropertiesPBoardType;
}

@property (assign) IBOutlet ESOutlineView *testOutlineView;
@property (assign) IBOutlet NSButton *theNewLeaf;
@property (assign) IBOutlet NSButton *theNewGroup;

- (NSArray *)treeNodeSortDescriptors; // This is a 'getter' method whose name is used in binding the sortDescriptors property of the treeController

- (IBAction)theNewLeaf:(id)sender;
- (IBAction)theNewGroup:(id)sender;

- (void)copy;
- (void)paste;
- (void)cut;
- (void)delete;

- (void)deleteItems;
- (void)cutItems;
- (void)writeToPasteboard:(NSPasteboard *)pasteBoard;
- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard;

- (void)restoreExpansionStates;

@end
