//
//  GameManager.h
//  WonkyBird
//
//  Created by Cam Saul on 2/25/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Constants.h"

@interface GameManager : NSObject

+ (GameManager *)sharedInstance;

@property (nonatomic) GameState gameState;

@end
