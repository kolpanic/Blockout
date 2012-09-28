//
//  TimeBlockoutView.m
//  Blockout
//
//  Created by Karl Moskowski on 11-12-08.
//  Copyright (c) 2011 Voodoo Ergonomics Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimeBlockoutView : NSView {
@private
	NSInteger _tag;
	double _lowValue;
	double _highValue;
    
	id __unsafe_unretained _observedObjectForLowValue;
	NSString *_observedKeyPathForLowValue;
	id __unsafe_unretained _observedObjectForHighValue;
	NSString *_observedKeyPathForHighValue;
    
	NSRect _backgroundRect;
	BOOL _trackingLowEnd;
	BOOL _trackingHighEnd;
	BOOL _isMouseDown;
    
	double _draggingLowValue;
	double _draggingHighValue;
}

- (NSAttributedString *) draggingDescriptionForValue:(double)value;

@property (assign) NSInteger tag;
@property (assign) double lowValue;
@property (assign) double highValue;

@property (unsafe_unretained) id observedObjectForLowValue;
@property (copy) NSString *observedKeyPathForLowValue;
@property (unsafe_unretained) id observedObjectForHighValue;
@property (copy) NSString *observedKeyPathForHighValue;

@property (assign) NSRect backgroundRect;
@property (assign) BOOL trackingLowEnd;
@property (assign) BOOL trackingHighEnd;
@property (assign) BOOL isMouseDown;

@end
