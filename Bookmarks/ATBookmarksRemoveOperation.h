//
//  ATBookmarksRemoveOperation.h
//  ATBookmarks
//
//  Created by 明史 高田 on 12/01/08.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATBookmarksOperation.h"

@interface ATBookmarksRemoveOperation : ATBookmarksOperation

+ (id)removeOperationWithIndexes:(NSIndexSet *)anIndexes binder:(ATBinder *)aBinder  contextInfo:(id)anInfo;

- (id)initWithIndexes:(NSIndexSet *)anIndexes binder:(ATBinder *)aBinder  contextInfo:(id)anInfo;

@end
