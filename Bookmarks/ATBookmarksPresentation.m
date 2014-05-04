//
//  ATBookmarksPresentaion.m
//  ATBookmarks
//
//  Created by 明史 on 05/10/12.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ATBookmarksPresentation.h"
#import "ATBookmarks.h"
#import "ATBinderPath.h"
#import "ATEditor.h"
#import "ATItem.h"
#import "ATBinder.h"
#import "ATBookmarksItemsArchiver.h"
#import <Carbon/Carbon.h>
#import "ATSelectionInBinder.h"
#import "ATBookmarksInsertOperation.h"
#import "ATBookmarksMoveOperation.h"
#import "ATBookmarksRemoveOperation.h"
#import "ATItemWrapper.h"
#import "ATBinderWrapper.h"
#import "ATBookmarksEnumerator.h"

NSString *ATBookmarksPresentationSelectionDidChangeNotification = @"ATBookmarksPresentationSelectionDidChangeNotification";
NSString *ATBookmarksPresentationDidChangeNotification = @"ATBookmarksPresentationDidChangeNotification";

@implementation ATBookmarksPresentation

- (id)init
{
	return [self initWithBookmarks:nil];
}

- (id)initWithBookmarks:(ATBookmarks *)aBookmarks
{
	[super init];
	
	[self setBookmarks:aBookmarks];

	return self;
}

- (void)dealloc
{
	NSLog(@"ATBookmarksPresentaion #dealloc");

    [self setBinderWrappers:nil];
	[self setBookmarks:nil];
	[self setRoot:nil];
	[self setPresentationID:nil];
	
	[super dealloc];
}

@end

@implementation ATBookmarksPresentation (Coding)

+ (BOOL)automaticallyEstablishCharacter
{
	return YES;
}

+ (void)defineCharacter:(NUCharacter *)aCharacter on:(NUPlayLot *)aPlayLot
{
	[aCharacter addOOPIvarWithName:@"presentationID"];
    [aCharacter addOOPIvarWithName:@"bookmarks"];
	[aCharacter addOOPIvarWithName:@"root"];
    [aCharacter addOOPIvarWithName:@"selectionForBinders"];
}

- (void)encodeWithAliaser:(NUAliaser *)aChildminder
{
    [aChildminder encodeObject:presentationID];
    [aChildminder encodeObject:bookmarks];
    [aChildminder encodeObject:root];
    [aChildminder encodeObject:binderWrappers];
}

- (id)initWithAliaser:(NUAliaser *)aChildminder
{
    [super init];
    
    NUSetIvar(&presentationID, [aChildminder decodeObject]);
//    NUSetIvar(&bookmarks, [aChildminder decodeObjectReally]);
    [self setBookmarks:[aChildminder decodeObject]];
//    NUSetIvar(&root, [aChildminder decodeObject]);
    [self setRoot:[aChildminder decodeObjectReally]];
    NUSetIvar(&binderWrappers, [aChildminder decodeObject]);
    
    return self;
}

- (NUBell *)bell
{
    return bell;
}

- (void)setBell:(NUBell *)anOOP
{
    bell = anOOP;
}

@end

@implementation ATBookmarksPresentation (Accessing)

- (void)setPresentationID:(NSNumber *)aNumber
{
    NUSetIvar(&presentationID, aNumber);
}

- (NSNumber *)presentationID
{
    return NUGetIvar(&presentationID);
}

- (void)setBookmarks:(ATBookmarks *)aBookmarks
{	
    if (bookmarks == aBookmarks) return;

    if (bookmarks && ![bookmarks isBell])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidInsertNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidMoveNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidMoveOrInsertNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidRemoveNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidChangeNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidOpenFolderNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidCloseFolderNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksWillEditItemNotification object:bookmarks];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ATBookmarksDidEditItemNotification object:bookmarks];
    }
    
    if (aBookmarks && ![aBookmarks isBell])
    {
        [self setRoot:[aBookmarks root]];
        [self setCountOfItems:[aBookmarks count]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksItemsDidInsert:) name:ATBookmarksDidInsertNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksItemsDidMove:) name:ATBookmarksDidMoveNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksItemsDidRemove:) name:ATBookmarksDidRemoveNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksDidChange:) name:ATBookmarksDidChangeNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksFolderDidOpenOrClose:) name:ATBookmarksDidOpenFolderNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksFolderDidOpenOrClose:) name:ATBookmarksDidCloseFolderNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksWillOrDidEditItem:) name:ATBookmarksWillEditItemNotification object:aBookmarks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookmarksWillOrDidEditItem:) name:ATBookmarksDidEditItemNotification object:aBookmarks];
    }
    
    [bookmarks autorelease];
    bookmarks = [aBookmarks retain];
}

- (ATBookmarks *)bookmarks
{
    if ([bookmarks isBell]) [self setBookmarks:[(NUBell *)bookmarks object]];
    
	return bookmarks;
}

- (ATBinder *)root
{    
	if (root)
		return root;
	else
		return [[self bookmarks] root];
}

- (void)setRoot:(ATBinder *)aRoot
{
	[root release];
	root = [aRoot retain];
    [self setBinderWrappers:[NSMutableArray array]];
    if (aRoot) [self addBinderWrapper:[ATBinderWrapper itemWrapperWithItem:aRoot]];
}

- (NSArray *)selections
{
//    NSIndexSet *aSelectionIndexes = [self selectionIndexesInColumn:[self lastColumn]];
//    return aSelectionIndexes ? [[self binderAt:[self lastColumn]] atIndexes:aSelectionIndexes] : [NSArray array];
    NSIndexSet *aSelectionIndexes = [self selectionIndexesInSelectedColumn];
    
    if ([aSelectionIndexes count])
        return [[self selectedBinder] atIndexes:aSelectionIndexes];
    else
        return [NSArray arrayWithObject:[self selectedBinder]];
}

- (NSArray *)selectedItems
{
	return [self selections];
}

- (NSArray *)selectedBookmarks
{
    NSArray *aSelectedItems = [self selectedItems];
    
    if ([aSelectedItems count] == 1 && [[aSelectedItems lastObject] isFolder])
        aSelectedItems = [[aSelectedItems lastObject] children];
    
    NSMutableArray *aSelectedBookmarks = [NSMutableArray array];
    
    [aSelectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isBookmark]) [aSelectedBookmarks addObject:obj];
    }];
    
    return aSelectedBookmarks;
}

- (NSArray *)selectionIndexPaths
{
	return [self bookmarks] ? [[self bookmarks] indexPathsFrom:[self selections]] : [NSArray array];
}

