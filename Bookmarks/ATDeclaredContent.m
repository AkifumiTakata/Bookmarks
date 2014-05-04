//
//  ATDeclaredContent.m
//  ATBookmarks
//
//  Created by ���c�@���j on 07/08/14.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATDeclaredContent.h"


@implementation ATDeclaredContent

+ (id)RCDATA
{	
	return [[[self alloc] initWithContent:@"RCDATA"] autorelease];
}

+ (id)EMPTY
{	
	return [[[self alloc] initWithContent:@"EMPTY"] autorelease];
}

- (id)initWithContent:(NSString *)aContent
{
	[super init];
	
	content = [aContent copy];
	
	return self;
}

- (void)dealloc
{
	[content release];
	
	[super dealloc];
}

- (BOOL)isDeclaredContent
{
	return YES;
}

- (BOOL)isContentModel
{
	return NO;
}

- (BOOL)isCDATA
{
	return [content isEqualToString:@"CDATA"];
}

- (BOOL)isRCDATA
{
	return [content isEqualToString:@"RCDATA"];
}

- (BOOL)isEMPTY
{
	return [content isEqualToString:@"EMPTY"];
}

- (ATProcessIndicator *)asIndicator
{
	return [[[ATProcessIndicator alloc] initWithContent:self] autorelease];
}

@end