//
//  Pipe.m
//  WonkyBird
//
//  Created by Cam Saul on 2/24/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Pipe.h"
#import "GameManager.h"

static const int kTileSize = 32; ///< in points

@interface Pipe ()
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic) NSUInteger numRows;
@end

@implementation Pipe
@synthesize position = _position, contentSize = _contentSize;

+ (instancetype)alloc {
	Pipe *p = [super alloc];
	if (p) {
		p->_item = [[Box2DItem alloc] initWithOwner:p];
	}
	return p;
}

+ (instancetype)pipeOfSize:(NSUInteger)pipeHeight {
	Pipe *p = [[Pipe alloc] init];
	p.numRows = pipeHeight;
	
	p.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"Pipe.tmx"];
	p.layer = [p.tileMap layerNamed:[NSString stringWithFormat:@"Pipe_%zu", p.numRows]];
	[p.layer removeFromParentAndCleanup:NO];
	
//	p.layer.contentSize = p.contentSize;
//	p.contentSize = CGSizeMake(kTileSize * 2, kTileSize * pipeHeight);
	
	return p;
}

//- (CGPoint)position {
//	return self.layer.position;
//}

- (void)setPosition:(CGPoint)position {
	_position = position;
	self.layer.position = CGPointMake(position.x - kTileSize, position.y - self.contentSize.height / 2);
}

- (CGSize)contentSize {
	CGSize size = self.layer.contentSize;
	size.height = self.numRows * kTileSize;
	return size;
}

//- (void)setContentSize:(CGSize)contentSize {
//	self.layer.contentSize = contentSize;
//}

- (void)updateStateWithDeltaTime:(ccTime)delta {
	if (!self.cleared) {
		if (self.position.x < ScreenHalfWidth()) {
			_cleared = YES;
			[GameManager sharedInstance].gameScore++;
		}
	}
}

@end
