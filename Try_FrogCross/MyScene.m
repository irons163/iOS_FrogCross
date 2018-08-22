//
//  MyScene.m
//  Try_Touch_Bugs
//
//  Created by irons on 2015/5/21.
//  Copyright (c) 2015年 ___FULLUSERNAME___. All rights reserved.
//

#import "MyScene.h"
#import "TextureHelper.h"
#import "CommonUtil.h"
#import "FrogUtil.h"
#import "MovingObjectUtil.h"
#import "CarUtil.h"
#import "WoodUtil.h"
#import "BoatUtil.h"
#import "BitmapUtil.h"

@implementation MyScene{
    
    int currentGameLevel;
//    Handler handler = new Handler();
    bool isGameRun;
    NSMutableArray* carUtils;
    NSMutableArray* woodUtils;
    NSMutableArray* boatUtils;
    
    NSMutableArray* carLines;
    NSMutableArray* woodLines;
    NSMutableArray* boatLines;
    
    int frogStartX;
    int frogStartY;
    
    NSMutableArray * goals;
    
    FrogUtil* frogUtil;
    
    ///////////////////
    
    int gameLevel;
    bool isTouchAble;
    int gamePointX;
    int gameScore;
    bool isRandomCatTexturesRepeat;
    
    SKSpriteNode * backgroundNode;
    NSArray * currentCatTextures;
    
    NSMutableArray * bugs;
    NSMutableArray * explodePool;
    
    NSArray * explodeTextures;
    
    SKSpriteNode * gamePointSingleNode, *gamePointTenNode, *gamePointHunNode, *gamePointTHUNode;
}

static const int CAR_LINE_NUM = 3;
static const int WOOD_LINE_NUM = 1;
static const int BOAT_LINE_NUM = 1;
static const int TOTAL_MOVING_OBJECT_LINE_NUM = CAR_LINE_NUM+WOOD_LINE_NUM+BOAT_LINE_NUM;
static const int RELEX_LINE_NUM = 2;
static const int GOAL_LINE_NUM = 1;
static const int TOTAL_LINE_NUM = TOTAL_MOVING_OBJECT_LINE_NUM + RELEX_LINE_NUM + GOAL_LINE_NUM;
static const int START_LINE_POSITION = TOTAL_LINE_NUM - 1;
static const int MID_RELEX_LINE_POSITION = WOOD_LINE_NUM + BOAT_LINE_NUM + GOAL_LINE_NUM;
static int RELEX_LINE_POSITIONS[] = {START_LINE_POSITION, MID_RELEX_LINE_POSITION};

static const int CAR_MOVE_SPEEDX = 3;
static const int WOOD_MOVE_SPEEDX = 2;
static const int BOAT_MOVE_SPEEDX = 1;

static int MOVEX_DISTANCE;
static int LINE_DISTANCE;
static int FrogMoveX;
static int FrogMoveY;

static const int HOLE_NUM = 5;
static int HOLE_WIDTH;

-(void)initGame{
    currentGameLevel = 1;
    isGameRun = true;
    carUtils = [NSMutableArray array];
    woodUtils = [NSMutableArray array];
    boatUtils = [NSMutableArray array];
    carLines = [NSMutableArray arrayWithCapacity:CAR_LINE_NUM];
    woodLines = [NSMutableArray arrayWithCapacity:CAR_LINE_NUM];
    boatLines = [NSMutableArray arrayWithCapacity:CAR_LINE_NUM];
    CommonUtil *commonUtil = [CommonUtil sharedInstance];
    frogStartY = (int) (commonUtil.screenHeight/4.0*3/8*START_LINE_POSITION);
    goals = [NSMutableArray array];
    
    MOVEX_DISTANCE = (int) (commonUtil.screenWidth/9.0);
    LINE_DISTANCE = (int) (commonUtil.screenHeight/4.0*3/8*1);
    FrogMoveX = MOVEX_DISTANCE;
    FrogMoveY = LINE_DISTANCE;
    HOLE_WIDTH = MOVEX_DISTANCE;
    currentLife = MAX_LIFE;
}

