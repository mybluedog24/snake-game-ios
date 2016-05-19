//
//  GameScene.m
//  Snake
//
//  Created by Frank Chen on 2/25/2014.
//  Copyright (c) 2014 Frank Chen. All rights reserved.
//

#import "GameScene.h"
#import "Dot.h"
#import "Button.h"
#import "Number.h"

#define UP 2
#define DOWN 4
#define LEFT 1
#define RIGHT 3
#define PAUSE -1
#define NEWGAME -2

#define kHighScoreLeaderboardCategory @"Long Snakes"

static const CGFloat statusBarHeight = 20;

static const CGFloat gridLength = 10;
static const CGFloat gridGap = 1;

static const CGFloat boardWidth = 29;
static const CGFloat boardHeight = 41;

static const int timeInterval = 200;


@interface GameScene ()
@property (nonatomic) NSMutableArray *snake;
@property (nonatomic) NSMutableArray *board;
@property (nonatomic) Dot *food;
@property (nonatomic) int direction;
@property (nonatomic) int score;
@property (nonatomic) int highScore;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL isOver;

@property (nonatomic) Button *play;
@property (nonatomic) Button *pause;
@property (nonatomic) Button *up;
@property (nonatomic) Button *down;
@property (nonatomic) Button *left;
@property (nonatomic) Button *right;
@property (nonatomic) Button *restart;
@property (nonatomic) Button *gameCenter;

@property (nonatomic) Number *high_100;
@property (nonatomic) Number *high_10;
@property (nonatomic) Number *high_1;
@property (nonatomic) Number *current_100;
@property (nonatomic) Number *current_10;
@property (nonatomic) Number *current_1;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [[GameKitHelper sharedGameKitHelper]
         authenticateLocalPlayer];
        
        self.backgroundColor = [SKColor colorWithRed:160/255.0 green:168/255.0 blue:147/255.0 alpha:1.0];
        SKSpriteNode *grid = [SKSpriteNode spriteNodeWithImageNamed:@"Grid"];
        [grid setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        [self addChild:grid];

        
        [self initBoard];
        [self initNumbers];
        [self initButtons];
        
        if (![self load]) {
            _score = 0;
            _highScore = 0;
            _isPaused = YES;
            _isOver = NO;
            [self initSnake];
            [self createFood];
            NSLog(@"can not load");
        }
        
        [self setHighScoreOnBoard];
        [self setScoreOnBoard];
        if (!_isOver) {
            [self showPlayHidePause:_isPaused];
            [self showControl:YES];
        }else {
            [_play setHidden:YES];
            [_pause setHidden:YES];
            [self showControl:NO];
            [_restart setHidden:NO];
            [_gameCenter setHidden:NO];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(moveOn) userInfo:nil repeats:YES];
         
        
    }
    return self;
}

- (void)initBoard
{
    _board = [NSMutableArray arrayWithCapacity:boardWidth];
    for (int i=0; i<boardWidth; i++) {
        _board[i] = [NSMutableArray arrayWithCapacity:boardHeight];
    }
    
    for (int i=0; i<boardWidth; i++) {
        for (int j=0; j<boardHeight; j++) {
            if (i==0 || j<=17 || i==boardWidth-1 || j>=boardHeight-7) {
                //[[_board objectAtIndex:i] insertObject:@YES atIndex:j];
                _board[i][j] = @YES;
            }else{
                _board[i][j] = @NO;
            }
        }
    }
}

- (void)showControl:(BOOL)isSet
{
    if (isSet) {
        [_up setHidden:NO];
        [_down setHidden:NO];
        [_left setHidden:NO];
        [_right setHidden:NO];
    }else {
        [_up setHidden:YES];
        [_down setHidden:YES];
        [_left setHidden:YES];
        [_right setHidden:YES];
    }
}

- (void)showPlayHidePause:(BOOL)isSet
{
    if (isSet) {
        [_play setHidden:NO];
        [_pause setHidden:YES];
    }else {
        [_play setHidden:YES];
        [_pause setHidden:NO];
    }
}

