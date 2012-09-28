//
//  TimeBlockoutView.h
//  Blockout
//
//  Created by Karl Moskowski on 11-12-08.
//  Copyright (c) 2011 Voodoo Ergonomics Inc. All rights reserved.
//

#import "TimeBlockoutView.h"
#import "Definitions.h"

NSString *const lowValueKey = @"lowValue";
NSString *const highValueKey = @"highValue";

double const minValue = 0.0;
double const maxValue = 24.0;

@implementation TimeBlockoutView

#pragma mark - Setup

- (id) initWithFrame:(NSRect)frameRect {
	if (self = [super initWithFrame:frameRect]) {
		self.lowValue = minValue;
		self.highValue = minValue;
		_draggingLowValue = minValue;
		_draggingHighValue = minValue;
	}
	return self;
}

#pragma mark - Utility

- (double) pixelToValue:(CGFloat)pixel {
	double scale = (self.backgroundRect.size.width) / (maxValue - minValue);
	return pixel / scale;
}

- (CGFloat) valueToPixel:(double)value {
	double scale = (self.backgroundRect.size.width) / (maxValue - minValue);
	return value * scale;
}

#pragma mark - Drawing

- (void) drawRect:(NSRect)rect {
	// track
	self.backgroundRect = rect;
	NSDrawDarkBezel(self.backgroundRect, [self bounds]);
	NSGradient *trackGradient = [[NSGradient alloc] initWithColors:
	                             [NSArray arrayWithObjects:[NSColor blackColor], [NSColor colorWithDeviceRed:0.0 green:0.75 blue:1.0 alpha:1.0], [NSColor blackColor], nil]];
	[trackGradient drawInRect:NSInsetRect(self.backgroundRect, 1.0, 1.0) angle:0.0];
    
    NSDictionary *attributes =[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Apple Color Emoji" size:[NSFont systemFontSize]] forKey:NSFontAttributeName];
    NSAttributedString *sun = [[NSAttributedString alloc] initWithString:@"☀" attributes:attributes];
    NSAttributedString *moon = [[NSAttributedString alloc] initWithString:@"🌙" attributes:attributes];
 
    CGFloat y = self.backgroundRect.origin.y + self.backgroundRect.size.height / 2.0 - 10.0;
    
    [moon drawAtPoint:NSMakePoint(self.backgroundRect.origin.x, y)];
    [sun drawAtPoint:NSMakePoint(self.backgroundRect.origin.x + self.backgroundRect.size.width / 2.0, y)];
    [moon drawAtPoint:NSMakePoint(self.backgroundRect.origin.x + self.backgroundRect.size.width - moon.size.width, y)];
    
	// blockout range
	double l = (self.isMouseDown ? _draggingLowValue : self.lowValue);
	double h = (self.isMouseDown ? _draggingHighValue : self.highValue);
	if (l < h) {
		NSRect rangeRect = NSMakeRect([self valueToPixel:l] + 1.0,
		                              self.backgroundRect.origin.y + 1.0,
		                              [self valueToPixel:h - l] - (h == 24.0 ? 2.0 : 1.0),
		                              self.backgroundRect.size.height - 2.0);
		[[NSColor colorWithCalibratedRed:0.631 green:0.22 blue:0.231 alpha:1.0] set];
		NSFrameRect(rangeRect);
        
		NSGradient *rangeGradient = [[NSGradient alloc] initWithColorsAndLocations:
		                             [NSColor colorWithCalibratedRed:0.957 green:0.537 blue:0.537 alpha:0.9], 0.0,
		                             [NSColor colorWithCalibratedRed:0.8 green:0.133 blue:0.133 alpha:0.9], 0.5,
		                             [NSColor colorWithCalibratedRed:0.957 green:0.537 blue:0.537 alpha:0.9], 1.0,
		                             nil];
		[rangeGradient drawInRect:NSInsetRect(rangeRect, 1.0, 1.0) angle:90.0];
	}
}

- (void) resetCursorRects {
	[self addCursorRect:self.bounds cursor:[NSCursor resizeLeftRightCursor]];
}

#pragma mark - Bindings

+ (void) initialize {
	if (self == [TimeBlockoutView class]) {
		[self exposeBinding:lowValueKey];
		[self exposeBinding:highValueKey];
	}
	[super initialize];
}

- (Class) valueClassForBinding:(NSString *)binding {
	if ([binding isEqualToString:lowValueKey] || [binding isEqualToString:highValueKey])
		return [NSNumber class];
	return [super valueClassForBinding:binding];
}

- (void)	bind	:(NSString *)bindingName toObject:(id)observableController withKeyPath:(NSString *)keyPath
      options :(NSDictionary *)options {
	if ([bindingName isEqualToString:lowValueKey]) {
		[observableController addObserver:self forKeyPath:keyPath options:0 context:(__bridge void *)lowValueKey];
		self.observedObjectForLowValue = observableController;
		self.observedKeyPathForLowValue = keyPath;
	}
	if ([bindingName isEqualToString:highValueKey]) {
		[observableController addObserver:self forKeyPath:keyPath options:0 context:(__bridge void *)highValueKey];
		self.observedObjectForHighValue = observableController;
		self.observedKeyPathForHighValue = keyPath;
	}
	[super bind:bindingName toObject:observableController withKeyPath:keyPath options:options];
}

- (void) unbind:bindingName {
	if ([bindingName isEqualToString:lowValueKey]) {
		[self.observedObjectForLowValue removeObserver:self forKeyPath:self.observedKeyPathForLowValue];
		self.observedObjectForLowValue = nil;
		self.observedKeyPathForLowValue = nil;
	}
	if ([bindingName isEqualToString:highValueKey]) {
		[self.observedObjectForHighValue removeObserver:self forKeyPath:self.observedKeyPathForHighValue];
		self.observedObjectForHighValue = nil;
		self.observedKeyPathForHighValue = nil;
	}
	[super unbind:bindingName];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == (__bridge void *)lowValueKey)
		self.lowValue = [[self.observedObjectForLowValue valueForKeyPath:self.observedKeyPathForLowValue] doubleValue];
	if (context == (__bridge void *)highValueKey)
		self.highValue = [[self.observedObjectForHighValue valueForKeyPath:self.observedKeyPathForHighValue] doubleValue];
	[self setNeedsDisplay:YES];
}

