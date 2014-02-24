//
//  GameplayLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameplayLayer.h"
#import "GameSprite.h"
#import "Toucan.h"
#import "Pipe.h"

static const int GroundHeight = 90;

@interface GameplayLayer ()
@property (nonatomic, strong) Toucan *toucan;
@property (nonatomic, strong) GameSprite *ground;
@property (nonatomic, strong) NSMutableArray *walls;
@property (nonatomic, strong) NSMutableArray *pipes;
@end

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super initWithTextureAtlasNamed:@"Textures"]) {
		self.toucan = [[Toucan alloc] init];
		self.toucan.position = ccp(SCREEN_SIZE.width / 2.0f, SCREEN_SIZE.height / 2.0f);
		[self.sceneSpriteBatchNode addChild:self.toucan];
		[self.toucan.item addToWorld:self.world];
		
		// add the ground
		self.ground = [[GameSprite alloc] init];
		self.ground.item.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(SCREEN_SIZE.width / 2.0f, GroundHeight / 2);
		self.ground.contentSize = CGSizeMake(SCREEN_SIZE.width, GroundHeight);
		self.ground.item.fixtureDef->density = 0.0f;
		[self.ground.item addToWorld:self.world];
		
		// add the "walls"
		self.walls = [NSMutableArray array];
		
		auto makeWall = [&](float x, float y, float width, float height) {
			GameSprite *wall = [[GameSprite alloc] init];
			wall.item.bodyDef->type = b2_staticBody;
			wall.position = CGPointMake(x, y);
			wall.contentSize = CGSizeMake(width, height);
			wall.item.fixtureDef->density = 0.0f;
			wall.item.fixtureDef->restitution = 0.4f;
			[wall.item addToWorld:self.world];
			[self.walls addObject:wall];
		};
		makeWall(160, SCREEN_SIZE.height - 2, 320, 4); // roof
		makeWall(-70 /* enough to move pipe offscreen */, SCREEN_SIZE.height / 2, 4, SCREEN_SIZE.height); // left wall
		makeWall(SCREEN_SIZE.width + 2, SCREEN_SIZE.height / 2, 4, SCREEN_SIZE.height); // right wall
		
		// add a pipe
		self.pipes = [NSMutableArray array];
		[self addPipeOfSize:6];
		
		self.touchEnabled = YES;
	}
	return self;
}

- (void)addPipeOfSize:(int)pipeSize {
	Pipe *p = [Pipe pipeOfSize:pipeSize];
	p.position = CGPointMake(SCREEN_SIZE.width, p.contentSize.height / 2 + GroundHeight);
	[self addChild:p.layer];
	[p.item addToWorld:self.world];
	[self.pipes addObject:p];
}

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)update:(ccTime)delta {
	[super update:delta];
	
	CCArray *gameObjects = self.sceneSpriteBatchNode.children; // TODO - this should be iterated in a thread safe manner ?
	for (GameSprite *sprite in gameObjects) {
		[sprite updateStateWithDeltaTime:delta andListOfGameObjects:gameObjects];
	}
	
	for (Pipe *p in self.pipes.copy) {
		if (p.position.x < -p.contentSize.width / 2) {
			[self.pipes removeObject:p];
			[self removeChild:p.layer cleanup:YES];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self addPipeOfSize:(rand() % 4) + 2];
			});
		} else {
			p.item.body->SetLinearVelocity({-1.0f, 0});
		}
	}
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (self.toucan.state != ToucanStateDead) {
		self.toucan.item.body->SetAwake(true);
		
		static const int XPositionValue = 0.5f;
		const float xPositionAmount = (SCREEN_SIZE.width/2 - self.toucan.position.x) * XPositionValue;
		
		static const int XTouchValue = 0.4f;
		const float xTouchAmount = ([touch locationInView:[[CCDirector sharedDirector] view]].x - SCREEN_SIZE.width/2) * XTouchValue;
		
		const float yVelocity = self.toucan.item.body->GetLinearVelocity().y;
		const float YVelocityBase = 150 + rand() % 100;
		const float yAmount = yVelocity > 1 ? (YVelocityBase / yVelocity) : YVelocityBase;
		self.toucan.item.body->ApplyForceToCenter({xPositionAmount + xTouchAmount, yAmount}, true); // try to fly toucan towards center
	}
	return YES;
}

@end
