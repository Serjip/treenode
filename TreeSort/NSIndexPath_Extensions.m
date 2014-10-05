//
//  NSIndexPath_Extensions.m
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "NSIndexPath_Extensions.h"


@implementation NSIndexPath (NSIndexPath_Extensions)

- (NSUInteger)firstIndex;
{
	return [self indexAtPosition:0]; 
}


- (NSUInteger)lastIndex;
{
	return [self indexAtPosition:[self length] - 1];
}


- (NSIndexPath *)indexPathByIncrementingLastIndex;
{
	NSUInteger lastIndex = [self lastIndex];
	NSIndexPath *temp = [self indexPathByRemovingLastIndex];
	return [temp indexPathByAddingIndex:++lastIndex];
}


- (NSIndexPath *)indexPathByReplacingIndexAtPosition:(NSUInteger)position withIndex:(NSUInteger)index;
{
	NSUInteger indexes[[self length]]; // this declares a C array of NSUInteger types!
	[self getIndexes:indexes]; // getIndexes returns a pointer to the indexes array
	indexes[position] = index;
	return [[[NSIndexPath alloc] initWithIndexes:indexes length:[self length]] autorelease];
}

@end
