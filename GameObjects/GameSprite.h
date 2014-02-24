//
//  GameSprite.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "CCSprite.h"

@interface GameSprite : CCSprite

@property (nonatomic, readonly) b2Body *body;					///< nullptr until [GameSprite addToWorld:] is called
@property (nonatomic, readonly) shared_ptr<b2BodyDef> bodyDef;

@property (nonatomic) b2Vec2 positionForBox2D;					///< magic getter/setter; converts self.position <-> Box2D

@property (nonatomic, readonly) b2Vec2 contentSizeForBox2D;		///< magic getter converts self.contentSize -> Box2D

- (void)addToWorld:(shared_ptr<b2World>)world;					/// Subclasses should override this to add fixtures to body as needed

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects; ///< Default behavior does nothing

// **** "PROTECTED" ****//

// Called during init/initWithFile/initWithFramename/etc methods. Subclasses can implement this method (and call [super setup]) to do additional customization
- (void)setup;

@end
