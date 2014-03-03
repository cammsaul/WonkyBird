//
//  Box2DItem.m
//  WonkyBird
//
//  Created by Cam Saul on 2/24/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Box2DItem.h"
#import "Constants.h"

using namespace std;

@interface Box2DItem ()
@property (nonatomic) b2Body *body;
@property (nonatomic) shared_ptr<b2BodyDef> bodyDef;
@end

@implementation Box2DItem

+ (instancetype)alloc {
	Box2DItem *item = nil;
	if ((item = [super alloc])) {
		item.body = nullptr;
		item.bodyDef = make_shared<b2BodyDef>();
		
		item.shape = make_shared<b2PolygonShape>();
		item.fixtureDef = make_shared<b2FixtureDef>();
		item.fixtureDef->shape = item.shape.get();
		
		//	self.bodyDef->allowSleep = false; // don't fall asleep after movement has started (gravity will continue to affect body; accelerometer will move boxes)
		item.bodyDef->type = b2_dynamicBody;
	}
	return item;
}

- (instancetype)initWithOwner:(id<Box2DItemOwner>)owner {
	if (self = [super init]) {
		_owner = owner;
	}
	return self;
}

- (void)dealloc {
	[self removeFromWorld];
}

- (b2Fixture &)fixture {
	return self.body->GetFixtureList()[0];
}

- (void)addToWorldPtr:(b2World*)world {
	self.bodyDef->position = self.positionForBox2D;
	[self updateShape];
	self.body = world->CreateBody(self.bodyDef.get());
	self.body->SetUserData((__bridge void *)self.owner);
	self.body->SetActive(true);
	
	if ([self.owner respondsToSelector:@selector(createFixtures)]) {
		[self.owner createFixtures];
	} else {
		self.body->CreateFixture(self.fixtureDef.get());
	}
	
	if ([self.owner respondsToSelector:@selector(addedToWorld)]) {
		[self.owner addedToWorld];
	}
}

- (void)addToWorld:(shared_ptr<b2World>)world {
	NSAssert(self.owner, @"you must create a Box2DItem using initWithOwner: !");
	
	[self addToWorldPtr:world.get()];
}

- (void)removeFromWorld {
	self.body->GetWorld()->DestroyBody(self.body);
	self.body = nullptr;
}

- (void)moveToNewPosition {
	auto* world = self.body->GetWorld();
	[self removeFromWorld];
	[self addToWorldPtr:world];
}

- (void)updateShape {
	self.shape->SetAsBox(self.contentSizeForBox2D.x / 2, self.contentSizeForBox2D.y / 2);
}

- (b2Vec2)positionForBox2D {
	return {self.owner.position.x / kPTMRatio, self.owner.position.y / kPTMRatio};
}

- (void)setPositionForBox2D:(b2Vec2)positionForBox2D {
	self.owner.position = CGPointMake(positionForBox2D.x * kPTMRatio, positionForBox2D.y * kPTMRatio);
}

- (b2Vec2)contentSizeForBox2D {
	return { self.owner.contentSize.width / kPTMRatio, self.owner.contentSize.height / kPTMRatio };
}

@end
