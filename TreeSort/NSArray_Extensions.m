//
//  NSArray_Extensions.m
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "NSArray_Extensions.h"


@implementation NSArray (ESExtensions)

- (id)firstObject;
{
	if ([self count] == 0)
		return nil;
	return [self objectAtIndex:0];
}

@end
