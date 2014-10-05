//
//  NSArrayController_Extensions.m
//  TreeSort
//
//  Created by Russell Newlands on 14/11/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "NSArrayController_Extensions.h"

@implementation NSArrayController (NSArrayController_Extensions)

- (NSUInteger)indexForInsertion;
{
    NSUInteger arrayCount = [[self arrangedObjects] count];
	NSIndexSet *selectedRows = [self selectionIndexes];
	NSUInteger insertionIndex;

	if ([selectedRows count] == 0)
		insertionIndex = arrayCount;
	else if ([selectedRows count] == 1) {
        insertionIndex = [selectedRows firstIndex] + 1;
	} else
        insertionIndex = [selectedRows lastIndex] + 1;
	return insertionIndex;
}

@end
