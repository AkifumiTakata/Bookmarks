//
//  ATProcessIndicator.h
//  ATBookmarks
//
//  Created by ���c�@���j on 07/08/10.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATProcessIndicator : NSObject
{
	ATProcessIndicator *parent;
	id content;
	id indicators;
	NSString *connector;
	BOOL isEvaluated;
	BOOL isSuccess;
}

- (id)initWithContent:(id)aContent;

- (void)setParent:(ATProcessIndicator *)aParent;

- (id)nextIndicator;
- (void)evaluated:(ATProcessIndicator *)aChildIndicator;
- (BOOL)hasIndicatorToBeEvaluated;
- (void)succeed;
- (void)failed;
- (void)contentOccurred;
- (void)contentDoesNotOccurred;

- (BOOL)isEvaluated;
- (BOOL)isSuccess;

- (BOOL)isModelGroupIndicator;
- (BOOL)isElementTokenIndicator;

- (BOOL)isOrdered;
- (BOOL)isOR;

- (NSString *)elementName;

@end