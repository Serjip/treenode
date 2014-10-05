//
//  ESCategory.h
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ESTreeNode;

@interface ESCategory : NSManagedObject 
{
 @private
}

@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) ESTreeNode *treeNode;

@end
