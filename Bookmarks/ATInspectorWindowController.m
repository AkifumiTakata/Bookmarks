#import "ATInspectorWindowController.h"
#import "ATEditor.h"

@implementation ATInspectorWindowController (Initializing)

+ (id)bookmarkInspectorWith:(ATEditor *)anEditor
{
	return [[[self alloc] initWith:anEditor windowNibName:@"ATNewBookmarkWindow"] autorelease];
}

+ (id)folderInspectorWith:(ATEditor *)anEditor;
{
	return [[[self alloc] initWith:anEditor windowNibName:@"ATNewBinderWindow"] autorelease];
}

- (id)initWith:(ATEditor *)anEditor windowNibName:(NSString *)aName
{
	[super initWithWindowNibName:aName];
	
	[self window];
	
	[editorController setContent:anEditor];
	
	return self;
}

@end

@implementation ATInspectorWindowController (Accessing)

- (ATEditor *)editor
{
    return [editorController content];
}

@end

@implementation ATInspectorWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[self window] makeFirstResponder:[[self window] initialFirstResponder]];
}

- (IBAction)cancel:(id)sender
{
	[[self editor] cancel];
	
	if ([[self window] isSheet])
        [[NSApplication sharedApplication] endSheet:[self window]];
    else
        [self close];
}

- (IBAction)ok:(id)sender
{
	[[self editor] accept];
	
    if ([[self window] isSheet])
        [[NSApplication sharedApplication] endSheet:[self window]];
    else
        [self close];
}

@end

@implementation ATInspectorWindowController (Sheet)

- (void)beginSheetOn:(NSWindow *)aWindow
{
	[self retain];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
	
	[self autorelease];
}

@end