- (void)initButtons
{
    _play = [Button spriteNodeWithImageNamed:@"Play"];
    _play.position = [self getRealPositionFrom:CGPointMake(2, 3)];
    [_play setHidden:YES];
    [self addChild:_play];
    
    _pause = [Button spriteNodeWithImageNamed:@"Pause"];
    _pause.position = [self getRealPositionFrom:CGPointMake(2, 3)];
    [_pause setHidden:YES];
    [self addChild:_pause];
    
    _up = [Button spriteNodeWithImageNamed:@"Up"];
    _up.position = [self getRealPositionFrom:CGPointMake(14, 12)];
    [_up setHidden:YES];
    [self addChild:_up];
    
    _down = [Button spriteNodeWithImageNamed:@"Down"];
    _down.position = [self getRealPositionFrom:CGPointMake(14, 4)];
    [_down setHidden:YES];
    [self addChild:_down];
    
    _left = [Button spriteNodeWithImageNamed:@"Left"];
    _left.position = [self getRealPositionFrom:CGPointMake(7, 8)];
    [_left setHidden:YES];
    [self addChild:_left];
    
    _right = [Button spriteNodeWithImageNamed:@"Right"];
    _right.position = [self getRealPositionFrom:CGPointMake(21, 8)];
    [_right setHidden:YES];
    [self addChild:_right];
    
    _restart = [Button spriteNodeWithImageNamed:@"Restart"];
    _restart.position = [self getRealPositionFrom:CGPointMake(6, 11)];
    [_restart setHidden:YES];
    [self addChild:_restart];
    
    _gameCenter = [Button spriteNodeWithImageNamed:@"GameCenter"];
    _gameCenter.position = [self getRealPositionFrom:CGPointMake(22, 11)];
    [_gameCenter setHidden:YES];
    [self addChild:_gameCenter];

    
}

- (void)initNumbers
{
    CGPoint hnum__ = [self getRealPositionFrom:CGPointMake(2, 38)] ;
    CGPoint _hnum_ = [self getRealPositionFrom:CGPointMake(6, 38)];
    CGPoint __hnum = [self getRealPositionFrom:CGPointMake(10, 38)];
    CGPoint num__ = [self getRealPositionFrom:CGPointMake(18, 38)];
    CGPoint _num_ = [self getRealPositionFrom:CGPointMake(22, 38)];
    CGPoint __num = [self getRealPositionFrom:CGPointMake(26, 38)];
    
    _high_100 = [Number spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(32, 54)];
    _high_10 = [Number spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(32, 54)];
    _high_1 = [Number spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(32, 54)];
    _current_100 = [Number spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(32, 54)];
    _current_10 = [Number spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(32, 54)];
    _current_1 = [Number spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(32, 54)];
    
    _high_100.position = hnum__;
    _high_10.position = _hnum_;
    _high_1.position = __hnum;
    _current_100.position = num__;
    _current_10.position = _num_;
    _current_1.position = __num;
    
    [self addChild:_high_100];
    [self addChild:_high_10];
    [self addChild:_high_1];
    [self addChild:_current_100];
    [self addChild:_current_10];
    [self addChild:_current_1];
}

- (void)setScoreOnBoard
{
    int tempScore = _score;
    _current_100.texture = [SKTexture textureWithImageNamed:[@(tempScore/100) stringValue]];
    tempScore = tempScore % 100;
    _current_10.texture = [SKTexture textureWithImageNamed:[@(tempScore/10) stringValue]];
    tempScore = tempScore % 10;
    _current_1.texture = [SKTexture textureWithImageNamed:[@(tempScore) stringValue]];
}

- (void)setHighScoreOnBoard
{
    int tempScore = _highScore;
    _high_100.texture = [SKTexture textureWithImageNamed:[@(tempScore/100) stringValue]];
    tempScore = tempScore % 100;
    _high_10.texture = [SKTexture textureWithImageNamed:[@(tempScore/10) stringValue]];
    tempScore = tempScore % 10;
    _high_1.texture = [SKTexture textureWithImageNamed:[@(tempScore) stringValue]];
}

