//
//  GameSprite.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "CCSprite.h"
#import "Box2DItem.h"

@interface GameSprite : CCSprite <Box2DItemOwner>

@property (nonatomic, readonly) Box2DItem *item;

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects; ///< Default behavior does nothing

@end
