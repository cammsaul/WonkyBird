//
//  GameplayLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Constants.h"
#import "GameplayLayer.h"
#import "GameSprite.h"
#import "Bird.h"
#import "Pipe.h"
#import "GameManager.h"
#import "Toucan.h"
#import "Pigeon.h"


float MaxTotalSize() {
	return MIN((InitialMaxSize + (CurrentRoundScore() / 2)), MaxMaxSize);
}

float RandomPipeSize() {
	const int SizeRange = MaxTotalSize() - (MinPipeSize * 2);
	return (random() % SizeRange) + MinPipeSize;
//	return MaxTotalSize - lastPipeSize;
}

@interface GameplayLayer () {
	NSMutableArray *_birds;
}
@property (nonatomic, strong) Bird *bird;
@property (nonatomic, strong) GameSprite *ground;
@property (nonatomic, strong) NSMutableArray *walls;
@property (nonatomic, strong) NSMutableArray *pipes;
@property (nonatomic, strong, readonly) NSMutableArray *birds;
@end

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super initWithTextureAtlasNamed:@"Textures"]) {
		srandom((int)time(NULL));
		
		self.bird = [[Toucan alloc] init];
		
		// add the ground
		self.ground = [[GameSprite alloc] init];
		self.ground.item.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(ScreenHalfWidth(), GroundHeight / 2);
		self.ground.contentSize = CGSizeMake(ScreenWidth() * 2 /* extend out past edges a bit */, GroundHeight);
		self.ground.item.fixtureDef->density = 0.0f;
		self.ground.item.fixtureDef->friction = 0.8f;
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
		makeWall(ScreenHalfWidth(), ScreenHeight() + 2, ScreenWidth() * 2, 4); // roof
//		makeWall(-70 /* enough to move pipe offscreen */, ScreenHeight() / 2, 4, ScreenHeight()); // left wall
//		makeWall(ScreenWidth() + 2, ScreenHeight() / 2, 4, ScreenHeight()); // right wall
								
		self.pipes = [NSMutableArray array];
		
		self.touchEnabled = YES;
	}
	return self;
}

- (NSMutableArray *)birds {
	if (!_birds) {
		_birds = [NSMutableArray array];
	}
	return _birds;
}

- (void)addBird:(Bird *)bird {
	bird.position = ccp(ScreenHalfWidth(), ScreenHeight() * kBirdMenuHeight);
	[self.spriteBatchNode addChild:bird];
	[self.birds addObject:bird];
	[bird.item addToWorld:self.world];
}

- (void)removeBird:(Bird *)bird {
	[bird removeFromParentAndCleanup:YES];
	[_birds removeObject:bird];
}

- (void)removeExtraBirds {
	for (Bird *b in self.birds.copy) {
		if (b != self.bird) {
			[self removeBird:b];
		}
	}
}

- (void)addExtraBirds {
	if (![self.bird isKindOfClass:Toucan.class]) [self addBird:[[Toucan alloc] init]];
	if (![self.bird isKindOfClass:Pigeon.class]) [self addBird:[[Pigeon alloc] init]];
}

- (void)setBird:(Bird *)bird {
	[self removeBird:_bird];
	_bird = bird;
	[self addBird:_bird];
}

- (void)addPipeOfSize:(int)pipeSize upsideDown:(BOOL)upsideDown {
	NSParameterAssert(pipeSize >= MinPipeSize);
	NSParameterAssert(pipeSize <= MaxPipeSize);
	NSParameterAssert(pipeSize <= MaxTotalSize() - MinPipeSize);
	
	Pipe *p = [Pipe pipeOfSize:pipeSize upsideDown:upsideDown];
	const float pipeHalfHeight = p.contentSize.height / 2;
	const float x = [GameManager sharedInstance].reverse ? (0 - p.contentSize.width) : (ScreenWidth() + p.contentSize.width / 2);
	p.position = CGPointMake(x, (upsideDown ? (ScreenHeight() - pipeHalfHeight) : (pipeHalfHeight + GroundHeight)));
	[self addChild:p.layer];
	[p.item addToWorld:self.world];
	[self.pipes addObject:p];
	
	p.item.body->SetLinearVelocity({PipeXVelocity * [GameManager sharedInstance].gameSpeed, -kGravityVelocity});
	p.item.body->SetGravityScale(0.0f); // pipes unaffected by gravity !
	
	// call self recursively to add upside-down pipe if needed
	if (!upsideDown) {
		const auto newPipeSize = MaxTotalSize() - pipeSize;
		[self addPipeOfSize:newPipeSize upsideDown:YES];
	}
}

