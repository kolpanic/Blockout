//
//  PreferencesWindowController.m
//  Blockout
//
//  Created by Karl Moskowski on 11-12-08.
//  Copyright (c) 2011 Voodoo Ergonomics Inc. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "TimeBlockoutView.h"
#import "Definitions.h"

@implementation PreferencesWindowController

- (id) init {
	return [super initWithWindowNibName:@"Preferences"];
}

- (void) awakeFromNib {
	[super awakeFromNib];
    
	self.blockoutView.tag = 1;
	[self.blockoutView bind:@"lowValue" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:@"BlockoutStart" options:nil];
	[self.blockoutView bind:@"highValue" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:@"BlockoutEnd" options:nil];
    
	LocalObserver(VEBlockoutAllChangedNotification, blockoutAllChanged:);
    
	[self showPrefsPaneForItem:nil];
	self.window.toolbar.selectedItemIdentifier = [[self.window.toolbar.items objectAtIndex:0] itemIdentifier];
}

- (void) blockoutAllChanged:(NSNotification *)n {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	double lowValue = [[[n userInfo] objectForKey:VEBlockoutChangedLowKey] doubleValue];
	double highValue = [[[n userInfo] objectForKey:VEBlockoutChangedHighKey] doubleValue];
	NSInteger tag = [[[n userInfo] objectForKey:VEBlockoutChangedTagKey] unsignedIntegerValue];
	if (tag != 1) {
		[defaults setObject:[NSNumber numberWithDouble:lowValue] forKey:VEBlockoutStartKey];
		[defaults setObject:[NSNumber numberWithDouble:highValue] forKey:VEBlockoutEndKey];
	}
}

- (IBAction) blockoutPresetWorkHours:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithDouble:9.0] forKey:VEBlockoutStartKey];
	[defaults setObject:[NSNumber numberWithDouble:17.0] forKey:VEBlockoutEndKey];
}

- (IBAction) blockoutPresetNone:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithDouble:0.0] forKey:VEBlockoutStartKey];
	[defaults setObject:[NSNumber numberWithDouble:0.0] forKey:VEBlockoutEndKey];
}

- (IBAction) blockoutResetDay:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger tag = [sender tag];
	if (tag == 1) {
		[defaults setObject:[NSNumber numberWithDouble:0.0] forKey:VEBlockoutStartKey];
		[defaults setObject:[NSNumber numberWithDouble:0.0] forKey:VEBlockoutEndKey];
	}
}

#pragma mark - Prefs Window Toolbar

- (IBAction) showPrefsPaneForItem:(id)sender {
	NSView *prefsView = self.blockoutPrefsView;
	if (prefsView) {
		if (self.window.contentView == prefsView)
			return;
        
		if (sender)
			self.window.title = [sender label];
        
		NSView *temp = [[NSView alloc] initWithFrame:[self.window.contentView frame]];
		self.window.contentView = temp;
        
		NSRect newFrame = self.window.frame;
		NSView *contentView = self.window.contentView;
		float dY = (prefsView.frame.size.height - contentView.frame.size.height) * self.window.userSpaceScaleFactor;
		newFrame.origin.y -= dY;
		newFrame.size.height += dY;
		float dX = (prefsView.frame.size.width - contentView.frame.size.width) * self.window.userSpaceScaleFactor;
		newFrame.size.width += dX;
        
		[prefsView setHidden:YES];
		[self.window setFrame:newFrame display:YES animate:YES];
		self.window.contentView = prefsView;
		[prefsView setHidden:NO];
	}
}

@synthesize blockoutView = i_blockoutView, blockoutPrefsView = i_blockoutPrefsView;

@end
