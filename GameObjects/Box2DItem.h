//
//  Box2DItem.h
//  WonkyBird
//
//  Created by Cam Saul on 2/24/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Box2DItemOwner;

@interface Box2DItem : NSObject

@property (nonatomic, weak, readonly) id<Box2DItemOwner> owner; ///< Sprite that 'owns' this item.

@property (nonatomic, readonly) b2Body *body;					///< nullptr until [GameSprite addToWorld:] is called
@property (nonatomic, readonly) shared_ptr<b2BodyDef> bodyDef;

@property (nonatomic) shared_ptr<b2PolygonShape> shape;			///< By default, just a box
@property (nonatomic) shared_ptr<b2FixtureDef> fixtureDef;

@property (nonatomic, readonly) b2Fixture& fixture;

@property (nonatomic) b2Vec2 positionForBox2D;					///< magic getter/setter; converts self.position <-> Box2D
@property (nonatomic, readonly) b2Vec2 contentSizeForBox2D;		///< magic getter converts self.contentSize -> Box2D

- (instancetype)initWithOwner:(id<Box2DItemOwner>)owner;		///< Designated initializer

- (void)addToWorld:(shared_ptr<b2World>)world;

- (void)removeFromWorld;										///< Remove this item's body from world.
- (void)moveToNewPosition;										///< 'Teleport' the item (remove from world and add back to world

@end


/// Sprite that is associated with a Box2D item
@protocol Box2DItemOwner <NSObject>

- (Box2DItem *)item; ///< Sprite should return Box2D item it is associated with

@property (nonatomic) CGPoint position;
@property (nonatomic) CGSize contentSize;

@optional

- (void)createFixtures;

@end