/*
- (void)FlipButton:(int)dir
{
    switch (dir) {
        case UP:
            [_upButton setn
            break;
        case DOWN:
            break;
        case LEFT:
            break;
        case RIGHT:
            break;
        case PAUSE:
            break;
    }
}
*/
- (void)initSnake
{
    int initSize = 5;
    // head
    int x = 2;
    int y = 23;
    
    if (_snake == NULL){
        _snake = [[NSMutableArray alloc] init];
    }
    for (int i=0; i<initSize; i++) {
        CGPoint indexPosition = CGPointMake(x, y-i);
        [_snake addObject:[self setDotFromIndexPosition:indexPosition]];
        _board[x][y-i] = @YES;
    }
    
    _direction = UP;
}

- (void)initOldFood
{
    CGPoint indexPosition = [self getIndexPositionFrom:(_food.position)];
    _board[(int)(indexPosition.x)][(int)(indexPosition.y)] = @YES;
}

- (CGPoint)getRealPositionFrom:(CGPoint)indexPosition
{
    CGFloat x = gridLength/2 + gridGap;
    CGFloat y = gridLength/2 + gridGap;
    return CGPointMake(x + (gridLength+gridGap)*indexPosition.x, y + (gridLength+gridGap)*indexPosition.y);
}

- (CGPoint)getIndexPositionFrom:(CGPoint)position
{
    CGFloat x = position.x;
    CGFloat y = position.y;
    x -= gridLength/2 + gridGap;
    y -= gridLength/2 + gridGap;
    x = x/(gridLength+gridGap);
    y = y/(gridLength+gridGap);
    return CGPointMake((int)x, (int)y);
}

- (Dot*)setDotFromIndexPosition:(CGPoint)position
{
    Dot *dot = [Dot spriteNodeWithImageNamed:@"Dot"];
    dot.position = [self getRealPositionFrom:position];
    [self addChild:dot];
    return dot;
}

- (Dot*)setDotFromRealPosition:(CGPoint)position
{
    Dot *dot = [Dot spriteNodeWithImageNamed:@"Dot"];
    dot.position = position;
    [self addChild:dot];
    return dot;
}

- (void)createFood
{
    int x, y;
    do{
        x = arc4random() % (int)boardWidth;
        y = arc4random() % (int)boardHeight;
    }while([_board[x][y] boolValue]);
    _food = [self setDotFromIndexPosition:CGPointMake(x, y)];
    _board[x][y] = @YES;
    
}

- (BOOL) moveOn
{
    isActivated = NO;
    
    if (_isPaused) {
        return YES;
    }
    if (_isOver) {
        return NO;
    }
    
    Dot *head = (Dot*)_snake[0];
    CGPoint headPosition = [self getIndexPositionFrom:head.position];
    CGFloat headX = headPosition.x;
    CGFloat headY = headPosition.y;
    
    switch (_direction) {
        case UP:
            headY += 1;
            break;
        case DOWN:
            headY -= 1;
            break;
        case LEFT:
            headX -= 1;
            break;
        case RIGHT:
            headX += 1;
            break;
    }
    
    if (0<headX && headX<boardWidth && 0<headY && headY<boardHeight) {
        CGPoint foodPoint = [self getIndexPositionFrom:_food.position];
        if ([_board[(int)headX][(int)headY] boolValue]) {
            if (headX == foodPoint.x && headY == foodPoint.y) {
                _score += 1;
                [self setScoreOnBoard];
                [_snake insertObject:_food atIndex:0];
                [self createFood];
                return YES;
            }else{
                [self gameOver];
                return NO;
            }
        }else{
            Dot *newHead = [self setDotFromIndexPosition:CGPointMake(headX, headY)];
            [_snake insertObject:newHead atIndex:0];
            _board[(int)headX][(int)headY] = @YES;
            Dot *last = (Dot *)[_snake lastObject];
            CGPoint lastPoint = [self getIndexPositionFrom:last.position];
            _board[(int)lastPoint.x][(int)lastPoint.y] = @NO;
            [last removeFromParent];
            [_snake removeLastObject];
            return YES;
        }
    }
    [self gameOver];
    return NO;
}

