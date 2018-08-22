//
//  test.h
//  Try_FrogCross
//
//  Created by irons on 2015/6/5.
//  Copyright (c) 2015年 irons. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IDrawSelf <NSObject>

- (void)onDrawSelf;

@end

@protocol IMovingObject <NSObject>

- (void)onMove;

@end


@protocol MovingObjectUtil <NSObject, IDrawSelf, IMovingObject>

@property (assign) int speed;

@optional
- (BOOL)isNeedCreateNewInstance;

@required
- (BOOL)isNeedRemoveInstance;


@end

@interface MovingObject : NSObject <MovingObjectUtil>

- (void)getInt;

@end


@interface test : MovingObject <MovingObjectUtil>

- (BOOL)isNeedCreateNewInstance;

@end