const static int EXPLODE_ZPOSITION = 2;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [TextureHelper initTextures];
        [TextureHelper initCatTextures];
        
        bugs = [NSMutableArray array];
        explodePool = [NSMutableArray array];
        
        [self checkIsRandomCatTexturesRepeat];
        [self randomCurrentCatTextures];
        
        isTouchAble = true;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
        
        int r = arc4random_uniform(15);
        
        self.backgroundNode = [SKSpriteNode spriteNodeWithTexture:[TextureHelper bgTextures][r]];
        CGSize backgroundSize = CGSizeMake(self.frame.size.width, self.frame.size.height                                                                                                                                                                                                                                                                                                                         );
        
        self.backgroundNode.size = backgroundSize;
        
        self.backgroundNode.anchorPoint = CGPointMake(0, 0);
        
        self.backgroundNode.position = CGPointMake(0, 0);
        
//        self.backgroundNode.zPosition = backgroundLayerZPosition;
        
        [self addChild:self.backgroundNode];
        
        int gamePointNodeWH = 30;
        
        gamePointX = self.frame.size.width/4;
        int gamePointY = self.frame.size.height*6/8.0;
        //        int gamePointY = self.frame.size.height - 50;
        
        gamePointSingleNode = [SKSpriteNode spriteNodeWithTexture:[self getTimeTexture:gameScore%10]];
        gamePointSingleNode.anchorPoint = CGPointMake(0, 0);
        gamePointSingleNode.size = CGSizeMake(gamePointNodeWH, gamePointNodeWH);
        gamePointSingleNode.position = CGPointMake(gamePointX, gamePointY);
        //        gamePointSingleNode.zPosition = backgroundLayerZPosition;
        
        gamePointTenNode = [SKSpriteNode spriteNodeWithTexture:[self getTimeTexture:(gameScore)/10]];
        gamePointTenNode.anchorPoint = CGPointMake(0, 0);
        gamePointTenNode.size = CGSizeMake(gamePointNodeWH, gamePointNodeWH);
        gamePointTenNode.position = CGPointMake(gamePointX - gamePointNodeWH, gamePointY);
        //        gamePointTenNode.zPosition = backgroundLayerZPosition;
        
        
        gamePointHunNode = [SKSpriteNode spriteNodeWithTexture:[self getTimeTexture:(gameScore)/100]];
        gamePointHunNode.anchorPoint = CGPointMake(0, 0);
        gamePointHunNode.size = CGSizeMake(gamePointNodeWH, gamePointNodeWH);
        gamePointHunNode.position = CGPointMake(gamePointX - gamePointNodeWH*2, gamePointY);
        
        gamePointTHUNode = [SKSpriteNode spriteNodeWithTexture:[self getTimeTexture:(gameScore)/10]];
        gamePointTHUNode.anchorPoint = CGPointMake(0, 0);
        gamePointTHUNode.size = CGSizeMake(gamePointNodeWH, gamePointNodeWH);
        gamePointTHUNode.position = CGPointMake(gamePointX - gamePointNodeWH*3, gamePointY);
        
        [self addChild:gamePointSingleNode];
        [self addChild:gamePointTenNode];
        [self addChild:gamePointHunNode];
        [self addChild:gamePointTHUNode];
        
        [self autoCreateBugs];
        
        [self setBgByGameLevel];
        
        [self initExplodeTextures];
    }
    return self;
}

-(void)initExplodeTextures{
    explodeTextures = [TextureHelper getTexturesWithSpriteSheetNamed:@"explode" withinNode:nil sourceRect:CGRectMake(0, 0, 500, 500) andRowNumberOfSprites:1 andColNumberOfSprites:5];
}

-(void) checkIsRandomCatTexturesRepeat{
    int r = arc4random_uniform(2);
    if (r == 0) {
        isRandomCatTexturesRepeat = false;
    }else{
        isRandomCatTexturesRepeat = true;
    }
}

-(void) randomCurrentCatTextures{
    int r = arc4random_uniform(5);
    
    switch (r) { 
        case 0:
            currentCatTextures = [TextureHelper cat1Textures];
            break;
        case 1:
            currentCatTextures = [TextureHelper cat2Textures];
            break;
        case 2:
            currentCatTextures = [TextureHelper cat3Textures];
            break;
        case 3:
            currentCatTextures = [TextureHelper cat4Textures];
            break;
        case 4:
            currentCatTextures = [TextureHelper cat5Textures];
            break;
        default:
            break;
    }
}

