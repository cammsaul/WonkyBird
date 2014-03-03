//
//  GameKitManager.h
//  WonkyBird
//
//  Created by Cam Saul on 3/2/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <ExpaPlatform/Components/XSingleton.h>

@interface GameKitManager : XSingleton

@property (nonatomic, readonly) BOOL userIsAuthenticated;

- (void)showLeaderboard; ///< Show the main game leaderboard

- (void)reportScoresForGameOver; ///< call this method on game over to report scores

@end
