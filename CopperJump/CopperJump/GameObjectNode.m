//
//  GameObjectNode.m
//  CopperJump
//
//  Created by Dong Yiming on 5/18/14.
//  Copyright (c) 2014 pengpai. All rights reserved.
//

#import "GameObjectNode.h"

@implementation GameObjectNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    return NO;
}

- (void) checkNodeRemoval:(CGFloat)playerY
{
    if (playerY < self.position.y - 300.0f) {
        [self removeFromParent];
    }
}

@end
