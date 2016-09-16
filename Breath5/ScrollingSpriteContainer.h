//
//  ScrollingSpriteContainer.h
//  Breath5
//
//  Created by barry on 22/10/2015.
//  Copyright © 2015 rocudo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ScrollingSpriteContainer : SKSpriteNode
@property(nonatomic,strong)SKSpriteNode  *carBody;
-(void)makeCar;
@end
