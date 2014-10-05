//
//  ESComment.h
//  TreeSort
//
//  Created by Russell Newlands on 11/12/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ESCategory;

@interface ESComment : NSManagedObject {
 @private
}

@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSNumber *sortIndex;
@property (nonatomic, retain) ESCategory *category;

@end
