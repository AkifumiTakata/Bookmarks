//
//  ATModelGroup.h
//  ATBookmarks
//
//  Created by ���c�@���j on 07/08/09.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATProcessIndicator;

@interface ATModelGroup : NSObject
{
	NSArray *contentTokens;
	NSString *occurrenceIndicator;
}

+ (id)modelGroupWithContentTokens:(NSArray *)aContentTokens;
+ (id)modelGroupWithContentTokens:(NSArray *)aContentTokens occurrenceIndicator:(NSString *)anIndicator;

- (id)initWithContentTokens:(NSArray *)aContentTokens;
- (id)initWithContentTokens:(NSArray *)aContentTokens occurrenceIndicator:(NSString *)anIndicator;

- (ATProcessIndicator *)asProcessIndicator;

- (BOOL)isDeclaredContent;

- (BOOL)isPrimitiveContentToken;
- (BOOL)isModelGroup;

- (NSString *)occurrenceIndicator;

- (NSEnumerator *)objectEnumerator;

@end