- (void)setSelectionIndexPaths:(NSArray *)anIndexPaths
{
	[self setSelections:[[self bookmarks] itemsBy:anIndexPaths]];
}

- (NSIndexSet *)selectionIndexes
{
    return [self selectionIndexesInColumn:[self lastColumn]];
}

- (NSIndexSet *)selectionIndexesInSelectedColumn
{
    return [self selectionIndexesInColumn:[self selectedColumn]];
}

- (NSUInteger)countOfItems
{
	return countOfItems;
}

- (void)setCountOfItems:(NSUInteger)aCount
{
	countOfItems = aCount;
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *aMenu = [[[NSMenu alloc] initWithTitle:@"bookmarkMenu"] autorelease];
	
	[aMenu insertItemWithTitle:NSLocalizedString(@"Open Bookmarks Of Selected Folder", nil) action:@selector(openItemsInSelectedFolder:) keyEquivalent:@"" atIndex:0];
	[aMenu insertItemWithTitle:NSLocalizedString(@"Open Selected Bookmarks", nil) action:@selector(openSelectedItemsWithoutFolders:) keyEquivalent:@"" atIndex:1];
	[aMenu insertItemWithTitle:NSLocalizedString(@"Open Selected Bookmarks With New Tabs", nil) action:@selector(openSelectedItemsWithoutFoldersWithNewTabs:) keyEquivalent:@"" atIndex:2];
	
	return aMenu;
}

@end

@implementation ATBookmarksPresentation (Opening)

- (NSArray *)arrayWithURLsOfSelectedBookmarkItems
{
	return [self arrayWithURLsOf:[self selectedBookmarks]];
}

- (NSArray *)arrayWithURLsOf:(NSArray *)anItems
{
	NSEnumerator *anEnumeratorOfSelectedItems = [anItems objectEnumerator];
	ATItem *anItem = nil;
	NSMutableArray *aURLs = [NSMutableArray array];
	
	while (anItem = [anEnumeratorOfSelectedItems nextObject])
	{
		if ([anItem isBookmark] && [anItem url])
			[aURLs addObject:[anItem url]];
	}
	
	return aURLs;
}

- (void)open:(id)anItem
{
    if (!anItem) return;
    
	if ([anItem isFolder])
		;
	else if ([anItem isBookmark] && [anItem url])
		[self openURLsIn:[self arrayWithURLsOf:[NSArray arrayWithObject:anItem]]];//[self runAppleScriptNamed:@"openURLInSafari" handlerName:@"openURLInSafari" argment:[NSAppleEventDescriptor descriptorWithString:[anItem urlString]]];
}

- (BOOL)openItemsInSelectedFolder
{
    return [self openURLsIn:[self arrayWithURLsOf:[[self selectedBinder] children]]];
}

- (BOOL)openURLsIn:(NSArray *)aURLs
{
	return [self openURLsIn:aURLs withNewTabs:NO];
}

- (BOOL)openURLsIn:(NSArray *)aURLs withNewTabs:(BOOL)aNewTabFlag
{
	int i = 0;
	NSAppleEventDescriptor *aListOfURL = [NSAppleEventDescriptor listDescriptor];

	for (; i < [aURLs count] ; i++)
	{
		[aListOfURL insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[[aURLs objectAtIndex:i] absoluteString]] atIndex:i + 1];
	}
	
	[self runAppleScriptNamed:@"openURLsInSafari" handlerName:(aNewTabFlag ? @"openURLsInSafariWithNewTabs" : @"openURLsInSafari") argment:aListOfURL];
	
	return YES;
}

@end

@implementation ATBookmarksPresentation (Testing)

- (BOOL)canCopy
{
	return [self currentSelectionIsNotRoot];
}

- (BOOL)canCut
{
	return [self currentSelectionIsNotRoot];
}

- (BOOL)canPaste
{
	return [[self bookmarks] canPaste];
}

- (BOOL)canDelete
{
	return [self currentSelectionIsNotRoot];
}

- (BOOL)currentSelectionIsRoot
{
    return [self selectedColumn] == 0 && [[self selectionIndexesInSelectedColumn] count] == 0;
}

- (BOOL)currentSelectionIsNotRoot
{
    return ![self currentSelectionIsRoot];
}

- (BOOL)inMakeNewItem
{
	return inMakeNewItem;
}

- (BOOL)isInDragging
{
    return countOfDraggingEntered > 0;
}

- (BOOL)anyBookmarkWithURLIsSelected
{
	NSEnumerator *aSelectionEnumerator = [[self selections] objectEnumerator];
	ATItem *anItem = nil;
	BOOL anAnyBookmarkWithURLIsSelected = NO;
	
	while (!anAnyBookmarkWithURLIsSelected && (anItem = [aSelectionEnumerator nextObject]))
	{
		if ([anItem isBookmark] && [anItem url])
			anAnyBookmarkWithURLIsSelected = YES;
	}
	
	return anAnyBookmarkWithURLIsSelected;
}

- (BOOL)canOpenSelectedBinder
{
	if ([[self selections] count] == 1)
	{
		ATItem *anItem = [[self selections] lastObject];

		return anItem && [anItem isFolder];
	}
	
	return NO;
}

- (BOOL)binderIsRoot:(ATBinder *)aBinder
{
    return [[self binderAt:0] isEqual:aBinder];
}

- (BOOL)lastBinderIsRoot
{
    return [self binderIsRoot:[self lastBinder]];
}

- (BOOL)lastBinderHasSelection
{
    return [[self selectionIndexesInColumn:[self lastColumn]] count] ? YES : NO;
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)aMenuItem
{
	SEL anAction = [aMenuItem action];
	
	if (anAction == @selector(copy:))
			return [self canCopy];
	else if (anAction == @selector(cut:))
			return [self canCut];
	else if (anAction == @selector(paste:))
			return [self canPaste];
	else if (anAction == @selector(delete:))
			return [self canDelete];
    else if (anAction == @selector(logItemIDOfSelections:))
        return YES;
    else if (anAction == @selector(logDuplicativeItemIDs:))
        return YES;
    else if (anAction == @selector(restAllItemIDs:))
        return YES;
	else if (anAction == @selector(logSelections:))
			return YES;
	else if (anAction == @selector(openItemsInSelectedFolder:))
		return YES;
	else if ((anAction == @selector(openSelectedItemsWithoutFolders:)) || (anAction == @selector(openSelectedItemsWithoutFoldersWithNewTabs:)))
		return [self anyBookmarkWithURLIsSelected];
	else
		return NO;
}

@end

