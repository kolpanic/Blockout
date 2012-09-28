//
//  PreferencesWindowController.h
//  Blockout
//
//  Created by Karl Moskowski on 11-12-08.
//  Copyright (c) 2011 Voodoo Ergonomics Inc. All rights reserved.
//

@class TimeBlockoutView;

@interface PreferencesWindowController : NSWindowController {
@private
	TimeBlockoutView *i_blockoutView;
	NSView *i_blockoutPrefsView;
}

- (IBAction)	blockoutPresetWorkHours:(id)sender;
- (IBAction)	blockoutPresetNone:(id)sender;
- (IBAction)	blockoutResetDay:(id)sender;
- (IBAction)	showPrefsPaneForItem:(id)sender;

@property (strong) IBOutlet TimeBlockoutView *blockoutView;
@property (strong) IBOutlet NSView *blockoutPrefsView;

@end