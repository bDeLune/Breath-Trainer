#import <SpriteKit/SpriteKit.h>

@interface AGMovingNode : SKNode

@property float pointsPerSecondSpeed;

- (instancetype)initWithPointsPerSecondSpeed:(float)pointsPerSecondSpeed;
- (void)update:(NSTimeInterval)currentTime paused:(BOOL)paused;

@end
