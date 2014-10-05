//
//  ESOutlineView.h
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OutlineViewController;

@interface ESOutlineView : NSOutlineView
{
 @private
}

@property (assign) IBOutlet OutlineViewController *outlineViewController;

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)delete:(id)sender;

@end
