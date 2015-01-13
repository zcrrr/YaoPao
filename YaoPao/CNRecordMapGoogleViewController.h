//
//  CNRecordMapGoogleViewController.h
//  YaoPao
//
//  Created by zc on 15-1-3.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "RunClass.h"

@interface CNRecordMapGoogleViewController : UIViewController

@property (nonatomic, strong) GMSMapView *mapView;

@property (strong, nonatomic) RunClass* oneRun;

@end
