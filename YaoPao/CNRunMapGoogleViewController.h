//
//  CNRunMapGoogleViewController.h
//  YaoPao
//
//  Created by zc on 14-12-16.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
@class CNGPSPoint;

@interface CNRunMapGoogleViewController : UIViewController

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSTimer* timer_map;

@property (nonatomic, strong) CNGPSPoint* lastDrawPoint;

@property (nonatomic, strong) GMSMutablePath *path;
@property (nonatomic, strong) GMSPolyline *polyline;



@end
