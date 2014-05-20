//
//  CJMyScene.m
//  CopperJump
//
//  Created by Dong Yiming on 5/18/14.
//  Copyright (c) 2014 pengpai. All rights reserved.
//

#import "CJMyScene.h"
#import "StarNode.h"
#import "PlatformNode.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer   = 0x1 << 0,
    CollisionCategoryStar     = 0x1 << 1,
    CollisionCategoryPlatform = 0x1 << 2,
};

@import CoreMotion;

@interface CJMyScene () <SKPhysicsContactDelegate>
{
    // Layered Nodes
    SKNode *_backgroundNode;
    SKNode *_midgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudNode;
    
    // Player
    SKNode *_player;
    
    // Tap To Start node
    SKSpriteNode *_tapToStartNode;
    
    // Height at which level ends
    int _endLevelY;
    
    // Motion manager for accelerometer
    CMMotionManager *_motionManager;
    
    // Acceleration value from accelerometer
    CGFloat _xAcceleration;
}
@end

@implementation CJMyScene

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // Set contact delegate
        self.physicsWorld.contactDelegate = self;
        
        // Add some gravity
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
        
        // Create the game nodes
        // Background
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
        
        // Midground
        _midgroundNode = [self createMidgroundNode];
        [self addChild:_midgroundNode];
        
        // Foreground
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        // HUD
        _hudNode = [SKNode node];
        [self addChild:_hudNode];
        
        
        // Load the level
        NSString *levelPlist = [[NSBundle mainBundle] pathForResource: @"Level01" ofType: @"plist"];
        NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:levelPlist];
        
        // Height at which the player ends the level
        _endLevelY = [levelData[@"EndY"] intValue];
        
        
        
        // Add the platforms
        NSDictionary *platforms = levelData[@"Platforms"];
        NSDictionary *platformPatterns = platforms[@"Patterns"];
        NSArray *platformPositions = platforms[@"Positions"];
        for (NSDictionary *platformPosition in platformPositions) {
            CGFloat patternX = [platformPosition[@"x"] floatValue];
            CGFloat patternY = [platformPosition[@"y"] floatValue];
            NSString *pattern = platformPosition[@"pattern"];
            
            // Look up the pattern
            NSArray *platformPattern = platformPatterns[pattern];
            for (NSDictionary *platformPoint in platformPattern) {
                CGFloat x = [platformPoint[@"x"] floatValue];
                CGFloat y = [platformPoint[@"y"] floatValue];
                PlatformType type = [platformPoint[@"type"] intValue];
                
                PlatformNode *platformNode = [self createPlatformAtPosition:CGPointMake(x + patternX, y + patternY)
                                                                     ofType:type];
                [_foregroundNode addChild:platformNode];
            }
        }
        
        // Add the stars
        NSDictionary *stars = levelData[@"Stars"];
        NSDictionary *starPatterns = stars[@"Patterns"];
        NSArray *starPositions = stars[@"Positions"];
        for (NSDictionary *starPosition in starPositions) {
            CGFloat patternX = [starPosition[@"x"] floatValue];
            CGFloat patternY = [starPosition[@"y"] floatValue];
            NSString *pattern = starPosition[@"pattern"];
            
            // Look up the pattern
            NSArray *starPattern = starPatterns[pattern];
            for (NSDictionary *starPoint in starPattern) {
                CGFloat x = [starPoint[@"x"] floatValue];
                CGFloat y = [starPoint[@"y"] floatValue];
                StarType type = [starPoint[@"type"] intValue];
                
                StarNode *starNode = [self createStarAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
                [_foregroundNode addChild:starNode];
            }
        }
        
        // Add the player
        _player = [self createPlayer];
        [_foregroundNode addChild:_player];
        
        
        // Tap to Start
        _tapToStartNode = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
        _tapToStartNode.position = CGPointMake(160, 280.0f);
        [_hudNode addChild:_tapToStartNode];
        
        
        // CoreMotion
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 // 3
                                                 CMAcceleration acceleration = accelerometerData.acceleration;
                                                 // 4
                                                 _xAcceleration = (acceleration.x * 0.75) + (_xAcceleration * 0.25);
                                             }];
        
    }
    return self;
}

