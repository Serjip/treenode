//
//  NSTreeController_Extensions.m
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "NSTreeController_Extensions.h"


@implementation NSTreeController (NSTreeController_Extensions)

// Navigation and searching of paths and nodes
- (NSArray *)rootNodes;
{
	return [[self arrangedObjects] childNodes];
}


- (NSTreeNode *)nextSiblingOfNode:(NSTreeNode *)node;
{
	return [self nextSiblingOfNodeAtIndexPath:[node indexPath]];
}


- (NSTreeNode *)nextSiblingOfNodeAtIndexPath:(NSIndexPath *)indexPath;
{
	return [[self arrangedObjects] descendantNodeAtIndexPath:[indexPath indexPathByIncrementingLastIndex]];
}


- (NSTreeNode *)nodeAtIndexPath:(NSIndexPath *)indexPath;
{
	return [[self arrangedObjects] descendantNodeAtIndexPath:indexPath];
}


// Will create an NSIndexPath after the selection, or as for the top of the children of a group node
- (NSIndexPath *)indexPathForInsertion;
{
	NSUInteger rootTreeNodesCount = [[self rootNodes] count];
	NSArray *selectedNodes = [self selectedNodes];
	NSTreeNode *selectedNode = [selectedNodes firstObject];
	NSIndexPath *indexPath;
	
	if ([selectedNodes count] == 0)
		indexPath = [NSIndexPath indexPathWithIndex:rootTreeNodesCount];
	else if ([selectedNodes count] == 1) {
		if (![selectedNode isLeaf])
			indexPath = [[selectedNode indexPath] indexPathByAddingIndex:0];
		else {
			if ([selectedNode parentNode])
				indexPath = [selectedNode adjacentIndexPath];
			else
				indexPath = [NSIndexPath indexPathWithIndex:rootTreeNodesCount];
		}
	} else
		indexPath = [[selectedNodes lastObject] adjacentIndexPath];
	return indexPath;
}


- (NSIndexPath *)indexPathToObject:(id)object;
{
    return [[self treeNodeForObject:object] indexPath];
}


- (NSTreeNode *)treeNodeForObject:(id)object;
{
	NSTreeNode *treeNode = nil;
	for (NSTreeNode *node in [self flattenedNodes]) {
		if ([node representedObject] == object) {
			treeNode = node;
			break;
		}
	}
	return treeNode;
}


// Many methods for 'flattening content' into an array
// Conversion of tree to array for easy lookup
- (NSArray *)flattenedContent;
{
    return [[self flattenedNodes] valueForKey:@"representedObject"]; // This converts each TreeNode in the array into a real object
}


// All the NSTreeNodes in the tree, depth-first searching
- (NSArray *)flattenedNodes;
{
	NSMutableArray *mutableArray = [NSMutableArray array];
	for (NSTreeNode *node in [self rootNodes]) {
		[mutableArray addObject:node];
		if (![[node valueForKey:[self leafKeyPath]] boolValue])
			[mutableArray addObjectsFromArray:[node valueForKey:@"descendants"]]; //Key-value coding used to access descendents (NSTreeNode category method)
	}
    // paranoid bit of code in case someone messes with your holy mutable array even though you've declared an 
    // immutable return version. Just return, it seems easier. Similar pattern for rest of related methods.
    
	return [[mutableArray copy] autorelease]; 
}


// Filter out nodes that are descended from each other in a selection to avoid duplication
- (NSArray *)filterByRemovingChildrenForNodes:(NSArray *)treeNodes;
{
    NSMutableArray *filteredNodes = [NSMutableArray array];
    
    for(NSTreeNode *potentialFilteredNode in treeNodes) {
        BOOL isChild = NO;
        
        for(NSTreeNode *potentialAncestorNode in treeNodes) {
            if((isChild = [potentialFilteredNode isDescendantOfNode:potentialAncestorNode]))
                break;
        }
        
        if(!isChild)
            [filteredNodes addObject:potentialFilteredNode];
    }
    return [[filteredNodes copy] autorelease];
}

// Convert the filtered nodes to NSManagedObjects
- (NSArray *)filterObjectsByRemovingChildrenForNodes:(NSArray *)treenodes;
{
    // Duplicate selections filtered out when a selected node is an ancestor of another selected node
    return [[self filterByRemovingChildrenForNodes:treenodes] valueForKey:@"representedObject"];
}


// Methods for 'flattening' selection content
- (NSArray *)flattenedSelectedNodes;
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    // Filter out duplicate selections when a selected node is an ancestor of another selected node
    NSArray *filteredNodes = [self filterByRemovingChildrenForNodes:[self selectedNodes]];   
    
    for (NSTreeNode *treeNode in filteredNodes) {
        if (![mutableArray containsObject:treeNode])
            [mutableArray addObject:treeNode];
        if (![[treeNode valueForKeyPath:[self leafKeyPath]] boolValue]) 
        {
            [mutableArray addObjectsFromArray:[treeNode valueForKey:@"descendants"]];
        }
    }
    
    return [[mutableArray copy] autorelease];
}


- (NSArray *)flattenedSelectedObjects;
{
    /*  Duplicate selections are filtered out when a selected node is an ancestor of another selected node
        This is done in the flattenedSelectedNodes Method
     */
    return [[self flattenedSelectedNodes] valueForKey:@"representedObject"];
}


- (NSArray *)flattenedSelectedLeafNodes;
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSTreeNode *treeNode in [self flattenedSelectedNodes]) {
        if ([[treeNode valueForKeyPath:[self leafKeyPath]] boolValue])
            [mutableArray addObject:treeNode];
    }
    return [[mutableArray copy] autorelease];
}


- (NSArray *)flattenedSelectedLeafObjects;
{
    return [[self flattenedSelectedLeafNodes] valueForKey:@"representedObject"];
}


- (NSArray *)flattenedSelectedGroupNodes;
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSTreeNode *treeNode in [self flattenedSelectedNodes]) {
        if (![[treeNode valueForKeyPath:[self leafKeyPath]] boolValue])
            [mutableArray addObject:treeNode];
    }
    return [[mutableArray copy] autorelease];
}


- (NSArray *)flattenedSelectedGroupObjects;
{
    return [[self flattenedSelectedGroupNodes] valueForKey:@"representedObject"];
}



// Selection methods
// Makes a blank selection in the outline view
- (void)selectNone;
{
	[self removeSelectionIndexPaths:[self selectionIndexPaths]];
}


- (void)selectParentFromSelection;
{
	if ([[self selectedNodes] count] == 0)
		return;
	
	NSTreeNode *parentNode = [[[self selectedNodes] firstObject] parentNode];
	if (parentNode)
		[self setSelectionIndexPath:[parentNode indexPath]];
	else
		// No parent exists (we are at the top of tree), so make no selection in our outline
		[self selectNone];
}


- (void)setSelectedNode:(NSTreeNode *)node;
{
    [self setSelectionIndexPath:[node indexPath]];
}


- (void)setSelectedObject:(id)object;
{
    [self setSelectedNode:[self treeNodeForObject:object]];
}


@end
