//
//  JOArrayController.m
//  TreeSort
//
//  Created by Russell Newlands on 14/11/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "JOArrayController.h"

@interface JOArrayController (Private)

- (void)updateSortOrderOfModelObjects;

@end


@implementation JOArrayController (Private)

- (void)updateSortOrderOfModelObjects;
{
    NSUInteger i;
    NSArray *allObjects;
    
    allObjects = [self arrangedObjects];
    
    // Turn off 'Auto Rearrange Content' in interface builder to make this work
    for(i = 0; i < [allObjects count]; i++) {
        [[allObjects objectAtIndex:i] setValue:[NSNumber numberWithUnsignedInteger:i] forKey:@"sortIndex"];
    }
}

@end


@implementation JOArrayController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)insertObject:(id)object atArrangedObjectIndex:(NSUInteger)index;
{
    [super insertObject:object atArrangedObjectIndex:index];
    [self updateSortOrderOfModelObjects];
}


- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexes:(NSIndexSet *)indexes;
{
    [super insertObjects:objects atArrangedObjectIndexes:indexes];
	[self updateSortOrderOfModelObjects];
}


- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index;
{
    [super removeObjectAtArrangedObjectIndex:index];
    [self updateSortOrderOfModelObjects];
}


- (void)removeObjectsAtArrangedObjectIndexes:(NSIndexSet *)indexes;
{
    [super removeObjectsAtArrangedObjectIndexes:indexes];
	[self updateSortOrderOfModelObjects];
}

@end
