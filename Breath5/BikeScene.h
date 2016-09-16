

#import <SpriteKit/SpriteKit.h>
#import "IIMyScene.h"

@class BikeScene;
@class User;
@protocol BikeSceneProtocol <NSObject>

-(void)gameWon:(BikeScene*)bikeScene;
-(void)gameStarted:(BikeScene*)bikeScene;
-(void)gameEnded:(BikeScene*)bikeScene;
-(void)gameDistance:(BikeScene*)bikeScene;
-(void)gameDuration:(BikeScene*)bikeScene;
-(void)gameAttemptEnded:(BikeScene*)bikeScene;
-(void)gamePosX:(int)pos;
@end

@interface BikeScene : IIMyScene
-(void)setup;
-(void)setAngle:(float)angle;
-(void)setWind:(float)wind;
-(void)setVelocity:(float)velocity;

-(void)gameDelegate:(id<BikeSceneProtocol>)gameDelegate;
-(float)bestVelocity;
-(float)currentWind;
-(float)slopeAngle;
-(int)bestDistance;
@property(nonatomic)CGPoint lastArrowPoint;


-(void)setCurrentUser:(User*)user;
-(void)updateDifficulty:(int)theDifficulty;


-(void)setArrowDistance:(CGPoint)point;
@property (nonatomic)float currentDistance;
-(void)addArrowPct:(float)pct;
-(void)resetDistance;
-(void)setStopVector;
-(void)hidePctArrow:(BOOL)hide;
-(void)playSuccess;

-(void)setContentScale:(CGFloat)scale;
-(void)setContentOffset:(CGPoint)contentOffset;
//@property(nonatomic,unsafe_unretained)id<BikeSceneProtocol>gamedelegate;
@property BOOL isBlowing;
@end
