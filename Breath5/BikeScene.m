
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define kBikeName  @"bike"
#define krightWall  @"rightwall"
#define  WHEEL_SIZE 15
#import "BikeScene.h"
#import "RMArrowNode.h"
#import "Globals.h"
#import "User.h"
#import "AGMovingNode.h"
@interface BikeScene()<SKPhysicsContactDelegate>

{
    float _velocity;
    gameDifficulty difficulty;
}
@property SKShapeNode  *ball;
@property SKSpriteNode *carBody;
@property SKShapeNode *carBodyShape;

@property BOOL drive;
@property float force;
@property float currentAngle;
@property float gravity;
@property float bestVelocity;

@property(nonatomic,unsafe_unretained)id<BikeSceneProtocol>gameDelegateRef;
@property(nonatomic,strong)NSMutableArray *contactQueue;
@property(nonatomic,strong)SKShapeNode  *slope;
@property(nonatomic,strong)SKShapeNode  *leftWheel;
@property(nonatomic,strong)SKShapeNode  *leftInnerNode;
@property(nonatomic,strong)SKShapeNode  *rightInnerNode;
@property(nonatomic,strong)SKShapeNode *rightWheel;
@property(nonatomic,strong)RMArrowNode  *arrow;
@property(nonatomic,strong)RMArrowNode  *arrowPct;

@property (nonatomic, strong) SKLabelNode *windLabel;
@property (nonatomic, strong) SKLabelNode *angleLabel;
@property(nonatomic,strong)SKEmitterNode *emitter;
@property int distanceOffset;
@property(nonatomic,weak)User  *currentUser;
@property (nonatomic,strong)SKAction *soundaction;
@property (nonatomic,strong)SKAction *soundactionEnd;
@property BOOL forward;
@property BOOL flapsforward;

@property int lapsHitX;
@property BOOL bellSoundIsPlaying;

@property int lastX;
@property(nonatomic,strong)AGMovingNode  *movingNode;
@property(nonatomic,strong)SKNode *myWorld;
@property(nonatomic,strong)SKPhysicsJointPin *jointA;
@property(nonatomic,strong)SKPhysicsJointPin *jointB;
@property float currentRotationAngle;
@property BOOL isMoving;

@end

@implementation BikeScene

static const u_int32_t kBikeCategory            = 0x1 << 0;
static const u_int32_t kRightWall    = 0x1 << 1;
static const u_int32_t karrowCategory               = 0x1 << 2;
//static const u_int32_t kSceneEdgeCategory          = 0x1 << 3;
//static const u_int32_t kInvaderFiredBulletCategory = 0x1 << 4;
-(void)playSuccess
{
    self.emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"]];
    //self.emitter.targetNode = self;
    // self.emitter.zPosition = 4.0;
    //self.emitter.particlePosition = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.emitter.particlePosition = self.carBody.position;

   // [self.emitter setZPosition:0];
    
   // self.physicsWorld.gravity=CGVectorMake(30, 30);
    
    
 //   int numChildren=(int)[self.children count];
   //[self insertChild:self.emitter atIndex:numChildren-1 ];
   
   
  

     [self.spriteForScrollingGeometry addChild:self.emitter];
      [self.emitter setZPosition:1002.0];
    
    self.soundactionEnd=[SKAction playSoundFileNamed:@"Cartoon_Finished_Melody.wav" waitForCompletion:YES];
    [self runAction:self.soundactionEnd completion:^{
        self.soundactionEnd=nil;
    }];
    
    if ([[_currentUser valueForKey:@"userHillType"]intValue]==hillTypeFlat) {
        //[self removeLandScape];
    }
   // self.spriteForScrollingGeometry.alpha=0.0;
    [self.carBody.physicsBody applyImpulse:CGVectorMake(100, 100)];
    [ self.emitter runAction:[SKAction fadeAlphaTo:0.1 duration:4] completion:^{
        
        self.paused=YES;
       
        [self.emitter removeFromParent];
        self.emitter=nil;
      // self.spriteForScrollingGeometry.alpha=1.0;
        if ([[_currentUser valueForKey:@"userHillType"]intValue]==hillTypeFlat) {
            [self createLandScape];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

                self.carBody.anchorPoint=CGPointMake(0, 0);
             [self.gameDelegateRef gameWon:self];
        });
        
        
    }];
    
    //self.paused=YES;

}
-(void)hidePctArrow:(BOOL)hide
{
    if (hide) {
        self.arrowPct.alpha=0.0f;
    }else
    {
        self.arrowPct.alpha=1.0f;
    }
}
-(void)resetDistance
{
    self.currentDistance=0;
   [self.spriteForScrollingGeometry addChild: [self addArrow]];
    
}
-(void)addArrowPct:(float)pct
{
   // User *user=[Globals sharedInstance]u

    float newx=self.lastArrowPoint.x*pct;
    float newy=self.lastArrowPoint.y*pct;
    
    CGPoint loc=CGPointMake(newx, newy);
    
    [self.spriteForScrollingGeometry addChild:[self addArrowPctNode:loc]];
    if (self.currentAngle==0.0) {
        //loc.y+=200;
    }
    self.arrowPct.position=loc;
    self.arrowPct.physicsBody=nil;
    
    
    
}

