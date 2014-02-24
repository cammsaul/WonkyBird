//
//  Box2DLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#include <memory>

#include <Box2D/Box2D.h>
#include <Box2D/GLES-Render.h>

#import "Box2DLayer.h"

using namespace std;

@interface Box2DLayer ()
@property (nonatomic) shared_ptr<b2World> world;
@property (nonatomic) shared_ptr<GLESDebugDraw> debugDraw;
@end

@implementation Box2DLayer

- (instancetype)init {
	if (self = [super init]) {
		// create world
		b2Vec2 gravity { 0.0f, -10.0f };
		self.world = make_shared<b2World>(gravity);
		
		// create debug draw
		self.debugDraw = make_shared<GLESDebugDraw>(kPTMRatio * CC_CONTENT_SCALE_FACTOR());
		self.world->SetDebugDraw(self.debugDraw.get());
		self.debugDraw->SetFlags(b2Draw::e_shapeBit);
	
		[self scheduleUpdate];
		
		// create a test box
		const CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint midScreen = {200, 300};
		midScreen = CC_POINT_PIXELS_TO_POINTS([[CCDirector sharedDirector] convertToGL:midScreen]);
		const b2Vec2 locationWorld {midScreen.x/kPTMRatio, midScreen.y/kPTMRatio};
		auto randFn = [](float min = 0.0f, float max = 1.0f) { const float range = max - min; return (((random() % 1000) / 1000.0f) * range) + (float)min; }; ///< return a value between (min = 0.0f, max = 1.0f)
		const float size = randFn(40, 60);
		[self createBoxAtLocation:locationWorld withSize:{size, size} friction:randFn(0.2) restitution:randFn(0.0f, 0.2f) density:randFn(0.8f, 1.0f)];
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
}

#pragma mark - Test Box

/// \param friction The friction coefficient, usually in the range [0,1].
/// \param restitution The restitution (elasticity) usually in the range [0,1].
/// \param density The density, usually in kg/m^2.
- (void)createBoxAtLocation:(b2Vec2)location withSize:(CGSize)size friction:(float32)friction restitution:(float32)restitution density:(float32)density {
	size = CC_SIZE_PIXELS_TO_POINTS(size);
	
	b2BodyDef bodyDef;
	bodyDef.allowSleep = false; // don't fall asleep after movement has started (gravity will continue to affect body; accelerometer will move boxes)
	bodyDef.type = b2_dynamicBody;
	bodyDef.position = location;
	b2Body *body = self.world->CreateBody(&bodyDef);
	
	b2PolygonShape shape;
	shape.SetAsBox(size.width/2/kPTMRatio, size.height/2/kPTMRatio);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = density;
	fixtureDef.friction = friction;
	fixtureDef.restitution = restitution;
	
	body->CreateFixture(&fixtureDef);
}

@end
