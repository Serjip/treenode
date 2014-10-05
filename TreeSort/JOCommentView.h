//
//  JOCommentView.h
//  TreeSort
//
//  Created by Newlands Russell on 31/12/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <AppKit/AppKit.h>

@class JOArrayController;

@interface JOCommentView : NSTableView
{
    NSManagedObjectContext *context;
    JOArrayController *commentController;
    NSSortDescriptor *tableSorter;
    
    NSString *commentPBoardType;
}

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)delete:(id)sender;

- (void)writeToPasteboard:(NSPasteboard *)pasteBoard;
- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard atInsertionIndex:(NSUInteger) insertionIndex;

@end
