//
//  StarNode.m
//  CopperJump
//
//  Created by Dong Yiming on 5/18/14.
//  Copyright (c) 2014 pengpai. All rights reserved.
//

#import "StarNode.h"

@implementation StarNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    // Boost the player up
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
    
    // Remove this star
    [self removeFromParent];
    
    // The HUD needs updating to show the new stars and score
    return YES;
}

@end
