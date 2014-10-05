//
//  NSManagedObject_Extensions.m
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "NSManagedObject_Extensions.h"

@implementation NSManagedObject (NSManagedObject_Extensions)

- (NSArray *)objectPropertyTreeInContext:(NSManagedObjectContext *)context;
{
    NSMutableArray *objectPropertyTree = [NSMutableArray array];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSMutableDictionary *allAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *allRelated = [NSMutableDictionary dictionary];

	NSString *entityName = [[self entity] name];
    [properties setValue:entityName forKey:@"entityName"];
    
	NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] relationshipsByName];
    NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName];
    
    for(NSString *attributeName in attributes) {
        [allAttributes setValue:[self valueForKey:attributeName] forKey:attributeName];
    }
    [properties setValue:allAttributes forKey:@"attributes"];
	
	for(NSString *relationshipName in [relationships allKeys]) {
        NSMutableArray *relatedURIs = [NSMutableArray array];
        NSManagedObject *relatedObject;
        NSRelationshipDescription *relDescription = [relationships objectForKey:relationshipName];
        
        if([relDescription isToMany]) {
            NSMutableSet *sourceSet = [self mutableSetValueForKey:relationshipName];
            
            for (relatedObject in sourceSet) {
                NSURL *relatedObjectURI = [[relatedObject objectID] URIRepresentation];
                if(relatedObjectURI) {
                    [relatedURIs addObject:relatedObjectURI];
                    [allRelated setValue:relatedURIs forKey:relationshipName];
                }
            }

            for (relatedObject in sourceSet) {                
                //recursive bit, call method again with relatedObject
                [objectPropertyTree addObjectsFromArray:[relatedObject objectPropertyTreeInContext:context]];
			}
            
		} else {
            relatedObject = [self valueForKey:relationshipName];
            NSURL *relatedObjectURI = [[relatedObject objectID] URIRepresentation];
            if(relatedObjectURI) {
                [relatedURIs addObject:relatedObjectURI];
                [allRelated setValue:relatedURIs forKey:relationshipName];
            }
        }
        
        [properties setValue:allRelated forKey:@"relationships"];
    }
       
    NSURL *selfURI = [[self objectID] URIRepresentation];
    [properties setValue:selfURI forKey:@"selfURI"];
    
    [objectPropertyTree addObject:properties];
    
    // 	return a dictionary of all managed object properties keyed to the object URIDescription
    return [[objectPropertyTree copy] autorelease];
}

@end
