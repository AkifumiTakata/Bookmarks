//
//  ATWebIconLoader.h
//  Bookmarks
//
//  Created by Akifumi Takata on 2012/12/28.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class ATBookmarks;

@protocol ATWebIconLoaderDelegate <NSObject>

- (void)webIconLoaderDidFinishLoading:(id)sender;

@end

@interface ATWebIconLoader : NSObject <WebFrameLoadDelegate>
{
	NSArray *items;
    NSMutableDictionary *urlToFaviconDictionary;
	NSUInteger currentIndex;
    NSString *title;
	NSImage *currentIconImage;
	BOOL inCancel;
    WebView *webView;
    ATBookmarks *bookmarks;
    id <ATWebIconLoaderDelegate> delegate;
}

+ (id)newWith:(NSArray *)anItems bookmarks:(ATBookmarks *)aBookmarks;
- (id)initWith:(NSArray *)anItems bookmarks:(ATBookmarks *)aBookmarks;

- (void)setWebView:(WebView *)aWebVew;

- (void)start;
- (void)cancel;

- (void)loadNext;
- (NSUInteger)nextBookmarkIndex;

- (NSString *)title;
- (void)setTitle:(NSString *)aString;

- (NSImage *)currentIconImage;
- (void)setCurrentIconImage:(NSImage *)anImage forURL:(NSString *)aURLString;

- (void)applyWebIconImagesToItems;

- (id <ATWebIconLoaderDelegate> )delegate;
- (void)setDelegate:(id <ATWebIconLoaderDelegate> )aDelegate;

@end
