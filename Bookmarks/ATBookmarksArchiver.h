//
//  BookmarksArchiver.h
//  Bookmarks
//
//  Created by Akifumi Takata on 09/04/12.
//  Copyright 2009 Nursery-Framework. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATBookmarks;

@interface ATBookmarksArchiver : NSObject
{
	ATBookmarks *bookmarks;
	NSMutableArray *itemsPlist;
	NSMutableDictionary *archivedBookmarks;
}

+ (id)archive:(ATBookmarks *)aBookmarks;

- (id)initWithBookmarks:(ATBookmarks *)aBookmarks;

- (id)archive;

- (id)makeArchivedBookmarks;

@end
