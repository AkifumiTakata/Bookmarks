//
//  ATMoveOperationItem.m
//  Bookmarks
//
//  Created by Akifumi Takata on 09/08/13.
//  Copyright 2009 Nursery-Framework. All rights reserved.
//

#import "ATMoveOperationItem.h"


@implementation ATMoveOperationItem

+ (id)moveOperationItemWith:(ATItem *)anItem canMove:(BOOL)aCanMove
{
	return [[[self alloc] initWithItem:anItem canMove:aCanMove] autorelease];
}

- (id)initWithItem:(ATItem *)anItem canMove:(BOOL)aCanMove
{
	[super init];
	
	item = [anItem retain];
	canMove = aCanMove;
	
	return self;
}

- (ATItem *)item
{
	return item;
}

- (BOOL)canMove
{
	return canMove;
}

- (void)dealloc
{
	[item release];
	item = nil;
	
	[super dealloc];
}

@end
