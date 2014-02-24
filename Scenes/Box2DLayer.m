//
//  Box2DLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Box2DLayer.h"
#import "GameSprite.h"

using namespace std;

@interface Box2DLayer ()
@property (nonatomic) shared_ptr<b2World> world;
@property (nonatomic) shared_ptr<GLESDebugDraw> debugDraw;
@end

@implementation Box2DLayer

- (instancetype)initWithTextureAtlasNamed:(NSString *)textureAtlasName {
	if (self = [super initWithTextureAtlasNamed:textureAtlasName]) {
		// create world
		b2Vec2 gravity { -0.5f, -10.0f };
		self.world = make_shared<b2World>(gravity);
		
		// create debug draw
		self.debugDraw = make_shared<GLESDebugDraw>(kPTMRatio);
		self.world->SetDebugDraw(self.debugDraw.get());
		self.debugDraw->SetFlags(b2Draw::e_shapeBit);
	
		[self scheduleUpdate];
	}
	return self;
}

- (void)draw {
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	
	self.world->DrawDebugData();
	
	kmGLPopMatrix();
}

- (void)update:(ccTime)delta {
	static const int32 VelocityIterations = 3;
	static const int32 PositionIterations = 2;
	self.world->Step(delta, VelocityIterations, PositionIterations);
	
	b2Body *body = self.world->GetBodyList();
	while (body) {
		id<Box2DItemOwner> gameSprite = (__bridge id<Box2DItemOwner>)body->GetUserData();
		gameSprite.item.positionForBox2D = body->GetPosition();
		body = body->GetNext();
	}
}

@end