-(void)setBgByGameLevel{
    backgroundNode.texture = [TextureHelper bgTextures][gameLevel];
}

-(void)autoCreateBugs{
    SKAction * createTimer;
    createTimer = [SKAction runBlock:^{
        [self createBugs];
    }];
    SKAction * wait;
    wait = [SKAction waitForDuration:2.0];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[createTimer, wait]]]];
}

-(void)createBugs{
    if(isRandomCatTexturesRepeat){
        [self randomCurrentCatTextures];
    }
    SKSpriteNode * bug = [SKSpriteNode spriteNodeWithTexture:currentCatTextures[0]];
    bug.position = CGPointMake(100, 100);
    bug.size = CGSizeMake(50, 50);
    [self addChild:bug];
    [bugs addObject:bug];
    [self move:bug];
    [self runMovementAction:bug];
}

#define ARC4RANDOM_MAX 0x100000000

-(void)move:(SKSpriteNode*)bug{
    float radians = ((float)arc4random() / ARC4RANDOM_MAX) * (M_PI*2-0) + 0;
    float r = 40;
    CGFloat dx = r * cos (radians);
    CGFloat dy = r * sin (radians);
    
    if((bug.position.x - bug.size.width/2.0f) + dx < 0){
        dx = -dx;
    }else if((bug.position.x + bug.size.width/2.0f) + dx > self.size.width){
        dx = -dx;
    }
    
    if((bug.position.y - bug.size.height/2.0f) + dy < 0){
        dy = -dy;
    }else if((bug.position.y + bug.size.height/2.0f) + dy > self.size.height){
        dy = -dy;
    }
    
    SKAction * action;
    action = [SKAction moveByX:dx y:dy duration:1.0];
    SKAction * wait;
    wait = [SKAction waitForDuration:2.0];
    SKAction * end;
    end = [SKAction runBlock:^{
        [self move:bug];
    }];
    
    [bug runAction:[SKAction sequence:@[action, wait, end]]];
}

-(void)runMovementAction:(SKSpriteNode*)bug{
    SKAction * movementAction = [SKAction animateWithTextures:@[currentCatTextures[0],currentCatTextures[1]] timePerFrame:0.2];
    [bug runAction:[SKAction repeatActionForever:movementAction]];
}




static NSMutableArray* MovingObjectLinesTop;
//	public static final int CAR_LINE1_TOP = (int) (CommonUtil.screenHeight/4.0*3/8*6);
//	public static final int CAR_LINE2_TOP = (int) (CommonUtil.screenHeight/4.0*3/8*5);
//	public static final int CAR_LINE3_TOP = (int) (CommonUtil.screenHeight/4.0*3/8*4);
//	public static final int WOOD_LINE_TOP = (int) (CommonUtil.screenHeight/4.0*3/8*2);
//	public static final int BOAT_LINE_TOP = (int) (CommonUtil.screenHeight/4.0*3/8*1);

-(void)initGameView{
//    MovingObjectLinesTop = int[TOTAL_MOVING_OBJECT_LINE_NUM];
    MovingObjectLinesTop = [NSMutableArray array];
    for(int i=GOAL_LINE_NUM, movingObjectLinesPosition=0; i< TOTAL_LINE_NUM; i++, movingObjectLinesPosition++){
//    Log.e("a", CommonUtil.screenHeight/4.0*3/(TOTAL_LINE_NUM)*i+"");
        
        for(int i = 0; i < sizeof(RELEX_LINE_POSITIONS); i++){
        if(i == relexLinePosition){
            movingObjectLinesPosition--;
//            continue exit;
        }
    }
    MovingObjectLinesTop[movingObjectLinesPosition] = (int) (CommonUtil.screenHeight/4.0*3/((TOTAL_LINE_NUM))*i);
}
}

