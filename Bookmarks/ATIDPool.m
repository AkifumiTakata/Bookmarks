//
//  ATIDPool.m
//  Bookmarks
//
//  Created by Akifumi Takata on 05/10/11.
//  Copyright 2005 Nursery-Framework. All rights reserved.
//

#import "ATIDPool.h"


@implementation ATIDPool

@end

@implementation ATIDPool (Initializing)

+ (id)idPool
{
    return [[self new] autorelease];
}

+ (id)newWith:(NSDictionary *)aPropertyList
{
	return [[[self alloc] initWith:aPropertyList] autorelease];
}

- (id)initWith:(NSDictionary *)aPropertyList
{
	[super init];
	
//    if ([aPropertyList objectForKey:@"unusedIDs"])
//    {
//        NSIndexSet *anUnusedIDs = [NSUnarchiver unarchiveObjectWithData:[aPropertyList objectForKey:@"unusedIDs"]];
//        NSIndexSet *aUsedIDs = [NSUnarchiver unarchiveObjectWithData:[aPropertyList objectForKey:@"usedIDs"]];
//        nextID = [anUnusedIDs firstIndex];
//        freeIDs = [[NSMutableIndexSet indexSet] retain];
//    }

	if ([aPropertyList objectForKey:@"freeIDs"])
    {
        freeIDs = [[NSUnarchiver unarchiveObjectWithData:[aPropertyList objectForKey:@"freeIDs"]] retain];
        nextID = [[aPropertyList objectForKey:@"nextID"] unsignedLongLongValue];
    }
    
	return self;
}

- (id)init
{
	[super init];
	
//	unusedIDs = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, NSNotFound - 1)];
//	usedIDs = [[NSMutableIndexSet indexSet] retain];

    nextID = 0;
    freeIDs = [[NSMutableIndexSet indexSet] retain];
	
	return self;
}

- (void)dealloc
{
	[freeIDs release];
	
	[super dealloc];
}

@end

@implementation ATIDPool (Coding)

+ (BOOL)automaticallyEstablishCharacter
{
    return YES;
}

+ (void)defineCharacter:(NUCharacter *)aCharacter on:(NUGarden *)aGarden
{
    [aCharacter addUInt64IvarWithName:@"nextID"];
    [aCharacter addOOPIvarWithName:@"freeIDs"];
}

- (void)encodeWithAliaser:(NUAliaser *)anAliaser
{
    [anAliaser encodeUInt64:nextID];
    [anAliaser encodeObject:freeIDs];
}

- (id)initWithAliaser:(NUAliaser *)anAliaser
{
    [super init];
    
    nextID = [anAliaser decodeUInt64];
    NUSetIvar(&freeIDs, [anAliaser decodeObjectReally]);
    
    return self;
}

- (NUBell *)bell
{
    return bell;
}

- (void)setBell:(NUBell *)anOOP
{
    bell = anOOP;
}

@end

@implementation ATIDPool (Accessing)

- (NUUInt64)newID
{
	NUUInt64 aNewID = nextID++;
	return aNewID;
}

- (NUUInt64)newIDWith:(NUUInt64)anID
{
	if ([self isUsing:anID])
		return NSNotFound;
	else
	{
        if ([freeIDs containsIndex:anID])
            [freeIDs removeIndex:anID];
        else
        {
            if (anID > nextID)
                [freeIDs addIndexesInRange:NSMakeRange(nextID, anID - nextID)];
            nextID = anID + 1;
        }
        
		return anID;
	}
}

- (void)releaseID:(NUUInt64)anID
{
    [freeIDs addIndex:anID];
}

@end


@implementation ATIDPool (Testing)

- (BOOL)isUsing:(NUUInt64)anID
{
    return anID < nextID && ![freeIDs containsIndex:anID];
}

@end

@implementation ATIDPool (Converting)

- (NSDictionary   *)propertyListRepresentation
{	
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSArchiver archivedDataWithRootObject:freeIDs],@"freeIDs", [NSNumber numberWithUnsignedLongLong:nextID],@"nextID", nil];
}

@end
