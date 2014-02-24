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

- (void)setup {
	self.body = nullptr;
	self.bodyDef = make_shared<b2BodyDef>();
	
	self.bodyDef->allowSleep = false; // don't fall asleep after movement has started (gravity will continue to affect body; accelerometer will move boxes)
	self.bodyDef->type = b2_dynamicBody;
}

- (id)initWithFile:(NSString *)filename {
	if (self = [super initWithFile:filename]) {
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
}

- (CGPoint)positionForOpenGL {
//	return [[CCDirector sharedDirector] convertToGL:self.position];
	return self.position;
}

- (void)setPositionForOpenGL:(CGPoint)positionForOpenGL {
//	self.position = [[CCDirector sharedDirector] convertToUI:positionForOpenGL];
	self.position = positionForOpenGL;
}

- (b2Vec2)positionForBox2D {
	auto converted = CC_POINT_PIXELS_TO_POINTS(self.positionForOpenGL);
	return {converted.x / kPTMRatio, converted.y / kPTMRatio};
}

- (void)setPositionForBox2D:(b2Vec2)positionForBox2D {
	self.positionForOpenGL = CC_POINT_POINTS_TO_PIXELS(ccp(positionForBox2D.x * kPTMRatio, positionForBox2D.y * kPTMRatio));
}

- (b2Vec2)contentSizeForBox2D {
	auto convertedSize = CC_SIZE_PIXELS_TO_POINTS(self.contentSize);
	return { convertedSize.width / kPTMRatio, convertedSize.height / kPTMRatio };
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {}

@end
