//
//  CNGPSPoint.m
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNGPSPoint.h"

@implementation CNGPSPoint

@synthesize status;
@synthesize time;
@synthesize lon;
@synthesize lat;
@synthesize speed;
@synthesize course;
@synthesize altitude;


- (id)proxyForJson{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",self.status],@"status",nil];
}
@end