- (void) dealloc {
	[self unbind:lowValueKey];
	[self unbind:highValueKey];
}

#pragma mark - Mouse Handling

- (void) updateForMouseEvent:(NSEvent *)event {
	// set appropriate value based on mouse location
    
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	double value = round([self pixelToValue:p.x]); // whole hours only
	value = MAX(minValue, value);
	value = MIN(maxValue, value);
	if (self.trackingLowEnd) {
		_draggingLowValue = value;
		_draggingHighValue = self.highValue;
	}
	if (self.trackingHighEnd) {
		_draggingLowValue = self.lowValue;
		_draggingHighValue = value;
	}
	if (!self.isMouseDown) {
		if (self.trackingLowEnd) {
			self.lowValue = value;
			[self.observedObjectForLowValue setValue:[NSNumber numberWithDouble:self.lowValue] forKeyPath:self.observedKeyPathForLowValue];
		}
		if (self.trackingHighEnd) {
			self.highValue = value;
			[self.observedObjectForHighValue setValue:[NSNumber numberWithDouble:self.highValue] forKeyPath:self.observedKeyPathForHighValue];
		}
	}
    
	// show current value as tooltip while dragging
	[[NSHelpManager sharedHelpManager] setContextHelp:[self draggingDescriptionForValue:value] forObject:self];
	[[NSHelpManager sharedHelpManager] showContextHelpForObject:self locationHint:[[self window] convertBaseToScreen:[self convertPointToBase:p]]];
	[[NSHelpManager sharedHelpManager] removeContextHelpForObject:self];
    
	if (!self.isMouseDown) {
		// if option-key is down, send a notification
		if (NSAlternateKeyMask == ([event modifierFlags] & NSAlternateKeyMask)) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			                          [NSNumber numberWithDouble:self.lowValue], VEBlockoutChangedLowKey,
			                          [NSNumber numberWithDouble:self.highValue], VEBlockoutChangedHighKey,
			                          [NSNumber numberWithUnsignedInteger:self.tag], VEBlockoutChangedTagKey,
			                          nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:VEBlockoutAllChangedNotification
                                                                object:nil userInfo:userInfo];
		}
	}
    
	[self setNeedsDisplay:YES];
}
- (void) mouseDown:(NSEvent *)event {
	// decide which end is being dragged
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	double distanceToLowEnd = ABS(p.x - [self valueToPixel:_draggingLowValue]);
	double distanceToHighEnd = ABS(p.x - [self valueToPixel:_draggingHighValue]);
	self.trackingLowEnd = (distanceToLowEnd < distanceToHighEnd);
	self.trackingHighEnd = !self.trackingLowEnd;
	self.isMouseDown = YES;
	[self updateForMouseEvent:event];
}
- (void) mouseDragged:(NSEvent *)event {
	[self updateForMouseEvent:event];
}
- (void) mouseUp:(NSEvent *)event {
	self.isMouseDown = NO;
	[self updateForMouseEvent:event];
	self.trackingLowEnd = NO;
	self.trackingHighEnd = NO;
    
	// fake a mouse-click to dismiss the dragging tooltip
	[[NSHelpManager sharedHelpManager] removeContextHelpForObject:self];
	NSEvent *newEvent = [NSEvent mouseEventWithType:NSLeftMouseDown
                                           location:[[self window] mouseLocationOutsideOfEventStream]
                                      modifierFlags:0
                                          timestamp:0
                                       windowNumber:[[self window] windowNumber]
                                            context:[[self window] graphicsContext]
                                        eventNumber:0
                                         clickCount:1
                                           pressure:0];
	[NSApp postEvent:newEvent atStart:NO];
	newEvent = [NSEvent mouseEventWithType:NSLeftMouseUp
                                  location:[[self window] mouseLocationOutsideOfEventStream]
                             modifierFlags:0
                                 timestamp:0
                              windowNumber:[[self window] windowNumber]
                                   context:[[self window] graphicsContext]
                               eventNumber:0
                                clickCount:1
                                  pressure:0];
	[NSApp postEvent:newEvent atStart:NO];
}
- (BOOL) acceptsFirstMouse:(NSEvent *)event {
	return YES;
}
- (BOOL) acceptsFirstResponder {
	return YES;
}

