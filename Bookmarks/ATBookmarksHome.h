//
//  ATBookmarksHome.h
//  ATBookmarks
//
//  Created by 高田 明史 on 2012/11/30.
//
//

#import <Foundation/Foundation.h>
#import <Nursery/Nursery.h>

@class ATBookmarks;
@class ATBookmarksPresentation;
@class ATIDPool;

@interface ATBookmarksHome : NSObject
{
    NUBell *bell;
    ATBookmarks *bookmarks;
    ATIDPool *bookmarksPresentationIDPool;
    NSMutableArray *bookmarksPresentations;
    NSDictionary *windowSettings;
    NUMainBranchNursery *nursery;
}

+ (id)bookmarksHome;

- (ATBookmarksPresentation *)newBookmarksPresentation;

- (NSNumber *)newBookmarksPresentationID;

@end

@interface ATBookmarksHome (Coding) <NUCoding>
- (NUPlayLot *)playLot;
@end

@interface ATBookmarksHome (Accessing)

- (ATBookmarks *)bookmarks;
- (void)setBookmarks:(ATBookmarks *)aBookmarks;

- (NUMainBranchNursery *)nursery;
- (ATIDPool *)bookmarksPresentationIDPool;
- (NSMutableArray *)bookmarksPresentations;
- (NSDictionary *)windowSettings;
- (void)setWindowSettings:(NSDictionary *)aDictionary;

@end

@interface ATBookmarksHome (Private)

- (void)setNursery:(NUMainBranchNursery *)aNursery;
- (void)setBookmarksPresentationIDPool:(ATIDPool *)aPool;
- (void)setBookmarksPresentations:(NSMutableArray *)aPresentations;

@end