-(void)setArrowDistance:(CGPoint)point
{
    NSLog(@"Setting arrow point!");
    if (point.x==0) {
        [self.spriteForScrollingGeometry addChild:[self addArrow] ];
        return;
    }
    self.lastArrowPoint=point;
    self.arrow.position=self.lastArrowPoint;

}
-(void)setCurrentUser:(User *)user
{
    _currentUser=user;
}
-(void)addLabels
{
    float w=self.gravity*-1;
    self.windLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    self.windLabel.text = [NSString stringWithFormat:@"Wind  %0.1f",w];
    self.windLabel.fontSize = 20;
    self.windLabel.position = CGPointMake(100, 450);
    
    //[self addChild:self.windLabel];
    
    
    self.angleLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    self.angleLabel.text = [NSString stringWithFormat:@"Angle %0.1f",[self slopeAngle]*45];
    self.angleLabel.fontSize = 20;
    self.angleLabel.position = CGPointMake(100, 400);
    
    //[self addChild:self.angleLabel];

}
#pragma mark -
#pragma mark - Getters

-(float)strongestVelocity
{
    return self.bestVelocity * 127.0;
}
-(float)currentWind
{
    return self.gravity*-1;
}
-(float)slopeAngle
{
    return self.currentAngle;
}
-(int)bestDistance
{
    float xA=0;
    float xB=self.lastArrowPoint.x;
    
    float yB=self.lastArrowPoint.y;
    float yA=0;
    
    float a=xA-xB;
    float b=yA-yB;
    
    float a2=powf(a, 2);
    float b2=powf(b, 2);
    
    
    float c2= a2+b2;
    
    float c=sqrtf(c2);
    
   // NSLog(@"Distance = %f",(c- self.distanceOffset)-30);
    
    //30 == size of wheel
    return (c- self.distanceOffset)-30;
}
#pragma mark -
#pragma mark - Setters
-(void)gameDelegate:(id<BikeSceneProtocol>)gameDelegate
{
    self.gameDelegateRef=gameDelegate;
}
-(void)setVelocity:(float)velocity
{
    _velocity=velocity;
}
-(void)setAngle:(float)angle
{
    //0 - 1;

   // if (angle>self.currentAngle) {
    angle=angle*100;
    float amt=angle/100;
   // }
   // NSLog(@"%f",self.carBody.physicsBody.velocity.dx);
    if (self.carBody.physicsBody.velocity.dx!=0) {
       // return;
    }

    self.currentAngle=amt;
    [self runAction:[SKAction runBlock:^{
        [self updateSlope];
    }] completion:^{
    
        self.carBody.physicsBody.velocity=CGVectorMake(0, 0);
        self.carBody.position = CGPointMake(50, 200);
    }];
    
    
    
  
    


}
-(void)setWind:(float)wind

{
    self.physicsWorld.gravity = CGVectorMake(0.0f, wind*-1);

}
-(void)updateSlope
{
   // se
    //[self.carBody removeFromParent];
    CGPoint start=CGPointMake(0, 0);
   
    
    
    // double endX = cos(self.angle) * self.frame.size.width + start.x;
    // double endY = sin(self.angle) * self.frame.size.height + start.y;
    double endX = self.frame.size.width;
    double endY = self.frame.size.height *self.currentAngle;
    CGPoint end = CGPointMake(endX, endY);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, end.x, end.y);
    CGPathMoveToPoint(path, NULL, end.x, end.y);
    CGPathAddLineToPoint(path, NULL, self.size.width, 0);
    CGPathMoveToPoint(path, NULL, self.size.width,  0);
    CGPathAddLineToPoint(path, NULL, 0, 0);

    self.slope.path = path;
    [self.slope setStrokeColor:[UIColor blueColor]];
    [self.slope setLineWidth:10];
    //[self addChild:floor];
    //[self.slope setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromPath:path]];
    [self.slope setPhysicsBody:[SKPhysicsBody bodyWithEdgeChainFromPath:path]];

    [self.slope setName:@"floor"];
    self.slope.physicsBody.friction=1;
    

   // [self addChild:self.carBody];

}

#pragma mark -
#pragma mark - Contact
- (void)didBeginContact:(SKPhysicsContact *)contact
{
   // NSLog(@"Body A == %@",contact.bodyA);
   // NSLog(@"Body B == %@",contact.bodyB);
    //[self.contactQueue addObject:contact];

}
- (void)didEndContact:(SKPhysicsContact *)contact
{


}
-(void)processContactsForUpdate:(NSTimeInterval)currentTime {
    return;
   /* for (SKPhysicsContact* contact in [self.contactQueue copy]) {
        [self handleContact:contact];
        [self.contactQueue removeObject:contact];
    }*/
}

