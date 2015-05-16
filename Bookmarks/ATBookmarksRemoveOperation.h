//
//  BookmarksRemoveOperation.h
//  Bookmarks
//
//  Created by P,T,A  on 12/01/08.
//  Copyright (c) 2012年 PEDOPHILIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATBookmarksOperation.h"

@interface ATBookmarksRemoveOperation : ATBookmarksOperation

+ (id)removeOperationWithIndexes:(NSIndexSet *)anIndexes binder:(ATBinder *)aBinder  contextInfo:(id)anInfo;

- (id)initWithIndexes:(NSIndexSet *)anIndexes binder:(ATBinder *)aBinder  contextInfo:(id)anInfo;

@end
