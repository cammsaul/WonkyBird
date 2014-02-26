//
//  StaticBackgroundLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "StaticBackgroundLayer.h"

@implementation StaticBackgroundLayer

- (instancetype)init {
	if (self = [super init]) {
		CCSprite *background = [CCSprite spriteWithFile:@"Background.png"];
		background.position = ccp(ScreenWidth() / 2.0f, ScreenHeight() / 2.0f + (IsIphone5() ? 0 : 44)); // cut off the top part of the sky on iPhone 4
		[self addChild:background];
	}
	return self;
}

@end