-(void)handleContact:(SKPhysicsContact*)contact {
    // Ensure you haven't already handled this contact and removed its nodes
   if (!contact.bodyA.node.parent || !contact.bodyB.node.parent) return;
    NSLog(@"%@",contact.bodyA);
    NSLog(@"%@",contact.bodyB);

    NSArray* nodeNames = @[contact.bodyA.node.name, contact.bodyB.node.name];
    
    if ([nodeNames containsObject:kBikeName] && [nodeNames containsObject:krightWall]) {

        NSLog(@"HIT THE RIGHT WALL");
       self.emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"]];
         self.emitter.targetNode = self;
         self.emitter.particlePosition = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        //self.paused=YES;
        self.physicsWorld.gravity=CGVectorMake(30, 30);
        [self addChild:self.emitter];
        [self runAction:[SKAction playSoundFileNamed:@"Crowd_cheer6.mp3" waitForCompletion:NO]];
        [self.carBody.physicsBody applyImpulse:CGVectorMake(100, 100)];

        [ self.emitter runAction:[SKAction fadeAlphaTo:0.1 duration:3] completion:^{
        
            self.paused=YES;
            [self.gameDelegateRef gameWon:self];


        }];
    }
    
    
    
    
}

#pragma mark -
#pragma mark - Setup

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
              /* [self.carBody runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                            [SKAction waitForDuration:3.0],
                                                                            [SKAction scaleTo:2.0 duration:2.0],
                                                                            [SKAction scaleTo:1.0 duration:2.0],
                                                                            ]]]];*/
        
      //  [self.carBody runAction:[SKAction scaleBy:0.5 duration:0.1]];
       // Vehicle  *v=[[Vehicle alloc]initWithPosition:CGPointMake(100, 400)];
       // [self addChild:v];
//        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];  //  Physics body of Scene
    }
    return self;
}
-(void)updateDifficulty:(int)theDifficulty
{
    switch (theDifficulty) {
        case userTypeSignifigant:
            difficulty=gameDifficultyEasy;
            break;
        case userTypeReduced:
            difficulty=gameDifficultMedium;
            
            break;
        case userTypeLittleReduced:
            difficulty=gameDifficultyHard;
            
            break;
    case userTypeNotReduced:
        difficulty=gameDifficultyVeryHard;
            
        default:
            break;
    }
}
-(void)setWindANdAngle
{
      //  self.currentAngle=[[[NSUserDefaults standardUserDefaults]valueForKey:@"angle"]floatValue];
    
    
    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            self.currentAngle=0.0;
            break;
        case hillTypeHill:
            self.currentAngle=0.5;

            break;
        case hillTypeMountain:
            self.currentAngle=0.9;

            break;
            
        default:
            break;
    }
    
        self.gravity=[[[NSUserDefaults standardUserDefaults]valueForKey:@"gravity"]floatValue];
        self.gravity=self.gravity*-1;
    
    
    
    
    switch ([[_currentUser valueForKey:@"userAbilityType"]intValue]) {
        case userTypeSignifigant:
            difficulty=gameDifficultyEasy;
            break;
        case userTypeReduced:
            difficulty=gameDifficultMedium;
            
            break;
        case userTypeLittleReduced:
            difficulty=gameDifficultyHard;
            
            break;
        case userTypeNotReduced:
        difficulty=gameDifficultyVeryHard;
        
        break;
        
        default:
            break;
    }

      //  difficulty=[[[NSUserDefaults standardUserDefaults]valueForKey:@"difficulty"]intValue];

    
    
}
-(void)setup
{
    [self setWindANdAngle];
    
  //  [self AGMovingNodeTest];

    self.physicsWorld.gravity = CGVectorMake(0.0f, self.gravity);
    self.physicsWorld.contactDelegate=self;
     self.contactQueue=[NSMutableArray new];
  
    [self createwall];
    [self.spriteForScrollingGeometry addChild:[self addArrow] ];

    [self.spriteForScrollingGeometry addChild:[self createSlope]];
   // [self createCircle];
   // [self.spriteForScrollingGeometry addChild:[self fireButtonNode]];
    self.force=0.1;
    _velocity=0.0;
    [self addLabels];
    [self.gameDelegateRef gameStarted:self];
    [self createCar];
    self.distanceOffset=self.arrow.position.x;
    self.forward=YES;
     self.soundaction=[SKAction playSoundFileNamed:@"Cartoon_Finished_bleep.wav" waitForCompletion:YES];
    self.lapsHitX=self.view.bounds.size.width-50;
  
}
- (SKNode*) createWheelWithRadius:(float)wheelRadius {
    CGRect wheelRect = CGRectMake(-wheelRadius, -wheelRadius, wheelRadius*2, wheelRadius*2);
    
    SKShapeNode* wheelNode = [[SKShapeNode alloc] init];
    wheelNode.path = [UIBezierPath bezierPathWithOvalInRect:wheelRect].CGPath;
    
    wheelNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:wheelRadius];
    [wheelNode setFillColor:[UIColor colorWithRed:255 green:153.0/255.0 blue:51.0/255.0 alpha:1]];
    SKShapeNode *positionMark = [SKShapeNode shapeNodeWithCircleOfRadius:6.0];
    positionMark.fillColor = [SKColor blackColor];
    positionMark.position = CGPointMake(0, -5);
    [wheelNode addChild:positionMark];
    [wheelNode setName:kBikeName];
    return wheelNode;
}