- (void) gameOver
{
    _isOver = YES;
    [_play setHidden:YES];
    [_pause setHidden:YES];
    [self showControl:NO];
    [_restart setHidden:NO];
    [_gameCenter setHidden:NO];
    if (_score > _highScore) {
        _highScore = _score;
        [self setHighScoreOnBoard];
        //[self presentLeaderboards];
    }
    [[GameKitHelper sharedGameKitHelper]
     submitScore:(int64_t)_highScore
     category:@"Snake"];
}

- (void) newGame
{
    _isOver = NO;
    _isPaused = YES;
    _score = 0;
    [self setScoreOnBoard];
    [_restart setHidden:YES];
    [_gameCenter setHidden:YES];
    [self showControl:YES];
    [self showPlayHidePause:YES];
    
    //remove snake
    int snakeSize = _snake.count;
    for (int i=0; i<snakeSize; i++) {
        Dot *last = (Dot *)[_snake lastObject];
        CGPoint lastPoint = [self getIndexPositionFrom:last.position];
        _board[(int)lastPoint.x][(int)lastPoint.y] = @NO;
        [last removeFromParent];
        [_snake removeLastObject];
    }
    //remove food
    CGPoint lastPoint = [self getIndexPositionFrom:_food.position];
    _board[(int)lastPoint.x][(int)lastPoint.y] = @NO;
    [_food removeFromParent];
    
    //create snake
    [self initSnake];
    //create food
    [self createFood];
    
    
}

- (void)pauseGame
{
    if (!_isOver) {
        _isPaused = YES;
        isActivated = NO;
        [self showPlayHidePause:YES];
    }
}

- (void) save
{
    if (!_isOver)
        _isPaused = YES;
    
    isActivated = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(_score) forKey:@"score"];
    [defaults setObject:@(_highScore) forKey:@"highScore"];
    [defaults setObject:@(_direction) forKey:@"direction"];
    [defaults setObject:@(_isPaused) forKey:@"isPaused"];
    [defaults setObject:@(_isOver) forKey:@"isOver"];
    [defaults setObject:NSStringFromCGPoint(_food.position) forKey:@"food"];
    
    int count = _snake.count;
    id pos[count];
    for (int i=0; i<count; i++) {
        pos[i] = NSStringFromCGPoint(((Dot*)_snake[i]).position);
    }
    id array = [NSArray arrayWithObjects:pos count:count];
    
    [defaults setObject:array forKey:@"snake"];
    
    [defaults synchronize];
    NSLog(@"save sucess!");
    
}

- (BOOL) load
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"score"])
        return false;
    _score = [[defaults objectForKey:@"score"] intValue];
    NSLog(@"score: %d",_score);
    
    if (![defaults objectForKey:@"highScore"])
        return false;
    _highScore = [[defaults objectForKey:@"highScore"] intValue];
    NSLog(@"highscore: %d",_highScore);
    
    if (![defaults objectForKey:@"direction"])
        return false;
    _direction = [[defaults objectForKey:@"direction"] intValue];
    NSLog(@"direction: %d",_direction);
    
    if (![defaults objectForKey:@"isPaused"])
        return false;
    _isPaused = [[defaults objectForKey:@"isPaused"] boolValue];
    NSLog(@"isPaused: %d",_isPaused);
    
    if (![defaults objectForKey:@"isOver"])
        return false;
    _isOver = [[defaults objectForKey:@"isOver"] boolValue];
    NSLog(@"isOver: %d",_isOver);
    
    //setup food
    if (![defaults objectForKey:@"food"]){
        NSLog(@"can not load food");
        return false;
    }
    CGPoint pos = CGPointFromString([defaults objectForKey:@"food"]);
    CGPoint indexPos = [self getIndexPositionFrom:pos];
    _food = [self setDotFromRealPosition:pos];
    _board[(int)indexPos.x][(int)indexPos.y] = @YES;
    
    //setup snake
    if (![defaults objectForKey:@"snake"]){
        NSLog(@"can not load snake");
        return false;
    }
    NSArray *array = [defaults objectForKey:@"snake"];
    int count = array.count;
    _snake = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0; i<count; i++) {
        CGPoint pos = CGPointFromString(array[i]);
        CGPoint indexPos = [self getIndexPositionFrom:pos];
        _snake[i] = [self setDotFromRealPosition:pos];
        _board[(int)indexPos.x][(int)indexPos.y] = @YES;
    }
    NSLog(@"load success!");
    return true;
    
}

