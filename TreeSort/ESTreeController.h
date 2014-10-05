//
//  ESTreeController.h
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ESTreeController : NSTreeController
{
 @private
}

// Overide the following NSTreeController methods. On insertion or deletions update the sortIndex based on new position
- (void)insertObject:(id)object atArrangedObjectIndexPath:(NSIndexPath *)indexPath;
- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexPaths:(NSArray *)indexPaths;
- (void)removeObjectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath;
- (void)removeObjectsAtArrangedObjectIndexPaths:(NSArray *)indexPaths;
- (void)moveNode:(NSTreeNode *)node toIndexPath:(NSIndexPath *)indexPath;
- (void)moveNodes:(NSArray *)nodes toIndexPath:(NSIndexPath *)indexPath;

@end