- (void) createCar2 {
    
    // Create the car
    self.carBody = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(60, 10)];
    self.carBody.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.carBody.size];
    self.carBody.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:self.carBody];
    UIImage* theImage = [UIImage imageNamed:@"Bike.png"];
    
    
    
    SKSpriteNode* theSprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:theImage]];
    
    theSprite.zRotation = M_PI/-4.0f;
    CGPoint  point=CGPointMake(0, 10);
    theSprite.position=point;
    
    [self.carBody addChild:theSprite];
    
    // Create the left wheel
    SKNode* leftWheelNode = [self createWheelWithRadius:16];
    leftWheelNode.position = CGPointMake(self.carBody.position.x-80, self.carBody.position.y);
    [self addChild:leftWheelNode];
    
    // Create the right wheel
    SKNode* rightWheelNode = [self createWheelWithRadius:16];
    rightWheelNode.position = CGPointMake(self.carBody.position.x+80, self.carBody.position.y);
    [self addChild:rightWheelNode];
    
    // Attach the wheels to the body
    CGPoint leftWheelPosition = leftWheelNode.position;
    CGPoint rightWheelPosition = rightWheelNode.position;
    
    SKPhysicsJointPin* leftPinJoint = [SKPhysicsJointPin jointWithBodyA:self.carBody.physicsBody bodyB:leftWheelNode.physicsBody anchor:leftWheelPosition];
    SKPhysicsJointPin* rightPinJoint = [SKPhysicsJointPin jointWithBodyA:self.carBody.physicsBody bodyB:rightWheelNode.physicsBody anchor:rightWheelPosition];
    
    [self.physicsWorld addJoint:leftPinJoint];
    [self.physicsWorld addJoint:rightPinJoint];
}
/*-(void)AGMovingNodeTest
{
    
    self.movingNode = [[AGMovingNode alloc] initWithPointsPerSecondSpeed:100.0];
    self.movingNode.name = @"background";
    [self.movingNode addChild:[SKSpriteNode spriteNodeWithImageNamed:@"landscape"] ];
    [self addChild:self.movingNode];
}*/
- (void)didFinishUpdate
{
    SKNode  *cam=[self childNodeWithName: @"//camera"];
    cam.position=self.carBody.position;
    [self centerOnNode: [self childNodeWithName: @"//camera"]];
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x, node.parent.position.y - cameraPositionInScene.y);
}
-(RMArrowNode*)addArrowPctNode:(CGPoint)location{

    if (self.arrowPct) {
        [self.arrowPct removeFromParent];
    }
    CGPoint start=CGPointMake(50, 0);
    CGPoint locations=CGPointMake(50,110);

    self.arrowPct =[RMArrowNode arrowNodeWithStartPoint:start
                                            endPoint:locations
                                           headWidth:10
                                          headLength:7
                                          headMargin:0
                                           tailWidth:5
                                          tailMargin:9
                                               color:[SKColor orangeColor]];
    self.arrowPct.name=@"arrowPCT";
    return self.arrowPct;

}
-(RMArrowNode*)addArrow{
    if (self.arrow) {
        [self.arrow removeFromParent];
    }
    
    if (self.arrowPct) {
        [self.arrowPct removeFromParent];
    }
    CGPoint start=CGPointMake(50, 0);
    CGPoint location=CGPointMake(50,100);
    self.lastArrowPoint=location;
    self.arrow =[RMArrowNode arrowNodeWithStartPoint:start
                                endPoint:location
                               headWidth:20
                              headLength:15
                              headMargin:0
                               tailWidth:8
                              tailMargin:18
                                   color:[SKColor yellowColor]];
    return self.arrow;

}
- (SKSpriteNode *)fireButtonNode
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"fireButton.png"];
    fireNode.position = CGPointMake(50,200);
    fireNode.name = @"fireButtonNode";//how the node is identified later
    fireNode.zPosition = 2.0;
    return fireNode;
}
-(void)createwall
{
    
    //Left
    
    CGMutablePathRef leftpath = CGPathCreateMutable();
    CGPathMoveToPoint(leftpath, NULL, 0, 0);
    CGPathAddLineToPoint(leftpath, NULL, 0, self.size.height);
    
    SKShapeNode *left = [SKShapeNode node];
    left.path = leftpath;
    [left setStrokeColor:[UIColor blackColor]];
    [left setPhysicsBody:[SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, self.size.height)]];
    [left setName:krightWall];
    [self.spriteForScrollingGeometry addChild:left];
    
    // Right
    
    
    CGMutablePathRef rightpath = CGPathCreateMutable();
    CGPathMoveToPoint(rightpath, NULL, self.size.width, 0);
    CGPathAddLineToPoint(rightpath, NULL, self.size.width, self.size.height);
    
    SKShapeNode *right = [SKShapeNode node];
    right.path = rightpath;
    [right setStrokeColor:[UIColor blackColor]];
    [right setPhysicsBody:[SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(self.size.width, 0) toPoint:CGPointMake(self.size.width, self.size.height)]];
    [right setName:krightWall];
    [self.spriteForScrollingGeometry addChild:right];

    right.physicsBody.categoryBitMask = kRightWall; // 3
    right.physicsBody.contactTestBitMask = kBikeCategory; // 4
    right.physicsBody.collisionBitMask = 0; // 5
    right.physicsBody.restitution=0;
    
    
    //ROOF
    
    CGMutablePathRef roofpath = CGPathCreateMutable();
    CGPathMoveToPoint(roofpath, NULL, 0, self.size.height);
    CGPathAddLineToPoint(roofpath, NULL, self.size.width, self.size.height);
    
    SKShapeNode *roof = [SKShapeNode node];
    roof.path = roofpath;
    [roof setStrokeColor:[UIColor blackColor]];
    [roof setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, self.frame.size.height, self.frame.size.width, 2)]];
     
     [roof setName:krightWall];
    [self.spriteForScrollingGeometry addChild:roof];
    
    roof.physicsBody.categoryBitMask = kRightWall; // 3
    roof.physicsBody.contactTestBitMask = kBikeCategory; // 4
    roof.physicsBody.collisionBitMask = 0; // 5
    roof.physicsBody.restitution=0;

    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            [self createLandScape];
            break;
        case hillTypeHill:
            
            break;
        case hillTypeMountain:
            
            break;
            
        default:
            break;
    }

}
-(void)createLandScape
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode * bg = [SKSpriteNode spriteNodeWithImageNamed:@"landscape"];
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.name = @"landscape";
        bg.zPosition = 0;//added
        [self.spriteForScrollingGeometry insertChild:bg atIndex:0];
    }
}
-(void)removeLandScape
{
    [self.spriteForScrollingGeometry enumerateChildNodesWithName:@"landscape" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
}
-(SKNode*)createSlope
{
    
    BOOL scaleDown=NO;
    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            scaleDown=YES;
            break;
        case hillTypeHill:
            
            break;
        case hillTypeMountain:
            
            break;
            
        default:
            break;
    }

    if (scaleDown==YES) {
        
            }
     CGPoint start=CGPointMake(0, 0);
   // NSLog(@"width == %f",self.frame.size.width);
   // NSLog(@"height == %f",self.frame.size.height);

   // double endX = cos(self.angle) * self.frame.size.width + start.x;
   // double endY = sin(self.angle) * self.frame.size.height + start.y;
    double endX = self.frame.size.width;
    double endY = self.frame.size.height *self.currentAngle;
    CGPoint end = CGPointMake(endX, endY);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, end.x, end.y);
    
    self.slope = [SKShapeNode node];
    self.slope.path = path;
    [self.slope setStrokeColor:[UIColor blueColor]];
    [self.slope setLineWidth:10];
    
       [self.slope setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromPath:path]];
    [self.slope setName:@"floor"];
    self.slope.physicsBody.friction=1;
    
    if (scaleDown==YES) {
        
    }


    return self.slope;
}
- (SKSpriteNode *)createFloor {
   SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:(CGSize){self.frame.size.width, 20}];
    
    [floor setAnchorPoint:(CGPoint){0, 1}];
    [floor setName:@"floor"];
    [floor setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:floor.frame]];
    floor.physicsBody.dynamic = NO;
    
    floor.physicsBody.usesPreciseCollisionDetection=YES;
    

    return floor;
    
}


