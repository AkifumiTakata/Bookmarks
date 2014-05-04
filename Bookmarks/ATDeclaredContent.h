//
//  ATDeclaredContent.h
//  ATBookmarks
//
//  Created by ���c�@���j on 07/08/14.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATProcessIndicator;

@interface ATDeclaredContent : NSObject
{
	NSString *content;
}

+ (id)RCDATA;
+ (id)EMPTY;

- (id)initWithContent:(NSString *)aContent;

- (BOOL)isContentModel;
- (BOOL)isDeclaredContent;

- (BOOL)isCDATA;
- (BOOL)isRCDATA;
- (BOOL)isEMPTY;

- (ATProcessIndicator *)asIndicator;

@end