#pragma mark - Accessors

- (double) lowValue {
	return _lowValue;
}
- (void) setLowValue:(double)value {
	[self willChangeValueForKey:lowValueKey];
	value = MAX(value, minValue);
	value = MIN(value, maxValue);
	value = (_highValue == 0.0) ? value : MIN(value, _highValue);
	if (_lowValue != value) {
		_lowValue = value;
		[self setNeedsDisplay:YES];
		if (!self.isMouseDown)
			_draggingLowValue = value;
	}
	[self didChangeValueForKey:lowValueKey];
	[self setToolTip:[self description]];
}

- (double) highValue {
	return _highValue;
}
- (void) setHighValue:(double)value {
	[self willChangeValueForKey:highValueKey];
	value = MAX(value, minValue);
	value = MIN(value, maxValue);
	value = (_lowValue == 0.0) ? value : MAX(value, _lowValue);
	if (_highValue != value) {
		_highValue = value;
		[self setNeedsDisplay:YES];
		if (!self.isMouseDown)
			_draggingHighValue = value;
	}
	[self didChangeValueForKey:highValueKey];
	[self setToolTip:[self description]];
}

- (NSString *) description {
	if (self.lowValue == 0.0 && self.highValue == 24.0)
		return NSLocalizedString(@"All day", @"tooltip");
	else if (self.lowValue == self.highValue)
		return NSLocalizedString(@"None", @"tooltip");
	else if (self.lowValue > 0.0 || self.highValue > 0.0) {
		NSDateFormatter *df = [NSDateFormatter new];
		[df setDateFormat:@"h a"];
		NSDate *midnight = [NSDate dateWithNaturalLanguageString:@"midnight"];
		NSDate *lowDate = [midnight dateByAddingTimeInterval:(self.lowValue * 3600.0)];
		NSDate *highDate = [midnight dateByAddingTimeInterval:(self.highValue * 3600.0)];
		NSString *description = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:lowDate], [df stringFromDate:highDate]];
		return description;
	} else
		return nil;
}

- (NSAttributedString *) draggingDescriptionForValue:(double)value {
	NSAttributedString *draggingDescription = nil;
	if (value == 0.0 || value == 24.0)
		draggingDescription = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Midnight", @"tooltip")];
	else if (value == 12.0)
		draggingDescription = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Noon", @"tooltip")];
	else {
		NSDateFormatter *df = [NSDateFormatter new];
		[df setDateFormat:@"h a"];
		NSDate *date = [[NSDate dateWithNaturalLanguageString:@"midnight"] addTimeInterval:(value * 3600.0)];
		draggingDescription = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [df stringFromDate:date]]];
	}
	return draggingDescription;
}

@dynamic lowValue;
@dynamic highValue;
@synthesize tag = _tag;
@synthesize backgroundRect = _backgroundRect;
@synthesize trackingLowEnd = _trackingLowEnd;
@synthesize trackingHighEnd = _trackingHighEnd;
@synthesize isMouseDown = _isMouseDown;
@synthesize observedObjectForLowValue = _observedObjectForLowValue;
@synthesize observedKeyPathForLowValue = _observedKeyPathForLowValue;
@synthesize observedObjectForHighValue = _observedObjectForHighValue;
@synthesize observedKeyPathForHighValue = _observedKeyPathForHighValue;

@end
