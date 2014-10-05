//
//  NSTreeNode_Extensions.h
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSTreeNode (NSTreeNode_Extensions)

- (NSArray *)descendants;
- (NSArray *)groupDescendants;
- (NSArray *)leafDescendants;
- (NSArray *)siblings;

- (BOOL)isDescendantOfNode:(NSTreeNode *)node;
- (BOOL)isSiblingOfNode:(NSTreeNode *)node;
- (BOOL)isSiblingOfOrDescendantOfNode:(NSTreeNode *)node;

- (NSIndexPath *)adjacentIndexPath;
- (NSIndexPath *)nextSiblingIndexPath;
- (NSIndexPath *)nextChildIndexPath;

@end
