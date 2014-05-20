//
//  GameState.h
//  CopperJump
//
//  Created by Dong Yiming on 5/20/14.
//  Copyright (c) 2014 pengpai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;
@property (nonatomic, assign) int stars;

+ (instancetype)sharedInstance;

- (void) saveState;

@end
