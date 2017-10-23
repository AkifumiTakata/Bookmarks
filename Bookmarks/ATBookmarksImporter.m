//
//  BookmarksImporter.m
//  Bookmarks
//
//  Created by P,T,A on 2014/06/07.
//  Copyright (c) 2014年 Nursery-Framework. All rights reserved.
//

#import "ATBookmarksImporter.h"

@implementation ATBookmarksImporter

+ (id)importer
{
    return [[[self alloc] init] autorelease];
}

- (NSString *)bookmarksFilepath
{
    return bookmarksFilepath;
}

- (void)setBookmarksFilepath:(NSString *)aFilepath
{
    [bookmarksFilepath release];
    bookmarksFilepath = [aFilepath copy];
}

- (NSString *)defaultBookmarksFilepath
{
    return nil;
}

- (ATBinder *)importBookmarksFromContentsOfFile:(NSString *)aFilepath
{
    [self setBookmarksFilepath:aFilepath];
    return [self importBookmarks];
}

- (ATBinder *)importBookmarks
{
    return nil;
}

@end
