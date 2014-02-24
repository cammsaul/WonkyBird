//
//  StaticBackgroundLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#define SCREEN_SIZE ([CCDirector sharedDirector].winSize)
#define IS_IPHONE_5 (SCREEN_SIZE.height > 480)

#import "StaticBackgroundLayer.h"

@implementation StaticBackgroundLayer

- (instancetype)init {
	if (self = [super init]) {
		CCSprite *background = [CCSprite spriteWithFile:@"Background.png"];
		background.position = ccp(SCREEN_SIZE.width / 2.0f, SCREEN_SIZE.height / 2.0f + (IS_IPHONE_5 ? 0 : 44)); // cut off the top part of the sky on iPhone 4
		[self addChild:background];
	}
	return self;
}

@end
