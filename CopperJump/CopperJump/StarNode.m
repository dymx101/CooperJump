//
//  StarNode.m
//  CopperJump
//
//  Created by Dong Yiming on 5/18/14.
//  Copyright (c) 2014 pengpai. All rights reserved.
//

#import "StarNode.h"

//@import AVFoundation;


@interface StarNode ()
{
    SKAction *_starSound;
}
@end



@implementation StarNode


- (id) init
{
    if (self = [super init]) {
        // Sound for when a star is collected
        _starSound = [SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO];
    }
    
    return self;
}


- (BOOL) collisionWithPlayer:(SKNode *)player
{
    // Boost the player up
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, player.physicsBody.velocity.dy / 2);
    
    
    // Play sound
    [self.parent runAction:_starSound];
    
    // Remove this star
    [self removeFromParent];
    
    // Award stars
    [GameState sharedInstance].stars += (_starType == STAR_NORMAL ? 1 : 5);
    
    // Award score
    [GameState sharedInstance].score += (_starType == STAR_NORMAL ? 20 : 100);
    
    // The HUD needs updating to show the new stars and score
    return YES;
}

@end
