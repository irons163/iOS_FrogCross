//
//  CarUtil.m
//  Try_FrogCross
//
//  Created by irons on 2015/10/7.
//  Copyright (c) 2015年 irons. All rights reserved.
//

#import "CarUtil.h"

@implementation CarUtil

+(CarUtil*) creataeCarUtilWithWidth:(float)width withHeight:(float)height{
    CarUtil* carUtil = [SKSpriteNode spriteNodeWithTexture:nil];
    
    return carUtil;
}

@end
