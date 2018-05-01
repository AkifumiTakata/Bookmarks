//
//  ATBookmaksBrowserController.h
//  Bookmarks
//
//  Created by Akifumi Takata  on 11/12/30.
//  Copyright (c) 2011年 Nursery-Framework. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ATBookmarksHome, ATBookmarksPresentation;

@interface ATBookmarksBrowserController : NSViewController
{
    NSBrowser *browser;
    ATBookmarksHome *bookmarksHome;
    ATBookmarksPresentation *bookmarksPresentaion;
    NSUInteger disableCountOfUpdating;
}

- (NSBrowser *)browser;
- (void)setBrowser:(NSBrowser *)aBrowser;

- (ATBookmarksHome *)bookmarksHome;
- (void)setBookmarksHome:(ATBookmarksHome *)aBookmarksHome;

- (ATBookmarksPresentation *)bookmarksPresentation;
- (void)setBookmarksPresentation:(ATBookmarksPresentation *)aBookmarksPresentation;

- (void)presentationDidChange:(NSNotification *)aNotification;

- (void)browser:(id)sender draggingEntered:(id <NSDraggingInfo>)aDraggingInfo;
- (void)browser:(id)sender draggingEnded:(id <NSDraggingInfo>)aDraggingInfo;

- (void)updateBrowser:(BOOL)aRootChanged;

- (BOOL)updatingIsEnabled;

- (void)disableUpdating;
- (void)enableUpdating;

- (NSMenu *)menuForEvent:(NSEvent *)theEvent;

- (IBAction)openItem:(id)sender;

@end