-(void)gameView {
////    super(context, attrs);
//    // TODO Auto-generated constructor stub
//    MovingObjectLinesTop = new int[TOTAL_MOVING_OBJECT_LINE_NUM];
//    exit: for(int i=GOAL_LINE_NUM, movingObjectLinesPosition=0; i< TOTAL_LINE_NUM; i++, movingObjectLinesPosition++){
////        Log.e("a", CommonUtil.screenHeight/4.0*3/(TOTAL_LINE_NUM)*i+"");
//        for(int relexLinePosition : RELEX_LINE_POSITIONS){
//            if(i == relexLinePosition){
//                movingObjectLinesPosition--;
//                continue exit;
//            }
//        }
//        MovingObjectLinesTop[movingObjectLinesPosition] = (int) (CommonUtil.screenHeight/4.0*3/((TOTAL_LINE_NUM))*i);
//    }
    
    for(int i=0; i<CAR_LINE_NUM; i++){
//        carUtils = new ArrayList<MovingObjectUtil>();
//        carUtils.add(new CarUtil(-BitmapUtil.carBitmap.getWidth(), MovingObjectLinesTop[MovingObjectLinesTop.length-1-i], CAR_MOVE_SPEEDX));
//        carLines.add(carUtils);
        carUtils = [NSMutableArray array];
//        carUtils.add(new CarUtil(-BitmapUtil.carBitmap.getWidth(), MovingObjectLinesTop[MovingObjectLinesTop.length-1-i], CAR_MOVE_SPEEDX));
        [CarUtil creataeCarUtilWithWidth:-BitmapUtil.carBitmap.width withHeight:MovingObjectLinesTop[MovingObjectLinesTop.length-1-i], CAR_MOVE_SPEEDX];
        [carUtils addObject:CarUtil], CAR_MOVE_SPEEDX));
        [carLines addObject:carUtils];
    }
    for(int i=0; i<WOOD_LINE_NUM; i++){
        woodUtils = new ArrayList<MovingObjectUtil>();
        woodUtils.add(new WoodUtil(-BitmapUtil.carBitmap.getWidth(), MovingObjectLinesTop[MovingObjectLinesTop.length-1-CAR_LINE_NUM-i], WOOD_MOVE_SPEEDX));
        woodLines.add(woodUtils);
    }
    for(int i=0; i<BOAT_LINE_NUM; i++){
        boatUtils = new ArrayList<MovingObjectUtil>();
        boatUtils.add(new BoatUtil(-BitmapUtil.carBitmap.getWidth(), MovingObjectLinesTop[i] , BOAT_MOVE_SPEEDX));
        boatLines.add(boatUtils);
    }
    
    initFrog();
    initGoals();
}

-(void) initFrog{
    BitmapUtil.createSpeficalFrogBitmap(LINE_DISTANCE/2, LINE_DISTANCE/2);
    frogStartX = (CommonUtil.screenWidth - BitmapUtil.frogUpBitmap.getWidth()) / 2;
    frogUtil = new FrogUtil(frogStartX, frogStartY);
}

-(void) initGoals{
    BitmapUtil.createSpeficalGoalBitmap(HOLE_WIDTH, HOLE_WIDTH);
    for(int i = 0; i < HOLE_NUM; i++){
        goals.add(new GoalUtil(MOVEX_DISTANCE * i*2, 0));
    }
}

-(void) process{
    [self doUtilMoveAndCheckCreateAndRemoveUtilOrNot:carLines];
    [self doUtilMoveAndCheckCreateAndRemoveUtilOrNot:woodLines];
    [self doUtilMoveAndCheckCreateAndRemoveUtilOrNot:boatLines];
    [self checkFrogSuccessArrival];
    [self checkGameWinOrLose];
    [self calculateScroe];
    //		doCarMoveAndCheckCreateAndRemoveCarOrNot();
    //		doWoodMove();
    //		doBoatMove();
}

-(void) draw{
    Canvas canvas = surfaceHolder.lockCanvas();
    canvas.drawColor(Color.WHITE);
    
    for(GoalUtil goalUtil : goals){
        goalUtil.onDrawSelf(canvas);
    }
    
    frogUtil.onDrawSelf(canvas);
    
    for(int i=0; i<CAR_LINE_NUM; i++){
        ArrayList<MovingObjectUtil> carUtils = carLines.get(i);
        for(MovingObjectUtil carUtil : carUtils){
            carUtil.onDrawSelf(canvas);
        }
    }
    for(int i=0; i<WOOD_LINE_NUM; i++){
        ArrayList<MovingObjectUtil> woodUtils = woodLines.get(i);
        for(MovingObjectUtil woodUtil : woodUtils){
            woodUtil.onDrawSelf(canvas);
        }
    }
    for(int i=0; i<BOAT_LINE_NUM; i++){
        ArrayList<MovingObjectUtil> boatUtils = boatLines.get(i);
        for(MovingObjectUtil biatUtil : boatUtils){
            biatUtil.onDrawSelf(canvas);
        }
    }
    
    
    surfaceHolder.unlockCanvasAndPost(canvas);
}