- (SKShapeNode*) makeWheel:(CGPoint)position
{
      SKShapeNode *wheel=[SKShapeNode shapeNodeWithCircleOfRadius:WHEEL_SIZE];
    wheel.position=position;
    SKShapeNode *positionMark = [SKShapeNode shapeNodeWithCircleOfRadius:6.0];
    //255,153,51
    [wheel setFillColor:[UIColor colorWithRed:255 green:153.0/255.0 blue:51.0/255.0 alpha:1]];
    /*[wheel setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:WHEEL_SIZE]];
    wheel.physicsBody.allowsRotation=YES;
    wheel.physicsBody.usesPreciseCollisionDetection=NO;
    wheel.physicsBody.dynamic = YES;
    wheel.physicsBody.restitution = 0.0;
    wheel.physicsBody.affectedByGravity=YES;*/
    
    positionMark.fillColor = [SKColor blackColor];
    positionMark.name=@"ball";
     positionMark.position = CGPointMake(0, -5);
    [wheel addChild:positionMark];
    [wheel setName:kBikeName];
    

    return wheel;
}

- (SKShapeNode*) makeWheel
{
    SKShapeNode *wheel = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddArc(myPath, NULL, 0,0, 16, 0, M_PI*2, YES);
    wheel.path = myPath;
    [wheel setFillColor:[UIColor colorWithRed:255 green:153.0/255.0 blue:51.0/255.0 alpha:1]];
SKShapeNode *positionMark = [SKShapeNode shapeNodeWithCircleOfRadius:6.0];
    positionMark.fillColor = [SKColor blackColor];
    positionMark.position = CGPointMake(0, -5);
    [wheel addChild:positionMark];
    [wheel setName:kBikeName];

    return wheel;
}