@implementation ATBookmarksPresentation (Actions)

- (IBAction)copy:(id)sender
{
	[self copySelections];
}

- (IBAction)cut:(id)sender
{
	[self cutSelections];
}

- (IBAction)paste:(id)sender
{
	[self paste];
}

- (IBAction)delete:(id)sender
{
	[self removeSelections];
}

- (IBAction)openItemsInSelectedFolder:(id)sender
{
	[self openItemsInSelectedFolder];
}

- (IBAction)openSelectedItemsWithoutFolders:(id)sender
{
	if ([[self selections] count] == 1 && [[[self selections] lastObject] isBookmark])
		[self open:[[self selections] lastObject]];
	else
		[self openURLsIn:[self arrayWithURLsOfSelectedBookmarkItems]];
}

- (IBAction)openSelectedItemsWithoutFoldersWithNewTabs:(id)sender
{
	[self openURLsIn:[self arrayWithURLsOfSelectedBookmarkItems] withNewTabs:YES];
}

- (void)runAppleScriptNamed:(NSString *)aScriptName handlerName:(NSString *)aHandlerName argment:(NSAppleEventDescriptor *)anArgment
{
	NSAppleEventDescriptor *anArgments = [NSAppleEventDescriptor listDescriptor];
    
	[anArgments insertDescriptor:anArgment atIndex:1];
	[self runAppleScriptNamed:aScriptName handlerName:aHandlerName argments:anArgments];
}

- (void)runAppleScriptNamed:(NSString *)aScriptName handlerName:(NSString *)aHandlerName argments:(NSAppleEventDescriptor *)anArgments
{
	NSString *aPath = [[NSBundle mainBundle] pathForResource:aScriptName ofType:@"scpt"];
	
    if (aPath != nil)
    {
        NSURL *aUrl = [NSURL fileURLWithPath:aPath];
		
        if (aUrl != nil)
        {
            NSDictionary *anErrors = nil;
            NSAppleScript *anAppleScript = [[NSAppleScript alloc] initWithContentsOfURL:aUrl error:&anErrors];
			
            if (anAppleScript != nil)
            {
                ProcessSerialNumber psn = {0, kCurrentProcess};
                NSAppleEventDescriptor *aTarget = [NSAppleEventDescriptor  descriptorWithDescriptorType:typeProcessSerialNumber bytes:&psn length:sizeof(ProcessSerialNumber)];
				
				NSAppleEventDescriptor *aHandler = [NSAppleEventDescriptor descriptorWithString:[aHandlerName lowercaseString]];
				
                NSAppleEventDescriptor *anEvent = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
															 eventID:kASSubroutineEvent
													targetDescriptor:aTarget
															returnID:kAutoGenerateReturnID
													   transactionID:kAnyTransactionID];
                [anEvent setParamDescriptor:aHandler forKeyword:keyASSubroutineName];
                [anEvent setParamDescriptor:anArgments forKeyword:keyDirectObject];
				
                if (![anAppleScript executeAppleEvent:anEvent error:&anErrors])
                {
					NSLog([anErrors description]);
                }
				
                [anAppleScript release];
            }
        }
    }
}

@end

@implementation ATBookmarksPresentation (Editing)

- (void)beginMakingNewItem:(ATEditor *)anEditor
{
	inMakeNewItem = YES;
}

- (void)endMakingNewItem:(ATEditor *)anEditor
{
	inMakeNewItem = NO;
}

- (NSArray *)editorsForSelections
{
    NSMutableArray *anEditors = [NSMutableArray array];
    [[self selections] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [anEditors addObject:[ATEditor editorFor:obj on:self]];
    }];
    return anEditors;
}

- (void)accept:(id)anOriginalItem edited:(NSDictionary *)aValue
{
	if ([anOriginalItem hasItemID])
		[[self bookmarks] change:anOriginalItem with:aValue];
	else
	{
		[anOriginalItem acceptEdited:aValue];
		[self add:anOriginalItem];
	}
}

@end

@implementation ATBookmarksPresentation (Modifying)

- (void)copySelections
{
    NSIndexSet *aSelectionIndexes = nil;
    ATBinder *aBinder = nil;
    
    [self getSelectionIndexesInto:&aSelectionIndexes binderInto:&aBinder];
    
    if (aBinder)
        [[self bookmarks] copy:aSelectionIndexes of:aBinder];
}

- (void)cutSelections
{
    NSIndexSet *aSelectionIndexes = nil;
    ATBinder *aBinder = nil;
    
    [self getSelectionIndexesInto:&aSelectionIndexes binderInto:&aBinder];
    
    if (aBinder)
        [[self bookmarks] cut:aSelectionIndexes of:aBinder];
}

- (void)paste
{
	ATBinder *aDestination = nil;
	unsigned anIndex = 0;
	
	[self preferredInsertDestination:&aDestination index:&anIndex];
	[[self bookmarks] pasteTo:aDestination at:anIndex contextInfo:[self presentationID]];
}

- (void)add:(id)anItem
{
	[self addItems:[NSArray arrayWithObject:anItem]];
}

- (void)addItems:(NSArray *)anItems
{
	ATBinder *aDestination = nil;
	unsigned anIndex = 0;
	
	[self preferredInsertDestination:&aDestination index:&anIndex];
	
    [[self bookmarks] insertItems:anItems to:anIndex of:aDestination contextInfo:[self presentationID]];
}

- (void)preferredInsertDestination:(ATBinder **)aDestinationBinder index:(unsigned *)anIndex
{
	if (![[self selections] count] || [[self selections] count] > 1)
	{
		*aDestinationBinder = [self lastBinder];
		*anIndex = [*aDestinationBinder count];
	}
	else
	{
		ATItem *aSelectedItem = [[self selections] objectAtIndex:0];
			
		if ([aSelectedItem isFolder])
		{
			*aDestinationBinder = aSelectedItem;
			*anIndex = [aSelectedItem count];
		}
		else
		{
			ATBinder *aSelectedBinder = [self selectedBinder];
			*aDestinationBinder = aSelectedBinder;
			*anIndex = [[self selectionIndexes] lastIndex] + 1;
		}
	}
}

- (void)removeSelections
{
    NSIndexSet *aSelectionIndexes = nil;
    ATBinder *aBinder = nil;
    
    [self getSelectionIndexesInto:&aSelectionIndexes binderInto:&aBinder];
    
    if (aBinder)
        [[self bookmarks] removeItemsAtIndexes:aSelectionIndexes from:aBinder contextInfo:[self presentationID]];
}

@end

@implementation ATBookmarksPresentation (BookmarksNotifications)