-(void) doUtilMoveAndCheckCreateAndRemoveUtilOrNot:(NSArray*) arrayList{
    for(int i=0; i<arrayList.size(); i++){
        doMovingObjectLineMove(i, arrayList.get(i));
    }
}

bool isCollision = false;

-(void) doMovingObjectLineMove:(int) carLinePosition list:(NSArray*)movingObjectUtilarrayList{
    bool isNeedCreateNewInstance = false;
    bool isNeedRemoveInstance = false;
    //		Object theInstanceForCheckType = arrayList.get(0);
    //		if (theInstanceForCheckType instanceof CarUtil) {
    //			ArrayList<CarUtil> carUtils = arrayList;
    //		}else if(theInstanceForCheckType instanceof WoodUtil){
    //
    //		}else{
    //
    //		}
    //		ArrayList<CarUtil> carUtils = carLines.get(carLinePosition);
    int firstCarPosition = 0;
    int LastCatPosition = movingObjectUtilarrayList.size()-1;
    
    for(int carPosition=0; carPosition<movingObjectUtilarrayList.size(); carPosition++){
        MovingObjectUtil movingObjectUtil = movingObjectUtilarrayList.get(carPosition);
        if(!isCollision)
        isCollision = frogUtil.isCollisionWith(movingObjectUtil);
        //			movingObjectUtil.onMove(CAR_MOVE_SPEEDX, 0);
        movingObjectUtil.onMove();
        if(carPosition==LastCatPosition)
        isNeedCreateNewInstance = movingObjectUtil.isNeedCreateNewInstance();
        if(carPosition==firstCarPosition){
            isNeedRemoveInstance = movingObjectUtil.isNeedRemoveInstance();
        }
    }
    if(isNeedCreateNewInstance){
        //			CarUtil carUtil = new CarUtil(-BitmapUtil.carBitmap.getWidth(), movingObjectUtilarrayList.get(LastCatPosition).getTop(), WOOD_MOVE_SPEEDX);
        movingObjectUtilarrayList.add(createNewMoveObject((MovingObjectUtil)movingObjectUtilarrayList.get(LastCatPosition)));
    }
    if(isNeedRemoveInstance){
        movingObjectUtilarrayList.remove(movingObjectUtilarrayList.get(firstCarPosition));
    }
}

//	enum MoveObjectType{
//		CAR, WOOD, BOAT
//	}

-(MovingObjectUtil*) createNewMoveObject:(MovingObjectUtil*) lastMovingObjectUtil{
    MovingObjectUtil newMovingObjectUtil = null;
    if (lastMovingObjectUtil instanceof CarUtil) {
        newMovingObjectUtil = new CarUtil(-BitmapUtil.carBitmap.getWidth(), lastMovingObjectUtil.getTop(), CAR_MOVE_SPEEDX);
        
    } else if (lastMovingObjectUtil instanceof WoodUtil) {
        newMovingObjectUtil = new WoodUtil(-BitmapUtil.woodBitmap.getWidth(), lastMovingObjectUtil.getTop(), WOOD_MOVE_SPEEDX);
        
    } else if (lastMovingObjectUtil instanceof BoatUtil) {
        newMovingObjectUtil = new BoatUtil(-BitmapUtil.boatBitmap.getWidth(), lastMovingObjectUtil.getTop(), BOAT_MOVE_SPEEDX);
        
    }
    return newMovingObjectUtil;
}

-(void) checkFrogSuccessArrival{
    isCollision = frogUtil.isSuccessArrival(goals);
}

-(void) checkGameWinOrLose{
    boolean isFrogSuccessArrivalAllGoal = true;
    for(GoalUtil goalUtil : goals){
        if(!goalUtil.isForgSuccessArrival()){
            isFrogSuccessArrivalAllGoal = false;
            break;
        }
        
    }
    
    if(isFrogSuccessArrivalAllGoal){
        if(currentGameLevel == GameActivity.GAME_MAX_LEVEL){
            isGameRun = false;
            //				showAllClearAnim
        }
        return;
    }else{
        //			time = 0;
    }
}

