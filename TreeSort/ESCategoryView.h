//
//  ESTableView.h
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ESTreeController;
@class JOArrayController;

@interface ESCategoryView: NSTableView
{
    NSManagedObjectContext *context;
    JOArrayController *categoryController;
    NSSortDescriptor *tableSorter;
    
    NSString *categoriesPBoardType;
}

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)delete:(id)sender;

- (void)writeToPasteboard:(NSPasteboard *)pasteBoard;
- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard atInsertionIndex:(NSUInteger) insertionIndex;

@end