- (void)bookmarksItemsDidInsert:(NSNotification *)aNotification
{	
    ATBookmarksInsertOperation *anInsertOperation = [[aNotification userInfo] objectForKey:@"operation"];
    [self updateWithInsertOperation:anInsertOperation];
    [self discardBinderWrappersForDragging];
	//[[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self userInfo:[aNotification userInfo]];
}

- (void)bookmarksItemsDidMove:(NSNotification *)aNotification
{
	ATBookmarksMoveOperation *aMoveOperation = [[aNotification userInfo] objectForKey:@"operation"];
    [self updateWithMoveOperation:aMoveOperation];
    [self discardBinderWrappersForDragging];
    
    /*if ([self notificationIsEnabled])
        [[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self userInfo:[aNotification userInfo]];*/
}

- (void)bookmarksItemsDidRemove:(NSNotification *)aNotification
{	
    ATBookmarksRemoveOperation *anOperation = [[aNotification userInfo] objectForKey:@"operation"];
    [self updateWithRemoveOperation:anOperation];
    
	//[[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self userInfo:[aNotification userInfo]];
}

- (void)bookmarksFolderDidOpenOrClose:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self userInfo:[aNotification userInfo]];
}

- (void)bookmarksWillOrDidEditItem:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self userInfo:[aNotification userInfo]];
}

- (void)bookmarksDidChange:(NSNotification *)aNotification
{
    //[self postDidChangeNotification:NO];
    [self delayedPostDidChangeNotification:NO];
	
	[self setCountOfItems:[[self bookmarks] count]];
}

- (void)delayedPostDidChangeNotification:(BOOL)aRootChanged
{
    [self performSelector:@selector(postDidChangeNotification:) withObject:aRootChanged afterDelay:0.03];
}

@end

//@implementation ATBookmarksPresentation (OutlineViewDataSouce)
//
//- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
//{
//	if (!item)
//		return [[self root] at:index];
//	else
//		return [item at:index];
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
//{
//	return [item isFolder];
//}
//
//- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
//{
//	if (!item)
//		return [[self root] count];
//	else	
//		return [item count];
//}
//
//- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
//{
//	if ([item isFolder] && [[tableColumn identifier] isEqualToString:@"urlString"])
//		return @"";
//	else if ([[tableColumn identifier] isEqualToString:@"name"])
//	{
//		NSCell *cell = [tableColumn dataCell];
//		
//		if ([item isBookmark] && [item icon])
//			[cell setImage:[item icon]];
//		else
//			[cell setImage:nil];
//		
//		return [item name];
//	}
//	else if ([[tableColumn identifier] isEqualToString:@"lastVisitDate"] || [[tableColumn identifier] isEqualToString:@"lastModifiedDate"])
//	{
//		if ([item isBookmark])
//			return [item valueForKey:[tableColumn identifier]];
//		else
//			return @"";
//	}
//	else
//		return [item valueForKey:[tableColumn identifier]];
//}
//
//
//- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
//{
//	if (!([item isFolder] && [[tableColumn identifier] isEqual:@"urlString"]))
//	{
//		ATEditor *anEditor = [ATEditor editorFor:item on:self];
//
//		[[anEditor value] setObject:([object isEqual:@""] ? [NSNull null] : object) forKey:[tableColumn identifier]];
//
//		[anEditor acceptIfValid];
//	}
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpanded:(id)aFolder
//{
//	return [aFolder isOpen];
//}
//
//- (void)outlineView:(NSOutlineView *)outlineView openFolder:(ATBinder *)aFolder recursive:(BOOL)aRecursiveFlag
//{
//	[[self bookmarks] openFolder:aFolder recursive:aRecursiveFlag];
//}
//
//- (void)outlineView:(NSOutlineView *)outlineView closeFolder:(ATBinder *)aFolder recursive:(BOOL)aRecursiveFlag
//{
//	[[self bookmarks] closeFolder:aFolder recursive:aRecursiveFlag];
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
//{
//	return [[self bookmarks] writeDraggingItems:[[self bookmarks] topLevelItemsIn:items] to:pboard];
//}
//
//- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index
//{
//	//[self logDraggingSourceOperationMask:info];
//	
//	if (index == NSOutlineViewDropOnItemIndex)
//		return [[self bookmarks] validateDrop:info on:item];
//	else
//		return [[self bookmarks] validateDrop:info to:(item ? item : [self root]) at:index];
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index
//{
//	if (index == NSOutlineViewDropOnItemIndex)
//		return [[self bookmarks] acceptDrop:info on:item contextInfo:[self presentationID]];
//	else
//		return [[self bookmarks] acceptDrop:info to:(item ? item : [self root]) at:index contextInfo:[self presentationID]];
//}
//
//@end

@implementation ATBookmarksPresentation (BrowserDelegate)

@end

@implementation ATBookmarksPresentation (Browser)

- (void)setSelectionIndexes:(NSIndexSet *)aSelectionIndexes inColumn:(NSUInteger)aColumn
{
    //NSLog(@"#setSelectionIndexes:inColumn:");
    
    ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:aColumn];
    if ([aBinderWrapper selectedItemIsSingleBinder])
        [aBinderWrapper removeAllOfSelectedSingleBinder];
    [aBinderWrapper setSelectionIndexes:aSelectionIndexes];
    [aBinderWrapper setSelectionIsChanged:YES];
    [self removeBinderWrappersFromIndex:aColumn + 1];

    if ([aSelectionIndexes count] == 1)
    {
        ATItemWrapper *aSelectedItem = [aBinderWrapper itemAt:[aSelectionIndexes lastIndex]];
        
        if ([aSelectedItem isBinderWrapper])
            [self addBinderWrapper:(ATBinderWrapper *)aSelectedItem];
    }
    
    
    if ([self notificationIsEnabled])
        [self postDidChangeNotification:NO];
}

- (void)changeLastColumn:(NSInteger)anOldLastColumn toColumn:(NSInteger)aColumn
{
    if (aColumn < anOldLastColumn)
    {
        ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:aColumn];
        if ([aBinderWrapper selectedItemIsSingleBinder])
            [aBinderWrapper removeAllOfSelectedSingleBinder];
        [self removeBinderWrappersFromIndex:aColumn + 1];
    }
    
    if ([self notificationIsEnabled])
        [self delayedPostDidChangeNotification:NO];
//        [self postDidChangeNotification:NO];
}

- (NSIndexSet *)selectionIndexesInColumn:(NSUInteger)aColumn
{
    return [[self binderWrapperAt:aColumn] selectionIndexes];
}