- (void) createCar
{
    
    
    // 1. car body
   self.carBody = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(60, 4)];
    self.carBody.position = CGPointMake(50, 100);
    
    UIImage* theImage = [UIImage imageNamed:@"Bike.png"];
    
    
    
    SKSpriteNode* theSprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:theImage]];
   
    theSprite.zRotation = M_PI/-4.0f;
    CGPoint  point=CGPointMake(0, 10);
    theSprite.position=point;

    [self.carBody addChild:theSprite];
    self.carBody.anchorPoint=CGPointMake(0, 0);

    CGPoint  originalLeft=CGPointMake(self.carBody.position.x - self.carBody.size.width / 2, self.carBody.position.y-2);
    //CGPoint  newLeft= [self convertPoint:originalLeft toNode:self.spriteForScrollingGeometry];
    self.leftWheel = [self makeWheel:originalLeft];
    
    CGPoint  originalRight=CGPointMake(self.carBody.position.x + self.carBody.size.width / 2, self.carBody.position.y-2);
    //CGPoint  newRight= [self convertPoint:originalRight toNode:self.spriteForScrollingGeometry];
    self.rightWheel = [self makeWheel:originalRight];
    
    
    [self.spriteForScrollingGeometry addChild:self.carBody];
    [self.spriteForScrollingGeometry addChild:self.leftWheel];
    [self.spriteForScrollingGeometry addChild:self.rightWheel];

    
    [self.carBody setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(60, 4)]];
    
    [self.rightWheel setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:WHEEL_SIZE]];
    [self.leftWheel setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:WHEEL_SIZE]];
  
    
    //self.carBody.physicsBody.usesPreciseCollisionDetection = YES;
    //self.carBody.physicsBody.dynamic = YES;
   // self.carBody.physicsBody.restitution = 0.1;
   // self.carBody.physicsBody.affectedByGravity=NO;
   // self.carBody.color=[UIColor clearColor];
    [self.carBody setName:kBikeName];
    
    self.carBody.physicsBody.categoryBitMask = kBikeCategory; // 3
    self.carBody.physicsBody.contactTestBitMask = kRightWall; // 4
    self.carBody.physicsBody.collisionBitMask = 0; // 5
    
    
  

    self.jointA=[SKPhysicsJointPin jointWithBodyA:self.carBody.physicsBody bodyB:self.leftWheel.physicsBody anchor:CGPointMake(CGRectGetMidX(self.leftWheel.frame),CGRectGetMinY(self.leftWheel.frame))];
    
    self.jointB=[SKPhysicsJointPin jointWithBodyA:self.carBody.physicsBody bodyB:self.rightWheel.physicsBody anchor:CGPointMake(CGRectGetMidX(self.rightWheel.frame),CGRectGetMinY(self.rightWheel.frame))];
    
    [self.jointA setShouldEnableLimits:YES];
    [self.jointB setShouldEnableLimits:YES];
    [self.scene.physicsWorld addJoint:self.jointA];

    [self.physicsWorld addJoint: self.jointB];

   
    
    BOOL scaleDown=NO;
    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            scaleDown=YES;
            break;
        case hillTypeHill:
            
            break;
        case hillTypeMountain:
            
            break;
            
        default:
            break;
    }

    if (scaleDown==YES) {
        
        //self car:[SKAction scaleTo:<#(CGFloat)#> duration:<#(NSTimeInterval)#>]
        //[self.carBody runAction:[SKAction scaleBy:0.5 duration:0.3]];
       // [self.leftWheel runAction:[SKAction scaleBy:0.5 duration:0.5]];
       // [self.rightWheel runAction:[SKAction scaleBy:0.5 duration:0.7]];
       
        

    }
}

#pragma mark -
#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKSpriteNode * floor = (SKSpriteNode *)[self childNodeWithName:@"floor"];
        if (![floor containsPoint:location]) {
            //if (!self.ball) {
               // [self addChild:[self createBall:location]];

            //}
        }
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.spriteForScrollingGeometry];
    SKNode *node = [self.spriteForScrollingGeometry nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"fireButtonNode"]) {
        //do whatever...
        //  self.ball.physicsBody.velocity = CGVectorMake(0.1 * 400.0f, 0);
        self.drive=YES;
        _velocity=0.1;


    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"fireButtonNode"]) {
        //do whatever...
       // self.ball.physicsBody.velocity = CGVectorMake(0.1 * 400.0f, 0);
        // [self.carBody.physicsBody applyForce:CGVectorMake(10000, 10000)];
        // self.ball.physicsBody.velocity=CGVectorMake(100, 50);
        // self.carBody.physicsBody.velocity=CGVectorMake(0.1 * 400.0f, 0);
        //self.force+=0.2;
        self.drive=YES;
        _velocity=0.0;
        self.drive=NO;
    }

}

