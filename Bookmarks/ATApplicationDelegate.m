#import "ATApplicationDelegate.h"
#import "ATNullBetweenNilTransformer.h"
#import "ATBrowser.h"

#ifndef DEBUG
static NSInteger ATDebugMenuItemTag = -1;
#endif

@implementation ATApplicationDelegate

- (void)awakeFromNib
{
	[NSValueTransformer setValueTransformer:[[[ATNullBetweenNilTransformer alloc] init] autorelease]
                                forName:@"ATNullBetweenNilTransformer"];
    [ATBrowser installHookMethods];
    
#ifndef DEBUG
    NSMenu *aMainMenu = [[NSApplication sharedApplication] mainMenu];
    [aMainMenu removeItem:[aMainMenu itemWithTag:ATDebugMenuItemTag]];
#endif
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (IBAction)logResponderChain:(id)sender
{
	[self logResponderChainOf:[[NSApplication sharedApplication] keyWindow] type:@"keyWindow"];
	[self logResponderChainOf:[[NSApplication sharedApplication] mainWindow] type:@"mainWindow"];
}

- (void)logResponderChainOf:(NSWindow *)aWindow type:(NSString *)aType
{
	int anIndentLevel = 0;
	NSResponder *aResponder = [aWindow firstResponder];

	NSLog(@"%@ title is %@", aType, [aWindow title]);
	
	NSLog(@"%@'s firstResponder is %@", aType, aResponder);
	
	while ((aResponder = [aResponder nextResponder]))
	{
		NSMutableString *anIndent = [NSMutableString string];
		int i = 0;
		
		anIndentLevel++;
		
		for ( ; i < anIndentLevel ; i++)
			[anIndent appendString:@" "];
			
		NSLog(@"%@%@", anIndent, [aResponder description]);
	}
}

- (IBAction)logCurrentFirstResponder:(id)sender
{
	NSLog(@"currentFirstResponder is %@", [[NSApplication sharedApplication] targetForAction:@selector(openWindow:)]);
}

@end