- (void)browser:(id)sender draggingEntered:(id <NSDraggingInfo>)aDraggingInfo
{
    //NSLog(@"presentation #draggingEntered:");
    
    countOfDraggingEntered++;
    
    if (countOfDraggingEntered == 1)
        [self storeBinderWrappersForDragging];
}

- (void)browser:(id)sender draggingEnded:(id <NSDraggingInfo>)aDraggingInfo
{
    //NSLog(@"presentation #draggingEnded:");
    
    countOfDraggingEntered--;
    
    if (countOfDraggingEntered != 0) return;
    
    [self enableNotification];

    if (binderWrappersBeforeDragging)
    {
        [self restoreBinderWrappersForDragging];
        [self postDidChangeNotification:YES];
    }
    else
        [self postDidChangeNotification:NO];
}

- (BOOL)acceptDrop:(id <NSDraggingInfo>)anInfo on:(id)anItem contextInfo:(id)aContextInfo
{
    return [self acceptDrop:anInfo to:anItem at:[anItem count] contextInfo:aContextInfo];
}

- (BOOL)acceptDrop:(id <NSDraggingInfo>)anInfo to:(id)anItem at:(NSUInteger)anIndex contextInfo:(id)aContextInfo
{
    BOOL anAccepted;
    
    [self disableNotification];
    
    anAccepted = [[self bookmarks] acceptDrop:anInfo to:anItem at:anIndex contextInfo:aContextInfo];
    
//    [self enableNotification];
    
    /*if (anAccepted && [self notificationIsEnabled])
        [self performSelector:@selector(postDidChangeNotification) withObject:nil afterDelay:0.03];*/
        //[[NSNotificationCenter defaultCenter] postNotificationName:ATBookmarksPresentationDidChangeNotification object:self];
    
//    if (anAccepted)
//    {
//        [binderWrappersBeforeDragging release];
//        binderWrappersBeforeDragging = nil;
//    }
    
    return anAccepted;
}

- (void)postDidChangeNotification:(BOOL)aRootChanged
{
    if (![self notificationIsEnabled]) return;
    
//    NSLog(@"postDidChangeNotification:");
//    NSLog(@"%@", [NSThread callStackSymbols]);
    
    NSDictionary *aUserInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:aRootChanged] forKey:@"RootChangedKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:ATBookmarksPresentationDidChangeNotification object:self userInfo:aUserInfo];
    [self discardBinderWrapperChangeInfo];
}

- (NSInteger)lastColumn
{
    return [self binderCount] - 1;
}

- (NSInteger)selectedColumn
{
    return [self lastColumn];
}

- (void)setSelectedColumn:(NSInteger)aColumn
{
    selectedColumn = aColumn;
    if (aColumn + 1 < [self binderCount])
        [self setSelectionIndexes:[NSIndexSet indexSet] inColumn:aColumn + 1];
}

- (void)getSelectionIndexesInto:(NSIndexSet **)aSelectionIndexes binderInto:(ATBinder **)aBinder
{    
    if ([self lastBinderHasSelection])
    {
        *aSelectionIndexes = [self selectionIndexesInSelectedColumn];
        *aBinder = [self selectedBinder];
    }
    else if (![self lastBinderIsRoot])
    {
        *aSelectionIndexes = [self selectionIndexesInColumn:[self lastColumn] - 1];
        *aBinder = [self binderAt:[self lastColumn] - 1];
    }
}

- (NSUInteger)binderCount
{
    return [[self binderWrappers] count];
}

- (ATBinder *)binderAt:(NSUInteger)anIndex
{
    return [[self binderWrapperAt:anIndex] binder];
}


- (NSUInteger)itemCountOf:(ATBinderWrapper *)aBinderWrapper
{
//    NSLog(@"#itemCountOf:");
    
    NSUInteger anIndexOfBinderWrapper = [self indexOfBinderWrapper:aBinderWrapper];
    
    if (anIndexOfBinderWrapper == NSNotFound)
    {
        ATBinderWrapper *aPreviousBinderWrapper = [self binderWrapperAt:[self lastColumn]];
        NSUInteger aBinderWrapperIndex = [aPreviousBinderWrapper indexOf:aBinderWrapper];
        NSIndexSet *aBinderWrapperIndexSet = [NSIndexSet indexSetWithIndex:aBinderWrapperIndex];
        if (![[aPreviousBinderWrapper selectionIndexes] isEqualToIndexSet:aBinderWrapperIndexSet])
        {
            if ([aPreviousBinderWrapper selectedItemIsSingleBinder])
                [aPreviousBinderWrapper removeAllOfSelectedSingleBinder];
            [aPreviousBinderWrapper setSelectionIndexes:aBinderWrapperIndexSet];
        }
        [self addBinderWrapper:aBinderWrapper];
    }
    
    return [aBinderWrapper count];
}

- (ATItemWrapper *)itemWrapperAt:(NSUInteger)anIndex ofBinderWrapper:(ATBinderWrapper *)aBinderWrapper
{
    //NSLog(@"itemWrapperAt:%lu ofBinderWrapper:", anIndex);
    return anIndex < [aBinderWrapper count] ? [aBinderWrapper itemAt:anIndex] : nil;
}

- (NSInteger)firstColumnForBinder:(ATBinder *)aBinder
{
    NSUInteger i = 0;
    
    for (; i < [self binderCount]; i++)
        if ([[self binderAt:i] isEqual:aBinder]) return i;

    return NSNotFound;
}

- (ATBinder *)lastBinder
{
    return [self binderAt:[self lastColumn]];
}
 
- (ATBinder *)selectedBinder
{
    return [self binderAt:[self selectedColumn]];
}

@end

@implementation ATBookmarksPresentation (Private)

- (NSMutableArray *)binderWrappers
{
    return NUGetIvar(&binderWrappers);
}

- (void)setBinderWrappers:(NSMutableArray *)aBinderWrappers
{
    NUSetIvar(&binderWrappers, aBinderWrappers);
}

- (void)removeBinderWrappersFromIndex:(NSUInteger)aColumn
{
//    NSLog(@"removeBinderWrappersFromIndex:%lu", aColumn);
    
    if (aColumn >= [self binderCount]) return;
    
    [[self binderWrappers] removeObjectsInRange:NSMakeRange(aColumn, [self binderCount] - aColumn)];
    
    [[[self bell] playLot] markChangedObject:[self binderWrappers]];
}