#pragma mark -
#pragma mark - Scene Delegates
- (CGPoint)pointAroundCircumferenceFromCenter:(CGPoint)center withRadius:(CGFloat)radius andAngle:(CGFloat)theta
{
    CGPoint point = CGPointZero;
    point.x = center.x + radius * cos(theta);
    point.y = center.y + radius * sin(theta);
    
    return point;
}
- (void)didSimulatePhysics {
    
    if (self.isMoving==NO) {
        return;
    }
    int amount=0;
    switch ([self.currentUser.userHillType intValue]) {
        case hillTypeFlat:
            amount=15;
            
            break;
        case hillTypeHill:
            amount=10;
            break;
            
        case hillTypeMountain:
            amount=5;
            break;
            
        default:
            break;
    }
    
    if (_forward==YES) {
        amount=amount*-1;
    }

    self.currentRotationAngle+=amount;
    if (self.currentRotationAngle>360) {
        self.currentRotationAngle=0;
    }
    if (self.currentRotationAngle<0) {
        self.currentRotationAngle=360;
    }
    [self.leftWheel enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        
       // SKAction *rotation = [SKAction rotateByAngle: M_PI/4.0 duration:0.1];
        //and just run the action
        
        //[node runAction: rotation];
        CGPoint center=CGPointMake(3,3);
        CGPoint point =[self pointAroundCircumferenceFromCenter:center withRadius:6 andAngle:DEGREES_TO_RADIANS(self.currentRotationAngle) ];
        node.position=point;
        
    
    }];
    
    [self.rightWheel enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        
        CGPoint center=CGPointMake(3,3);
        CGPoint point =[self pointAroundCircumferenceFromCenter:center withRadius:6 andAngle:DEGREES_TO_RADIANS(self.currentRotationAngle) ];
        node.position=point;
    
    }];
}

-(void)setStopVector
{
    _velocity=0.0;
    int amount=0;
    
    switch ([self.currentUser.userHillType intValue]) {
        case hillTypeFlat:
            amount=-200;
            
            break;
        case hillTypeHill:
            amount=-60;
            break;
            
        case hillTypeMountain:
            amount=-40;
            break;
            
        default:
            break;
    }
   // [self.carBody.physicsBody applyTorque:-5];
    [self.carBody.physicsBody applyImpulse:CGVectorMake(amount, amount)];
}
 
-(void)update:(NSTimeInterval)currentTime {
    self.lastX=self.carBody.position.x;
    
    BOOL scroll=NO;
    
    
    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            scroll=YES;
            break;
        case hillTypeHill:
            
            break;
        case hillTypeMountain:
            
            break;
            
        default:
            break;
    }


    if (scroll==YES) {
        if (self.leftWheel.position.x<80) {
           // self.leftWheel.position= CGPointMake(80, 0);

        }
        //if (self.leftWheel.position.x>=80) {
            
            if (self.rightWheel.position.x<=self.frame.size.width/2) {
                //NSLog(@" wheel %f ",self.rightWheel.position.x);
                //NSLog(@" wheel %f ",self.rightWheel.position.y);

               // NSLog(@" scroll y%f ",self.spriteForScrollingGeometry.position.y);
               // NSLog(@" scroll x%f ",self.spriteForScrollingGeometry.position.x);

                
                [self setContentOffset:CGPointMake(self.rightWheel.position.x-80, 0)];

            }
            
        //}
    }

    [self processContactsForUpdate:currentTime];
    [self checkBikeContraints];
    
    if (_velocity>self.bestVelocity) {
        self.bestVelocity=_velocity;
    }
    
   // _velocity+=0.0001;
    CGFloat rate = _velocity;
    
    //rate=0;
     
    switch (difficulty) {
        case gameDifficultyEasy:
            self.force=750;
            break;
        case gameDifficultMedium:
            self.force=550;

            break;
        
        case gameDifficultyHard:
            self.force=350;

            break;
        case gameDifficultyVeryHard:
        
        self.force=270;
        
        break;
        default:
            break;
    }
    
    if (rate==0) {
       // self.carBody.physicsBody.velocity.dx=0;
    }
    BOOL reduce=NO;
    
    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            //self.currentAngle=0.1;
            reduce=YES;
            break;
        case hillTypeHill:
            //return;
            
            break;
        case hillTypeMountain:
           // return;
            
            break;
            
        default:
            break;
    }

    
    CGVector relativeVelocity = CGVectorMake(self.force-self.carBody.physicsBody.velocity.dx, 1-self.carBody.physicsBody.velocity.dy);
  //  NSLog(@"%f",relativeVelocity.dy);
    if (_flapsforward==NO)
    {
        self.carBody.physicsBody.velocity=CGVectorMake(self.carBody.physicsBody.velocity.dx+relativeVelocity.dx*rate, self.carBody.physicsBody.velocity.dy+relativeVelocity.dy*rate);

    }else
    {
        self.physicsWorld.gravity = CGVectorMake(-0.0314f, self.gravity);

        self.carBody.physicsBody.velocity=CGVectorMake(self.carBody.physicsBody.velocity.dx-relativeVelocity.dx*rate, self.carBody.physicsBody.velocity.dy-relativeVelocity.dy*rate);

        //self.carBody.physicsBody.velocity=CGVectorMake(self.carBody.physicsBody.velocity.dx-relativeVelocity.dx*rate, self.carBody.physicsBody.velocity.dy-relativeVelocity.dy*rate);

    }
    
   // NSLog(@"Rate %f",rate);
    
    int  directionINT=self.carBody.physicsBody.velocity.dx;
    uint directionUint=directionINT;
   // NSLog(@"position == %f",self.carBody.position.x);
    
    if (rate!=0.0)
    {
        [self.gameDelegateRef gameDistance:self];

    }
    
    if (self.carBody.position.x>=self.currentDistance) {
        self.currentDistance=self.carBody.position.x;

    }
    if (directionINT>0) {
        self.forward=true;

        if (directionUint!=0) {
          //  NSLog(@"FORWARD");
            self.isMoving=YES;
        }else
        {
            self.isMoving=NO;
        }
    }else
    {
        self.forward=false;
        if (directionUint!=0) {
            self.isMoving=YES;

       // NSLog(@"BACKWARD");
            
            
        }else
        {
            self.isMoving=NO;

        }
        
    }
    
  //  [self checkLaps];
    [self.gameDelegateRef gameDuration:self];
    
   }