/*
- (void)encodeWithCoder:(NSCoder *)encoder
{
    if (!_isOver)
        _isPaused = YES;
    
    isActivated = NO;
    
    //0: score
    [encoder encodeObject:@(_score) forKey:@"score"];
    //1: high score
    [encoder encodeObject:@(_highScore) forKey:@"highScore"];
    //2: direction
    [encoder encodeObject:@(_direction) forKey:@"direction"];
    //3: is paused
    [encoder encodeObject:@(_isPaused) forKey:@"isPaused"];
    //4: is over
    [encoder encodeObject:@(_isOver) forKey:@"isOver"];
    //5: snake
    [encoder encodeObject:_snake forKey:@"snake"];
    //6: food
    [encoder encodeObject:_food forKey:@"food"];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        _score = (int)[decoder decodeObjectForKey:@"score"];
        _highScore = (int)[decoder decodeObjectForKey:@"highScore"];
        _direction = (int)[decoder decodeObjectForKey:@"direction"];
        _isPaused = (BOOL)[decoder decodeObjectForKey:@"isPaused"];
        _isOver = (BOOL)[decoder decodeObjectForKey:@"isOver"];
        _snake = [decoder decodeObjectForKey:@"snake"];
        _food = [decoder decodeObjectForKey:@"food"];
        
        
    }
    return self;
}
*/
- (void) printBoard
{
    // test board
    NSString *str1 = @"";
    NSString *bool1 = @"";
    for (int i=0; i<boardWidth; i++) {
        str1 = @"";
        for (int j=0; j<boardHeight; j++) {
            bool1 = [_board[i][j] boolValue] ? @"1" : @"0";
            str1 = [str1 stringByAppendingString:bool1];
        }
        NSLog(@"%@",str1);
    }
}

- (void)update:(NSTimeInterval)currentTime {
    //[self moveOn];
    //[NSThread sleepForTimeInterval:0.5];
}

int button = 0;
bool isActivated = NO;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (_isOver) {
        isActivated = NO;
        if (CGRectContainsPoint(_restart.frame, location)) {
            [self newGame];
        }else if (CGRectContainsPoint(_gameCenter.frame, location)) {
            [[GameKitHelper sharedGameKitHelper] presentLeaderboards];
        }
        return;
    }
    
    if (isActivated) {
        return;
    }
    isActivated = YES;
    
    if (CGRectContainsPoint(_up.frame, location)) {
        button = UP;
    }else if (CGRectContainsPoint(_down.frame, location)) {
        button = DOWN;
    }else if (CGRectContainsPoint(_left.frame, location)) {
        button = LEFT;
    }else if (CGRectContainsPoint(_right.frame, location)) {
        button = RIGHT;
    }else if (CGRectContainsPoint(_pause.frame, location) || (CGRectContainsPoint(_play.frame, location))) {
        button = PAUSE;
    }
    
    if (button == PAUSE) {
        _isPaused = !_isPaused;
        [self showPlayHidePause:_isPaused];
    }else if (button != 0 && (_direction % 2 != button % 2) && !_isPaused) {
        _direction = button;
    }
    
    button = 0;
}



@end
