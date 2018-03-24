//
//  ATElement.h
//  Bookmarks
//
//  Created by Akifumi Takata on 07/08/09.
//  Copyright 2007 Nursery-Framework. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATMarkup;
@class ATNetscapeBookmarkFile1Scanner;
@class ATNetscapeBookmarkFile1DocumentEntity;

@interface ATElement : NSObject
{
	NSString *name;
	ATNetscapeBookmarkFile1DocumentEntity *documentEntity;
	ATNetscapeBookmarkFile1Scanner *scanner;
	ATMarkup *startTag;
	ATMarkup *endTag;
	id content;
}

+ (id)elementWithName:(NSString *)aName documentEntity:(ATNetscapeBookmarkFile1DocumentEntity *)aDocument scanner:(ATNetscapeBookmarkFile1Scanner *)aScanner;

- (id)initWithName:(NSString *)aName documentEntity:(ATNetscapeBookmarkFile1DocumentEntity *)aDocument scanner:(ATNetscapeBookmarkFile1Scanner *)aScanner;

- (BOOL)parse;
- (BOOL)parseContentFor:(id)aContent;

- (NSDictionary *)attributeList;

- (void)setContent:(id)aContent;
- (id)content;

- (void)add:(id)aContent;

- (BOOL)nameIs:(NSString *)aName;
- (BOOL)hasChildElement;

- (NSUInteger)countOfElementNamed:(NSString *)aName;

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)subtreeEnumerator;

@end
