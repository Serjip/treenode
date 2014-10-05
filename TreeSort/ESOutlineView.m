//
//  ESOutlineView.m
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESOutlineView.h"
#import "OutlineViewController.h"

@implementation ESOutlineView

@synthesize outlineViewController;

#pragma mark -
#pragma mark Event Handling methods

// Intercept key presses
- (void)keyDown:(NSEvent *)theEvent
{
	if(theEvent) {
		switch([[theEvent characters] characterAtIndex:0])
		{
			case NSDeleteCharacter:
				[outlineViewController deleteItems];
				break;
                                
			default:
				[super keyDown:theEvent];
				break;
		}
	}
}

- (IBAction)copy:(id)sender;
{	
    [outlineViewController copy];
}

- (IBAction)paste:(id)sender
{
    [outlineViewController paste];
}

- (IBAction)cut:(id)sender
{
    [outlineViewController cut];
}

- (IBAction)delete:(id)sender
{
    [outlineViewController delete];
}


- (void)dealloc
{
    [super dealloc];
}

@end

