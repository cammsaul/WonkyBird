//
//  AppDelegate.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright LuckyBird, Inc. 2014. All rights reserved.
//

@class NavController;

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	NavController *navController_;

	CCDirectorIOS	*__weak director_;							// weak ref
}

@property (nonatomic, strong) UIWindow *window;
@property (readonly) NavController *navController;
@property (weak, readonly) CCDirectorIOS *director;

@end