- (SKNode *) createBackgroundNode
{
    // Create the node
    SKNode *backgroundNode = [SKNode node];
    
    // Go through images until the entire background is built
    for (int nodeCount = 0; nodeCount < 20; nodeCount++) {

        NSString *backgroundImageName = [NSString stringWithFormat:@"Background%02d", nodeCount+1];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];

        node.anchorPoint = CGPointMake(0.5f, 0.0f);
        node.position = CGPointMake(160.0f, nodeCount*64.0f);

        [backgroundNode addChild:node];
    }
    

    // Return the completed background node
    return backgroundNode;
}

- (SKNode *) createPlayer
{
    SKNode *playerNode = [SKNode node];
    [playerNode setPosition:CGPointMake(160.0f, 7000.0f)];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
    [playerNode addChild:sprite];
    
    

    playerNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    playerNode.physicsBody.dynamic = NO;
    playerNode.physicsBody.allowsRotation = NO;

    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    

    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform;
    
    return playerNode;
}

- (StarNode *) createStarAtPosition:(CGPoint)position ofType:(StarType)type
{
    StarNode *node = [StarNode node];
    [node setPosition:position];
    [node setName:@"NODE_STAR"];
    
    [node setStarType:type];
    SKSpriteNode *sprite;
    if (type == STAR_SPECIAL) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"StarSpecial"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
    }
    [node addChild:sprite];
    
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    
    node.physicsBody.dynamic = NO;
    
    node.physicsBody.categoryBitMask = CollisionCategoryStar;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}

- (PlatformNode *) createPlatformAtPosition:(CGPoint)position ofType:(PlatformType)type
{
    PlatformNode *node = [PlatformNode node];
    [node setPosition:position];
    [node setName:@"NODE_PLATFORM"];
    [node setPlatformType:type];
    
    SKSpriteNode *sprite;
    if (type == PLATFORM_BREAK) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"PlatformBreak"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Platform"];
    }
    [node addChild:sprite];
    
    if (type == PLATFORM_BREAK) {
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    } else {
        node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width / 2];
    }
    
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = CollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}


- (SKNode *)createMidgroundNode
{
    // Create the node
    SKNode *midgroundNode = [SKNode node];
    
    // Add some branches to the midground
    for (int i=0; i<10; i++) {
        NSString *spriteName;

        int r = arc4random() % 2;
        if (r > 0) {
            spriteName = @"BranchRight";
        } else {
            spriteName = @"BranchLeft";
        }

        SKSpriteNode *branchNode = [SKSpriteNode spriteNodeWithImageNamed:spriteName];
        branchNode.position = CGPointMake(160.0f, 500.0f * i);
        [midgroundNode addChild:branchNode];
    }
    
    // Return the completed background node
    return midgroundNode;	
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If we're already playing, ignore touches
    if (_player.physicsBody.dynamic) return;
    
    // Remove the Tap to Start node
    [_tapToStartNode removeFromParent];
    
    // Start the player by putting them into the physics simulation
    _player.physicsBody.dynamic = YES;

    [_player.physicsBody applyImpulse:CGVectorMake(0.0f, 10.0f)];
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    BOOL updateHUD = NO;
    
 
    SKNode *other = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    
    updateHUD = [(GameObjectNode *)other collisionWithPlayer:_player];
    
    // Update the HUD if necessary
    if (updateHUD) {
        // 4 TODO: Update HUD in Part 2
    }
}

- (void) update:(CFTimeInterval)currentTime {
    // Calculate player y offset
    if (_player.position.y > 200.0f) {
        _backgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/10));
        _midgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/4));
        _foregroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
    }
}

- (void) didSimulatePhysics
{
    // Set velocity based on x-axis acceleration
    _player.physicsBody.velocity = CGVectorMake(_xAcceleration * 400.0f, _player.physicsBody.velocity.dy);
    

    // Check x bounds
    if (_player.position.x < -20.0f) {
        _player.position = CGPointMake(340.0f, _player.position.y);
    } else if (_player.position.x > 340.0f) {
        _player.position = CGPointMake(-20.0f, _player.position.y);
    }
    return;
}

@end
