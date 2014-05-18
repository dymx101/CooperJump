//
//  CJMyScene.m
//  CopperJump
//
//  Created by Dong Yiming on 5/18/14.
//  Copyright (c) 2014 pengpai. All rights reserved.
//

#import "CJMyScene.h"

@interface CJMyScene ()
{
    // Layered Nodes
    SKNode *_backgroundNode;
    SKNode *_midgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudNode;
    
    // Player
    SKNode *_player;
}
@end

@implementation CJMyScene

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // Create the game nodes
        // Background
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
        
        // Foreground
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        // Add the player
        _player = [self createPlayer];
        [_foregroundNode addChild:_player];
        
    }
    return self;
}

- (SKNode *) createBackgroundNode
{
    // 1
    // Create the node
    SKNode *backgroundNode = [SKNode node];
    
    // 2
    // Go through images until the entire background is built
    for (int nodeCount = 0; nodeCount < 20; nodeCount++) {
        // 3
        NSString *backgroundImageName = [NSString stringWithFormat:@"Background%02d", nodeCount+1];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];
        // 4
        node.anchorPoint = CGPointMake(0.5f, 0.0f);
        node.position = CGPointMake(160.0f, nodeCount*64.0f);
        // 5
        [backgroundNode addChild:node];
    }
    
    // 6
    // Return the completed background node
    return backgroundNode;
}

- (SKNode *) createPlayer
{
    SKNode *playerNode = [SKNode node];
    [playerNode setPosition:CGPointMake(160.0f, 80.0f)];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
    [playerNode addChild:sprite];
    
    return playerNode;
}

@end
