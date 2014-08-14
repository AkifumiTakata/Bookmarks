/* ATBookmarksWindowController */

#import <Cocoa/Cocoa.h>

@class ATBookmarks;
@class ATBookmarksHome;
@class ATBookmarksPresentation;
@class ATBookmarksBrowserController;

@interface ATBookmarksWindowController : NSWindowController
{
	IBOutlet id bookmarksView;
	IBOutlet ATBookmarksPresentation *bookmarksPresentation;
	IBOutlet NSObjectController *presentationController;
    IBOutlet ATBookmarksBrowserController *browserController;
    ATBookmarksHome *bookmarksHome;
	NSUInteger windowIndex;
	BOOL ignoreWindowFrameChange;
}
@end

@interface ATBookmarksWindowController (Initializing)

+ (id)controllerWithPresentation:(ATBookmarksPresentation *)aPresentation windowIndex:(NSUInteger)anIndex home:(ATBookmarksHome *)aHome;

- (id)initWithPresentation:(ATBookmarksPresentation *)aPresentation windowIndex:(NSUInteger)anIndex home:(ATBookmarksHome *)aHome;

@end

@interface ATBookmarksWindowController (Accessing)

- (ATBookmarks *)bookmarks;

- (void)setBookmarksPresentation:(ATBookmarksPresentation *)aPresentation;
- (ATBookmarksPresentation *)bookmarksPresentation;

- (NSIndexSet *)selectionIndexSetInPresentation;

@end

@interface ATBookmarksWindowController (Actions)

- (IBAction)makeNewBookmark:(id)sender;
- (IBAction)makeNewFolder:(id)sender;

- (IBAction)showNewWindow:(id)sender;

- (IBAction)openWindowWithCurrentPresentation:(id)sender;
- (IBAction)openWindowForCurrentBinder:(id)sender;
- (IBAction)openItem:(id)sender;

- (IBAction)loadWebIconOfSelectedItems:(id)sender;

- (IBAction)openSelectedBinder:(id)sender;

@end

@interface ATBookmarksWindowController (Testing)

- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem;

- (BOOL)ignoreWindowFrameChange;
- (void)setIgnoreWindowFrameChange:(BOOL)aFlag;

@end

@interface ATBookmarksWindowController (Notifying)

- (void)addObserverForWindow;
- (void)windowDidMoveOrResize:(NSNotification *)aNotification;

@end