-(void) calculateScroe{
    if(isCollision){
        notifyObserver();
    }
}

-(void) setCurrentGameLevel:(int) currentGameLevel{
    this.currentGameLevel = currentGameLevel;
}

-(int) getCurrentGameLevel{
    return currentGameLevel;
}

int scoreMultiplierForTime = 10;
int scoreMultiplierForLife = 300;
int MAX_LIFE = 3;
int currentLife;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if(!isTouchAble){
        return;
    }
    
    for (int i = bugs.count-1; i >= 0 ; i--) {
        if (CGRectContainsPoint([bugs[i] calculateAccumulatedFrame], location)) {
            isTouchAble = false;
            
            SKSpriteNode * bug = bugs[i];
            [self runHitAction:bug];
            
            SKSpriteNode * explodeNode = [self checkPool];
            if(explodeNode==nil){
                explodeNode = [SKSpriteNode spriteNodeWithTexture:nil];
                explodeNode.zPosition = EXPLODE_ZPOSITION;
                explodeNode.size = bug.size;
                explodeNode.position = CGPointMake(bug.position.x, bug.position.y+bug.size.height);
                explodeNode.anchorPoint = CGPointMake(0.5, 1);
                
                [self addChild:explodeNode];
                [explodePool addObject:explodeNode];
            }else{
                explodeNode.position = CGPointMake(bug.position.x, bug.position.y+bug.size.height);
            }
            
            [self runExplodeAction:explodeNode];
            
            [self changeGamePoint];
            
//            [hamer runAction:hamerHitCat];
//            [self enemyBeHit];
            break;
        }
    }
}

-(void)runHitAction:(SKSpriteNode*)bug{
    [bug removeAllActions];
    bug.texture = currentCatTextures[3];
    SKAction * wait = [SKAction waitForDuration:0.5];
    SKAction * end = [SKAction runBlock:^{
        [bug removeFromParent];
        [bugs removeObject:bug];
    }];
    
    [bug runAction:[SKAction sequence:@[wait, end]]];
}

-(SKSpriteNode*)checkPool{
    SKSpriteNode * availidExplodeNode = nil;
    
    for(int i = 0; i < explodePool.count; i++){
        SKSpriteNode * explode = explodePool[i];
        if (explode.isHidden) {
            explode.hidden = false;
            availidExplodeNode = explode;
            break;
        }
    }
    
    return availidExplodeNode;
}

-(void)runExplodeAction:(SKSpriteNode*)explode{
    
    SKAction * explodeAction = [SKAction animateWithTextures:explodeTextures timePerFrame:0.2];
    SKAction * end = [SKAction runBlock:^{
        explode.hidden = true;
        isTouchAble = true;
    }];
    
    [explode runAction:[SKAction sequence:@[explodeAction, end]]];
}

-(void)changeGamePoint{
    gameScore++;
    
    gamePointSingleNode.texture = [self getTimeTexture:gameScore%10];
    
    gamePointTenNode.texture = [self getTimeTexture:(gameScore)/10%10];
    
    gamePointHunNode.texture = [self getTimeTexture:(gameScore)/100%10];
    
    gamePointTHUNode.texture = [self getTimeTexture:(gameScore)/1000%10];
}

-(SKTexture*)getTimeTexture:(int)time{
    SKTexture* texture;
    switch (time) {
        case 0:
            texture = [TextureHelper timeTextures][0];
            break;
        case 1:
            texture = [TextureHelper timeTextures][1];
            break;
        case 2:
            texture = [TextureHelper timeTextures][2];
            break;
        case 3:
            texture = [TextureHelper timeTextures][3];
            break;
        case 4:
            texture = [TextureHelper timeTextures][4];
            break;
        case 5:
            texture = [TextureHelper timeTextures][5];
            break;
        case 6:
            texture = [TextureHelper timeTextures][6];
            break;
        case 7:
            texture = [TextureHelper timeTextures][7];
            break;
        case 8:
            texture = [TextureHelper timeTextures][8];
            break;
        case 9:
            texture = [TextureHelper timeTextures][9];
            break;
            //        default:
            //            texture = [self getTimeTexture:time/10];
            //            break;
    }
    return texture;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
