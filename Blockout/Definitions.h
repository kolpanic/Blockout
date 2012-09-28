//
//  Definitions.h
//  Blockout
//
//  Created by Karl Moskowski on 11-12-08.
//  Copyright (c) 2011 Voodoo Ergonomics Inc. All rights reserved.
//

#define LocalObserver(n, s) [[NSNotificationCenter defaultCenter] addObserver : self selector : @selector(s) name : n object : nil]

extern NSString *const VEBlockoutChangedLowKey;
extern NSString *const VEBlockoutChangedHighKey;
extern NSString *const VEBlockoutAllChangedNotification;
extern NSString *const VEBlockoutChangedTagKey;
extern NSString *const VEBlockoutStartKey;
extern NSString *const VEBlockoutEndKey;
