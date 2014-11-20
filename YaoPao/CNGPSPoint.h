//
//  CNGPSPoint.h
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+SBJson.h"

@interface CNGPSPoint : NSObject

@property (assign, nonatomic) int status;
@property (assign, nonatomic) long long time;
@property (assign, nonatomic) double lon;
@property (assign, nonatomic) double lat;
@property (assign, nonatomic) int speed;
@property (assign, nonatomic) int course;
@property (assign, nonatomic) int altitude;

- (id)proxyForJson;


@end