- (void)addBinderWrapper:(ATBinderWrapper *)aBinderWrapper
{
    NSLog(@"addBinderWrapper:%@", aBinderWrapper);
    if ([self binderCount] == 1)
        NSLog(@"");
    
    [[self binderWrappers] addObject:aBinderWrapper];
//    [aBinderWrapper setItemsIsChanged:YES];
    
    [[[self bell] playLot] markChangedObject:[self binderWrappers]];
}

- (void)reloadItemsAt:(NSUInteger)aColumn
{
    [[self binderWrapperAt:aColumn] reloadAll];
}

- (ATBinderWrapper *)binderWrapperAt:(NSUInteger)aColumn
{
    return [[self binderWrappers] objectAtIndex:aColumn];
}

- (NSUInteger)indexOfBinderWrapper:(ATBinderWrapper *)aBinderWrapper
{
    return [[self binderWrappers] indexOfObject:aBinderWrapper];
}

- (void)storeBinderWrappersForDragging
{
    [self setBinderWrappersForDragging:[self copyBinderWrappers]];
}

- (void)restoreBinderWrappersForDragging
{
    [self setBinderWrappers:binderWrappersBeforeDragging];
    [self setBinderWrappersForDragging:nil];
    [[[self bell] playLot] markChangedObject:self];
}

- (void)discardBinderWrappersForDragging
{
    [self setBinderWrappersForDragging:nil];
}

- (void)setBinderWrappersForDragging:(NSMutableArray *)aBinderWrappers
{
    [binderWrappersBeforeDragging autorelease];
    binderWrappersBeforeDragging = [aBinderWrappers retain];
}

- (NSMutableArray *)copyBinderWrappers
{
    NSMutableArray *aCopiedBinderWrappers = [NSMutableArray new];
    [aCopiedBinderWrappers addObject:[[[self binderWrapperAt:0] copy] autorelease]];
    
    while ([[aCopiedBinderWrappers lastObject] isBinderWrapper]
           && [[aCopiedBinderWrappers lastObject] selectedItemIsSingleBinder])
    {
        [aCopiedBinderWrappers addObject:[[[aCopiedBinderWrappers lastObject] selectedItems] lastObject]];
    }
            
    return aCopiedBinderWrappers;
}

- (NSIndexSet *)computeNewSelectionWithCurrentSelection:(NSIndexSet *)aCurrentSelectionIndexes removedSelection:(NSIndexSet *)aRemovedSelectionIndexes
{
    NSMutableIndexSet *aNewSelectionIndexes = [NSMutableIndexSet indexSet];
    
    [aCurrentSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger anIndex, BOOL *aStop) {
        if (![aRemovedSelectionIndexes containsIndex:anIndex])
            [aNewSelectionIndexes addIndex:anIndex
                - [aRemovedSelectionIndexes countOfIndexesInRange:NSMakeRange(0, anIndex)]];
    }];
    
    return aNewSelectionIndexes;
}


- (void)disableNotification
{
    disableCountOfNotification++;
}

- (void)enableNotification
{
    disableCountOfNotification--;
}

- (BOOL)notificationIsEnabled
{
    return disableCountOfNotification == 0;
}

- (void)getUpperBinderIndex:(NSInteger *)anUpperBinderIndex lowerBinderIndex:(NSInteger *)aLowerBinderIndex fromBinderIndex1:(NSInteger)aBinderIndex1 binderIndex2:(NSInteger)aBinderIndex2
{
    if (aBinderIndex1 == NSNotFound && aBinderIndex2 == NSNotFound)
    {
        *anUpperBinderIndex = NSNotFound;
        *aLowerBinderIndex = NSNotFound;
    }
    else if (aBinderIndex1 != NSNotFound && aBinderIndex2 != NSNotFound)
    {
        if (aBinderIndex1 <= aBinderIndex2)
        {
            *anUpperBinderIndex = aBinderIndex1;
            *aLowerBinderIndex = aBinderIndex2;
        }
        else
        {
            *anUpperBinderIndex = aBinderIndex2;
            *aLowerBinderIndex = aBinderIndex1;
        }
    }
    else
    {
        if (aBinderIndex1 != NSNotFound)
        {
            *anUpperBinderIndex = aBinderIndex1;
            *aLowerBinderIndex = NSNotFound;
        }
        else
        {
            *anUpperBinderIndex = aBinderIndex2;
            *aLowerBinderIndex = NSNotFound;
        }
    }
}

- (void)updateWithInsertOperation:(ATBookmarksInsertOperation *)anInsertOperation
{
    NSArray *anOldSelectedItems = nil;
    NSArray *anInsertWrappers = nil;
    NSInteger aLastDestinationBinderIndex = NSNotFound;
    
    for (NSInteger i = 0; i < [self binderCount]; i++)
    {
        ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:i];
        
        if ([[aBinderWrapper binder] isEqual:[anInsertOperation binder]])
        {
            anInsertWrappers = [ATItemWrapper wrappersFrom:[anInsertOperation items]];
            anOldSelectedItems = [aBinderWrapper selectedItems];
            aLastDestinationBinderIndex = i;
            [aBinderWrapper insertItems:anInsertWrappers at:[anInsertOperation indexes]];
            [aBinderWrapper setSelectedItems:anOldSelectedItems];
        }
    }
    
    if (aLastDestinationBinderIndex == NSNotFound) return;
    
    ATBinderWrapper *aLastDestinationBinderWrapper = [self binderWrapperAt:aLastDestinationBinderIndex];
    [aLastDestinationBinderWrapper setSelectedItems:anInsertWrappers];
    if ([aLastDestinationBinderWrapper itemIsSingleBinder:anOldSelectedItems])
    {
        [[anOldSelectedItems lastObject] removeAll];
        [self removeBinderWrappersFromIndex:aLastDestinationBinderIndex + 1];
        
        if ([aLastDestinationBinderWrapper itemIsSingleBinder:anInsertWrappers])
            [self addBinderWrapper:[anInsertWrappers lastObject]];
    }
}

- (void)updateWithMoveOperation:(ATBookmarksMoveOperation *)aMoveOperation
{    
    if ([[aMoveOperation sourceBinder] isEqual:[aMoveOperation destinationBinder]])
        [self updateWithSameBinderMoveOperation:aMoveOperation];
    else
        [self updateWithDifferentBinderMoveOperation:aMoveOperation];
}

