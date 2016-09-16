#import "AGMovingNode.h"

@implementation AGMovingNode
{
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _deltaTime;
    
}

- (instancetype)initWithPointsPerSecondSpeed:(float)pointsPerSecondSpeed {
    if (self = [super init]) {
        self.pointsPerSecondSpeed = pointsPerSecondSpeed;
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime paused:(BOOL)paused {
    if (paused) {
        _lastUpdateTime = 0;
        return;
    }
    //To compute velocity we need delta time to multiply by points per second
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    CGPoint bgVelocity = CGPointMake(-self.pointsPerSecondSpeed, 0.0);
    CGPoint amtToMove = CGPointMake(bgVelocity.x * _deltaTime, bgVelocity.y * _deltaTime);
    self.position = CGPointMake(self.position.x+amtToMove.x, self.position.y+amtToMove.y);
}
@end