-(void)checkLaps
{
    switch ([[_currentUser valueForKey:@"userHillType"]intValue]) {
        case hillTypeFlat:
            //self.currentAngle=0.1;
            break;
        case hillTypeHill:
            return;

            break;
        case hillTypeMountain:
            return;

            break;
            
        default:
            break;
    }
    
    if (_flapsforward==YES) {
        if (self.carBody.position.x>=self.lapsHitX)
        {
            _flapsforward=NO;
            self.lapsHitX=50;
        }
    }else
    {
    
        if (self.carBody.position.x<=self.lapsHitX)
        {
            _flapsforward=YES;
            self.lapsHitX=self.view.bounds.size.width-50;
        }
    }
    
 

}
-(void)checkBikeContraints
{
    
    float x1=0;
    float x2=self.size.width;
    
    float y1=0;
    float y2=self.size.height*self.currentAngle;
    
    float slope= (y2-y1)/(x2-x1);
    
   // NSLog(@"CHECKING BIKE CONSTRAINTS");
    

    CGPoint  bikePos=self.carBody.position;
   // NSLog(@"Y == %f",bikePos.y);
    
    
    float mx= (slope*bikePos.x+self.carBody.frame.size.width+30);
    float ypos = mx+bikePos.x;
    
    
   // NSLog(@"ypos %f",ypos);
    if (ypos<0) {
        [self.carBody setPosition:CGPointMake(20, 200)];
        self.carBody.zRotation=0;
    }
    if (bikePos.y>self.frame.size.height+self.carBody.size.width/2)
    {
        //ADDED
        self.carBody.zRotation=0;
        self.physicsWorld.gravity=CGVectorMake(-100, -100);
        [self.carBody setPosition:CGPointMake(20, 200)];
    }
    
    CGPoint  arrowpoint=CGPointMake(self.carBody.position.x+50, mx-self.arrow.frame.size.height-30);
    
    if (arrowpoint.x>self.lastArrowPoint.x) {
        self.lastArrowPoint=arrowpoint;
        self.arrow.position=self.lastArrowPoint;
    }
    
    if (self.arrowPct.alpha>0) {
       
       /// NSLog(@"CHECKP1");
        
        
        if (self.carBody.position.x+50>=self.arrowPct.position.x) {
            
        //     NSLog(@"CHECKP2");
            
            if (self.soundaction) {
               // return;
            }
            
            if (self.forward==NO) {
                return;
            }
            if (self.bellSoundIsPlaying) {
                return;
            }
            
           // return;//remnove
            self.bellSoundIsPlaying=YES;

            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
             //NSLog(@"CHECKP3");
                
                if (!self.soundaction) {
                     NSLog(@"PLAYING SOUNDFILE");
                     self.soundaction=[SKAction playSoundFileNamed:@"Cartoon_Finished_bleep.wav" waitForCompletion:YES];
                    
                    [self runAction:self.soundaction completion:^{
                        self.soundaction=nil;
                    }];
                    
                    
                }
               
                [self runAction:self.soundaction completion:^{
                    self.soundaction=nil;
                    
                    //below was 3 secs
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    self.bellSoundIsPlaying=NO;
                    
                    });
                }];
            
            });//added parenthesis
            
           
        }
    }

   // NSLog(@"rotation == %f",self.carBody.zRotation);
    
}

 
 //-(void) update:(NSTimeInterval)currentTime
 //{
 //CGPoint pos = self.position;
 //pos.x += velocity.x;
 //pos.y += velocity.y;
 //self.position = pos;
 //}

/*-(void)update:(CFTimeInterval)currentTime {
    //NSLog(@"%f",currentTime);
    NSLog(@"X= %f",self.carBody.position.x);
    if (self.drive) {
        self.carBody.physicsBody.velocity=CGVectorMake(100, 0);

        
        
    }
    [self.carBody.physicsBody setFriction:1.0];
    //
    [self.carBody.physicsBody applyForce:CGVectorMake(cos(self.angle), sin(self.angle))];

   // [self.carBody.physicsBody applyForce:CGVectorMake(self.force*100, 0)];
    self.force-=0.01;
    if (self.force<0) {
        self.force=0;
    }
   
}*/


@end
