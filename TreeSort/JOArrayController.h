//
//  JOArrayController.h
//  TreeSort
//
//  Created by Russell Newlands on 14/11/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface JOArrayController : NSArrayController
{
  @private  
}

// Overide the following NSArrayController methods. On insertion or deletions update the sortIndex based on new position
- (void)insertObject:(id)object atArrangedObjectIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexes:(NSIndexSet *)indexes;
- (void)removeObjectAtArrangedObjectIndex:(NSUInteger)index;
- (void)removeObjectsAtArrangedObjectIndexes:(NSIndexSet *)indexes;

@end