- (void)updateWithSameBinderMoveOperation:(ATBookmarksMoveOperation *)aMoveOperation
{
    ATBinder *aBinder = [aMoveOperation sourceBinder];
    NSInteger aLastBinderIndex = NSNotFound;
    NSArray *aMoveItems = nil;
    NSArray *aSelectedItems = nil;
    
    for (NSInteger i = 0; i < [self binderCount]; i++)
    {
        ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:i];
        
        if ([[aBinderWrapper binder] isEqual:aBinder])
        {
            aLastBinderIndex = i;
            aSelectedItems = [aBinderWrapper selectedItems];
            aMoveItems = [aBinderWrapper itemsAt:[aMoveOperation sourceIndexes]];
            [aBinderWrapper removeAtIndexes:[aMoveOperation sourceIndexes]];
            [aBinderWrapper insertItems:aMoveItems at:[aMoveOperation destinationIndexes]];
            [aBinderWrapper setSelectedItems:aSelectedItems];
//            [aBinderWrapper setItemsIsChanged:YES];
//            [aBinderWrapper setSelectionIsChanged:YES];
        }
    }
    
    if (aLastBinderIndex == NSNotFound) return;
    
    ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:aLastBinderIndex];
    
    if ([aBinderWrapper itemIsSingleBinder:aMoveItems] && [aBinderWrapper itemIsEqualItemOf:[aMoveItems lastObject]])
        return;
    
    if (![aSelectedItems isEqual:aMoveItems])
    {
        if ([aBinderWrapper itemIsSingleBinder:aSelectedItems])
        {
            [aBinderWrapper removeAllOfSelectedSingleBinder];
            [self removeBinderWrappersFromIndex:aLastBinderIndex + 1];
        }
        
        if ([aBinderWrapper itemIsSingleBinder:aMoveItems])
            [self addBinderWrapper:[aMoveItems lastObject]];
        
        [aBinderWrapper setSelectedItems:aMoveItems];
//        [aBinderWrapper setSelectionIsChanged:YES];
    }
}

- (void)updateWithDifferentBinderMoveOperation:(ATBookmarksMoveOperation *)aMoveOperation
{
    ATBinder *aSourceBinder = [aMoveOperation sourceBinder];
    ATBinder *aDestinationBinder = [aMoveOperation destinationBinder];
    NSInteger aLastDestinationBinderIndex = NSNotFound;
    
    for (NSInteger i = 0; i < [self binderCount]; i++)
    {
        ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:i];
        
        if ([[aBinderWrapper binder] isEqual:aSourceBinder])
        {
            NSArray *aMoveItems = [aBinderWrapper itemsAt:[aMoveOperation sourceIndexes]];
            NSArray *anOldSelectedItems = [aBinderWrapper selectedItems];
            NSMutableArray *aNewSelectedItems = [[anOldSelectedItems mutableCopy] autorelease];
            
            [aNewSelectedItems removeObjectsInArray:aMoveItems];
            [aBinderWrapper removeAtIndexes:[aMoveOperation sourceIndexes]];
            [aBinderWrapper setSelectedItems:aNewSelectedItems];
//            [aBinderWrapper setItemsIsChanged:YES];
//            [aBinderWrapper setSelectionIsChanged:YES];
            
            if ([aBinderWrapper itemIsSingleBinder:anOldSelectedItems]
                && ![anOldSelectedItems isEqualToArray:aNewSelectedItems])
            {
                [[anOldSelectedItems lastObject] removeAll];
                [self removeBinderWrappersFromIndex:i + 1];
            }
            
            if (![anOldSelectedItems isEqualToArray:aNewSelectedItems]
                && [aBinderWrapper itemIsSingleBinder:aNewSelectedItems])
                [self addBinderWrapper:[aNewSelectedItems lastObject]];
        }
        else if ([[aBinderWrapper binder] isEqual:aDestinationBinder])
        {
            aLastDestinationBinderIndex = i;
            NSArray *aSelectedItems = [aBinderWrapper selectedItems];
            
            [aBinderWrapper insertItems:[ATItemWrapper wrappersFrom:[aMoveOperation items]] at:[aMoveOperation destinationIndexes]];
            [aBinderWrapper setSelectedItems:aSelectedItems];
//            [aBinderWrapper setItemsIsChanged:YES];
//            [aBinderWrapper setSelectionIsChanged:YES];
        }
    }
        
    if (aLastDestinationBinderIndex != NSNotFound && aLastDestinationBinderIndex < [self binderCount])
    {
        ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:aLastDestinationBinderIndex];
        NSArray *anOldSelectedItems = [aBinderWrapper selectedItems];
        NSArray *aNewSelectedItems = [aBinderWrapper itemsAt:[aMoveOperation destinationIndexes]];
        
        [aBinderWrapper setSelectedItems:aNewSelectedItems];
//        [aBinderWrapper setSelectionIsChanged:YES];
        
        if ([aBinderWrapper itemIsSingleBinder:anOldSelectedItems]
            && ![anOldSelectedItems isEqualToArray:aNewSelectedItems])
        {
            [[anOldSelectedItems lastObject] removeAll];
            [self removeBinderWrappersFromIndex:aLastDestinationBinderIndex + 1];
        }
        
        if (![anOldSelectedItems isEqualToArray:aNewSelectedItems]
            && [aBinderWrapper itemIsSingleBinder:aNewSelectedItems])
            [self addBinderWrapper:[aNewSelectedItems lastObject]];
    }
}

- (void)updateWithRemoveOperation:(ATBookmarksRemoveOperation *)aRemoveOperation
{    
    ATBinder *aBinder = [aRemoveOperation binder];
    
    for (NSInteger i = 0; i < [self binderCount]; i++)
    {
        ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:i];
        
        if ([[aBinderWrapper binder] isEqual:aBinder])
        {
            NSArray *anOldSelectedItems = [aBinderWrapper selectedItems];
            NSMutableArray *aNewSelectedItems = [[anOldSelectedItems mutableCopy] autorelease];
            
            [aNewSelectedItems removeObjectsInArray:[aBinderWrapper itemsAt:[aRemoveOperation indexes]]];
            
            if ([aBinderWrapper itemIsSingleBinder:anOldSelectedItems] && ![anOldSelectedItems isEqualToArray:aNewSelectedItems])
            {
                [[anOldSelectedItems lastObject] removeAll];
                [self removeBinderWrappersFromIndex:i + 1];
            }
            
            if ([aBinderWrapper itemIsSingleBinder:aNewSelectedItems] && [anOldSelectedItems isEqualToArray:aNewSelectedItems])
            {
                [self addBinderWrapper:[aNewSelectedItems lastObject]];
            }
            
            [aBinderWrapper removeAtIndexes:[aRemoveOperation indexes]];
            [aBinderWrapper setSelectedItems:aNewSelectedItems];
        }
    }
}