- (void)removeOldPipes {
	Pipe *p = self.pipes.firstObject;
	if (p.position.x < -p.contentSize.width / 2 || (p.position.x > ScreenWidth() + p.contentSize.width)) {
		[self.pipes removeObject:p];
		[self removeChild:p.layer cleanup:YES];
		[self removeOldPipes];
	}
}

- (void)addRandomPipeIfNeeded {
	[self removeOldPipes];
	
	if (self.pipes.count >= kMaxNumPipes) return;
	
	// how far was the most recent pipe?
	Pipe *lastPipe = self.pipes.lastObject;
	
	if (([GameManager sharedInstance].reverse && lastPipe.layer && lastPipe.layer.position.x < (ScreenWidth() * (1 - NextPipeDistance)))
	   || (![GameManager sharedInstance].reverse && lastPipe.layer.position.x > ScreenWidth() * NextPipeDistance)) return; // too soon

	[self addPipeOfSize:RandomPipeSize() upsideDown:NO];
}

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)update:(ccTime)delta {
	static GameState lastState = GStateMainMenu;
		
	if (GStateIsGetReady())
	{
		if (lastState != GStateGetReady && lastState != GStateMainMenu) {
			// switch out the birds
			if ([self.bird isKindOfClass:[Toucan class]]) {
				self.bird = [[Pigeon alloc] init];
			} else {
				self.bird = [[Toucan alloc] init];
			}
		}
		
		for (Bird *b in self.birds) if (b != self.bird) {
			b.xVelocity = PipeXVelocity * [GameManager sharedInstance].gameSpeed;
			if (b.x < -(b.contentSize.width / 2)) {
				[self removeBird:b];
			}
		}
		
		self.bird.state = BirdStateFlapping;
		const float BirdYDiff = ((self.bird.y - (ScreenHeight() * 0.60f)) / kPTMRatio) * 4;
		const float BirdXDiff = ((self.bird.x - ScreenHalfWidth()) / kPTMRatio) * 4;
		self.bird.velocity =  b2Vec2{-BirdXDiff, -BirdYDiff};
		
		for (Pipe *p in self.pipes) {
			[self removeChild:p.layer cleanup:YES];
		}
		[self.pipes removeAllObjects];
	}
	if (GStateIsMainMenu()) {
		if (self.birds.count < 2) {
			[self addExtraBirds];
		}
		if (GStateIsMainMenu()) {
			for (Bird *b in self.birds) {
				[b flapAroundOnMainScreen:self.birds];
			}
		} else {
			for (Bird *b in self.birds) {
				if (b != self.bird) {
					b.state = BirdStateFalling;
				}
				b.rotation = 0;
			}
		}
	}
	else if (GStateIsActive())
	{
		if (lastState != GStateActive) {
			[self removeExtraBirds];
			self.bird.x = ScreenHalfWidth();
			self.bird.xVelocity = 0.0f;
		}
		
		if (ABS(self.bird.xVelocity) >= 0.2f) {
			NSLog(@"Bird x: %.2f", self.bird.xVelocity);
			self.bird.state = BirdStateDead;
		}

		if (self.bird.dead) {
			SetGState(GStateGameOver);
		} else {
			[self addRandomPipeIfNeeded];
		}
		
		for (Pipe *p in self.pipes) {
			const float pipeXVelocity = PipeXVelocity * [GameManager sharedInstance].gameSpeed;
			p.item.body->SetLinearVelocity({pipeXVelocity, 0});
			[p updateStateWithDeltaTime:delta];
		}
	}
	else if (GStateIsGameOver()) {
		for (Pipe *p in self.pipes) {
			p.item.body->SetLinearVelocity({0, 0});
			[p updateStateWithDeltaTime:delta];
		}
	}
	
	[super update:delta];
	
	CCArray *gameObjects = self.spriteBatchNode.children; // TODO - this should be iterated in a thread safe manner ?
	for (GameSprite *sprite in gameObjects) {
		[sprite updateStateWithDeltaTime:delta andListOfGameObjects:gameObjects];
	}
	
	lastState = GState();
}

static NSUInteger __touchBeginTime = 0;

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (!GStateIsActive()) {
		return NO;
	}
	
	__touchBeginTime = [[CCDirector sharedDirector] totalFrames];
	return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	const NSUInteger numFrames = [[CCDirector sharedDirector] totalFrames] - __touchBeginTime;
	NSLog(@"num frames: %zd", numFrames);
	
	if (self.bird.state != BirdStateDead) {
		self.bird.item.body->SetAwake(true);

//		self.bird.yVelocity = 20;

		// move Bird towards horizontal center of screen if needed
		self.bird.xVelocity = (ScreenHalfWidth() / kPTMRatio) - self.bird.item.positionForBox2D.x;
		[self.bird applyTouch:numFrames];
	}
}
//
//- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
//	self.bird.item.body->ApplyForceToCenter({0, 10}, true);
//}

@end
