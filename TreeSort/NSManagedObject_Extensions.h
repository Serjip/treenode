//
//  NSManagedObject_Extensions.h
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (NSManagedObject_Extensions)

- (NSArray *)objectPropertyTreeInContext:(NSManagedObjectContext *)context;

@end