//- (void)updateWithMoveOperation:(ATBookmarksMoveOperation *)aMoveOperation binderIndex:(NSInteger)aBinderIndex
//{
//    ATBinderWrapper *aBinderWrapper = [self binderWrapperAt:aBinderIndex];
//    NSArray *aMoveItems = [aBinderWrapper itemsAt:[aMoveOperation sourceIndexes]];
//    NSArray *aSelectedItems = [aBinderWrapper selectedItems];
//    if ([aSelectedItems count] == 1 && [[aSelectedItems lastObject] isBinderWrapper])
//        [[aSelectedItems lastObject] removeAll];
//    [aBinderWrapper removeAtIndexes:[aMoveOperation sourceIndexes]];
//    [aBinderWrapper insertItems:aMoveItems at:[aMoveOperation destinationIndexes]];
//    [aBinderWrapper setSelectedItems:aMoveItems];
//}
//
//- (void)updateWithMoveOperation:(ATBookmarksMoveOperation *)aMoveOperation upperBinderIndex:(NSInteger)anUpperBinderIndex lowerBinderIndex:(NSInteger)aLowerBinderIndex
//{
//    ATBinderWrapper *anUpperBinderWrapper = [self binderWrapperAt:anUpperBinderIndex];
//    
//    if ([[anUpperBinderWrapper binder ] isEqual:[aMoveOperation sourceBinder]])
//    {
//        NSArray *aMoveItems = [anUpperBinderWrapper itemsAt:[aMoveOperation sourceIndexes]];
//        NSArray *anOldSelectedItems = [anUpperBinderWrapper selectedItems];
//        NSMutableArray *aNewSelectedItems = [[anOldSelectedItems mutableCopy] autorelease];
//        [aNewSelectedItems removeObjectsInArray:aMoveItems];
//        if ([anOldSelectedItems count] == 1 && [[anOldSelectedItems lastObject] isBinderWrapper]
//            && ![anOldSelectedItems isEqualToArray:aNewSelectedItems])
//            [[anOldSelectedItems lastObject] removeAll];
//        [anUpperBinderWrapper removeAtIndexes:[aMoveOperation sourceIndexes]];
//        [anUpperBinderWrapper setSelectedItems:aNewSelectedItems];
//        
//        if (aLowerBinderIndex != NSNotFound)
//        {
//            ATBinderWrapper *aDestinationBinderWrapper = [self binderWrapperAt:aLowerBinderIndex];
//            NSArray *aSelectedItemsInDestination = [aDestinationBinderWrapper selectedItems];
//            [aDestinationBinderWrapper insertItems:aMoveItems at:[aMoveOperation destinationIndexes]];
//            if ([aSelectedItemsInDestination count] == 1 && [[aSelectedItemsInDestination lastObject] isBinderWrapper])
//                [[aSelectedItemsInDestination lastObject] removeAll];
//            [aDestinationBinderWrapper setSelectedItems:aMoveItems];
//        }
//    }
//    else
//    {
//        NSArray *anOldSelectedItems = [anUpperBinderWrapper selectedItems];
//        
//        if (aLowerBinderIndex != NSNotFound)
//        {
//            ATBinderWrapper *aSourceBinderWrapper = [self binderWrapperAt:aLowerBinderIndex];
//            NSArray *aMoveItems = [aSourceBinderWrapper itemsAt:[aMoveOperation sourceIndexes]];
//            [aSourceBinderWrapper removeAtIndexes:[aMoveOperation sourceIndexes]];
//            if ([anOldSelectedItems count] == 1 && [[anOldSelectedItems lastObject] isBinderWrapper])
//                [[anOldSelectedItems lastObject] removeAll];
//            [anUpperBinderWrapper insertItems:aMoveItems at:[aMoveOperation destinationIndexes]];
//            [anUpperBinderWrapper setSelectedItems:aMoveItems];
//        }
//    }
//}

- (void)discardBinderWrapperChangeInfo
{
    [[self binderWrappers] enumerateObjectsUsingBlock:^(ATBinderWrapper *obj, NSUInteger idx, BOOL *stop) {
        [obj discardChangeInfo];
    }];
}

@end

@implementation ATBookmarksPresentation (Debugging)

- (IBAction)logItemIDOfSelections:(id)sender
{
    [[self selectedItems] enumerateObjectsUsingBlock:^(ATItem *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", [[obj numberWithItemID] description]);
    }];
}

- (IBAction)logDuplicativeItemIDs:(id)sender
{
    NSMutableSet *aDuplicativeItems = [NSMutableSet set];
    NSMutableDictionary *anItems = [NSMutableDictionary dictionary];
    ATBookmarksEnumerator *enumerator = [ATBookmarksEnumerator enumeratorWithBinder:[self root]];
    ATItem *anItem = nil;
    
    while (anItem = [enumerator nextObject])
    {
        ATItem *aVisitedItem = [anItems objectForKey:[anItem numberWithItemID]];
        if (aVisitedItem)
        {
            [aDuplicativeItems addObject:aVisitedItem];
            [aDuplicativeItems addObject:anItem];
        }
        else
            [anItems setObject:anItem forKey:[anItem numberWithItemID]];
    }
    
    NSLog(@"DuplicativeItems: %@", aDuplicativeItems);
}

- (IBAction)restAllItemIDs:(id)sender
{
    [[self bookmarks] resetAllItemIDs];
}

- (IBAction)logSelections:(id)sender
{
	NSString *aDesc = [[self selections] description];
	
	if (![self selections] || ![[self selections] count])
		NSLog(@"emptySelection");
	else
		NSLog(aDesc);
}

- (void)logDraggingSourceOperationMask:(id <NSDraggingInfo> )info
{
	if ([info draggingSourceOperationMask] & NSDragOperationCopy)
		NSLog(@"NSDragOperationCopy");
	if ([info draggingSourceOperationMask] & NSDragOperationLink)
		NSLog(@"NSDragOperationLink");
	if ([info draggingSourceOperationMask] & NSDragOperationGeneric)
		NSLog(@"NSDragOperationGeneric");
	if ([info draggingSourceOperationMask] & NSDragOperationPrivate)
		NSLog(@"NSDragOperationPrivate");
	if ([info draggingSourceOperationMask] & NSDragOperationMove)
		NSLog(@"NSDragOperationMove");
	if ([info draggingSourceOperationMask] & NSDragOperationDelete)
		NSLog(@"NSDragOperationDelete");
	if ([info draggingSourceOperationMask] & NSDragOperationEvery)
		NSLog(@"NSDragOperationEvery");
	if ([info draggingSourceOperationMask] & NSDragOperationNone)
		NSLog(@"NSDragOperationNone");
}

@end