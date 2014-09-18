//
//  ATMoveOperationItem.h
//  ATBookmarks
//
//  Created by 高田 明史 on 09/08/13.
//  Copyright 2009 Pedophilia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATItem;

@interface ATMoveOperationItem : NSObject
{
	ATItem *item;
	BOOL canMove;
}

+ (id)moveOperationItemWith:(ATItem *)anItem canMove:(BOOL)aCanMove;
- (id)initWithItem:(ATItem *)anItem canMove:(BOOL)aCanMove;

- (ATItem *)item;
- (BOOL)canMove;

@end
