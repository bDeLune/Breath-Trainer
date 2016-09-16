//
//  IIMyScene.m
//  ScrollKit
//
//  Created by Fille Åström on 20/11/13.
//

#import "IIMyScene.h"

typedef NS_ENUM(NSInteger, IIMySceneZPosition)
{
    kIIMySceneZPositionScrolling = 0,
    kIIMySceneZPositionVerticalAndHorizontalScrolling,
    kIIMySceneZPositionStatic,
};

@interface IIMyScene ()
//kIIMySceneZPositionScrolling
@property (nonatomic, weak) SKSpriteNode *spriteToScroll;

//kIIMySceneZPositionStatic
@property (nonatomic, weak) SKSpriteNode *spriteForStaticGeometry;

//kIIMySceneZPositionVerticalAndHorizontalScrolling
@property (nonatomic, weak) SKSpriteNode *spriteToHostHorizontalAndVerticalScrolling;
@property (nonatomic, weak) SKSpriteNode *spriteForHorizontalScrolling;
@property (nonatomic, weak) SKSpriteNode *spriteForVerticalScrolling;
@end

@implementation IIMyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        [self setAnchorPoint:(CGPoint){0,1}];
        SKSpriteNode *spriteToScroll = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteToScroll setAnchorPoint:(CGPoint){0,1}];
        NSLog(@"SETX: %@", kIIMySceneZPositionScrolling);
        [spriteToScroll setZPosition:kIIMySceneZPositionScrolling];
        //[spriteToScroll setZPosition:0];
        [self addChild:spriteToScroll];

        //Overlay sprite to make anchor point 0,0 (lower left, default for SK)
        SKSpriteNode *spriteForScrollingGeometry = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteForScrollingGeometry setAnchorPoint:(CGPoint){0,0}];
        [spriteForScrollingGeometry setPosition:(CGPoint){0, -size.height}];
        [spriteToScroll addChild:spriteForScrollingGeometry];

        SKSpriteNode *spriteForStaticGeometry = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteForStaticGeometry setAnchorPoint:(CGPoint){0,0}];
        [spriteForStaticGeometry setPosition:(CGPoint){0, -size.height}];
        [spriteForStaticGeometry setZPosition:kIIMySceneZPositionStatic];
        [self addChild:spriteForStaticGeometry];

        SKSpriteNode *spriteToHostHorizontalAndVerticalScrolling = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:size];
        [spriteToHostHorizontalAndVerticalScrolling setAnchorPoint:(CGPoint){0,0}];
        [spriteToHostHorizontalAndVerticalScrolling setPosition:(CGPoint){0, -size.height}];
        [spriteToHostHorizontalAndVerticalScrolling setZPosition:kIIMySceneZPositionVerticalAndHorizontalScrolling];
        [self addChild:spriteToHostHorizontalAndVerticalScrolling];

        CGSize upAndDownSize = size;
        upAndDownSize.width = 30;
        SKSpriteNode *spriteForVerticalScrolling = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:upAndDownSize];
        [spriteForVerticalScrolling setAnchorPoint:(CGPoint){0,0}];
        [spriteForVerticalScrolling setPosition:(CGPoint){0,30}];
        [spriteToHostHorizontalAndVerticalScrolling addChild:spriteForVerticalScrolling];

        CGSize leftToRightSize = size;
        leftToRightSize.height = 30;
        SKSpriteNode *spriteForHorizontalScrolling = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:leftToRightSize];
        [spriteForHorizontalScrolling setAnchorPoint:(CGPoint){0,0}];
        [spriteForHorizontalScrolling setPosition:(CGPoint){10,0}];
        [spriteToHostHorizontalAndVerticalScrolling addChild:spriteForHorizontalScrolling];


        //Set properties
        _contentSize = size;
        _spriteToScroll = spriteToScroll;
        _spriteForScrollingGeometry = spriteForScrollingGeometry;
        _spriteForStaticGeometry = spriteForStaticGeometry;
        _spriteToHostHorizontalAndVerticalScrolling = spriteToHostHorizontalAndVerticalScrolling;
        _spriteForVerticalScrolling = spriteForVerticalScrolling;
        _spriteForHorizontalScrolling = spriteForHorizontalScrolling;
        _contentOffset = (CGPoint){0,0};
        
        
    }
    return self;
}

-(void)didChangeSize:(CGSize)oldSize
{
    CGSize size = [self size];

    CGPoint lowerLeft = (CGPoint){0, -size.height};

    [self.spriteForStaticGeometry setSize:size];
    [self.spriteForStaticGeometry setPosition:lowerLeft];

    [self.spriteToHostHorizontalAndVerticalScrolling setSize:size];
    [self.spriteToHostHorizontalAndVerticalScrolling setPosition:lowerLeft];
}

-(void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(contentSize, _contentSize))
    {
        _contentSize = contentSize;
        [self.spriteToScroll setSize:contentSize];
        [self.spriteForScrollingGeometry setSize:contentSize];
        [self.spriteForScrollingGeometry setPosition:(CGPoint){0, -contentSize.height}];
        [self updateConstrainedScrollerSize];
    }
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    _contentOffset = contentOffset;
    contentOffset.x *= -1;
    [self.spriteToScroll setPosition:contentOffset];

    CGPoint scrollingLowerLeft = [self.spriteForScrollingGeometry convertPoint:(CGPoint){0,0} toNode:self.spriteToHostHorizontalAndVerticalScrolling];

    CGPoint horizontalScrollingPosition = [self.spriteForHorizontalScrolling position];
    horizontalScrollingPosition.y = scrollingLowerLeft.y;
    [self.spriteForHorizontalScrolling setPosition:horizontalScrollingPosition];

    CGPoint verticalScrollingPosition = [self.spriteForVerticalScrolling position];
    verticalScrollingPosition.x = scrollingLowerLeft.x;
    [self.spriteForVerticalScrolling setPosition:verticalScrollingPosition];
}

-(void)setContentScale:(CGFloat)scale;
{
    [self.spriteToScroll setScale:scale];
    [self updateConstrainedScrollerSize];
}

-(void)updateConstrainedScrollerSize
{

    CGSize contentSize = [self contentSize];
    CGSize verticalSpriteSize = [self.spriteForVerticalScrolling size];
    verticalSpriteSize.height = contentSize.height;
    [self.spriteForVerticalScrolling setSize:verticalSpriteSize];

    CGSize horizontalSpriteSize = [self.spriteForHorizontalScrolling size];
    horizontalSpriteSize.width = contentSize.width;
    [self.spriteForHorizontalScrolling setSize:horizontalSpriteSize];

    CGFloat xScale = [self.spriteToScroll xScale];
    CGFloat yScale = [self.spriteToScroll yScale];
    [self.spriteForVerticalScrolling setYScale:yScale];
    [self.spriteForVerticalScrolling setXScale:xScale];
    [self.spriteForHorizontalScrolling setXScale:xScale];
    [self.spriteForHorizontalScrolling setYScale:yScale];
    CGFloat xScaleReciprocal = 1.0/xScale;
    CGFloat yScaleReciprocal = 1/yScale;
    for (SKNode *node in [self.spriteForVerticalScrolling children])
    {
        [node setXScale:xScaleReciprocal];
        [node setYScale:yScaleReciprocal];
    }
    for (SKNode *node in [self.spriteForHorizontalScrolling children])
    {
        [node setXScale:xScaleReciprocal];
        [node setYScale:yScaleReciprocal];
    }

    [self setContentOffset:self.contentOffset];
}
/*
 *********
 **************
 *********
 */

@end
