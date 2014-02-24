//
//  GameSprite.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

@interface GameSprite ()
@property (nonatomic) b2Body *body;
@property (nonatomic) shared_ptr<b2BodyDef> bodyDef;
@end

@implementation GameSprite

+ (instancetype)alloc {
	GameSprite *item = nil;
	if ((item = [super alloc])) {
		item.body = nullptr;
		item.bodyDef = make_shared<b2BodyDef>();
	}
	return item;
}

- (void)setup {
//	self.bodyDef->allowSleep = false; // don't fall asleep after movement has started (gravity will continue to affect body; accelerometer will move boxes)
	self.bodyDef->type = b2_dynamicBody;
}

- (id)initWithFile:(NSString *)filename {
	if (self = [super initWithFile:filename]) {
		[self setup];
	}
	return self;
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
	if (self = [super initWithSpriteFrame:spriteFrame]) {
		[self setup];
	}
	return self;
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName {
	if (self = [super initWithSpriteFrameName:spriteFrameName]) {
		[self setup];
	}
	return self;
}

- (instancetype)init {
	if (self = [super init]) {
		[self setup];
	}
	return self;
}

- (void)addToWorld:(shared_ptr<b2World>)world {
	self.bodyDef->position = self.positionForBox2D;
	self.body = world->CreateBody(self.bodyDef.get());
	self.body->SetUserData((__bridge void *)self);
	self.body->SetActive(true);
}

- (b2Vec2)positionForBox2D {
	return {self.position.x / kPTMRatio, self.position.y / kPTMRatio};
}

- (void)setPositionForBox2D:(b2Vec2)positionForBox2D {
	self.position = ccp(positionForBox2D.x * kPTMRatio, positionForBox2D.y * kPTMRatio);
}

- (b2Vec2)contentSizeForBox2D {
	return { self.contentSize.width / kPTMRatio, self.contentSize.height / kPTMRatio };
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {}

@end
