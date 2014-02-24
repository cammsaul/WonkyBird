//
//  GameSprite.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

@implementation GameSprite

+ (instancetype)alloc {
	GameSprite *gameSprite = nil;
	if ((gameSprite = [super alloc])) {
		gameSprite->_item = [[Box2DItem alloc] initWithOwner:gameSprite];
	}
	return gameSprite;
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {}

@end
