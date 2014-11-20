//
//  CNRegisterPhoneViewController.h
//  YaoPao
//
//  Created by zc on 14-7-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@interface CNRegisterPhoneViewController : UIViewController<UITextFieldDelegate,registerPhoneDelegate>
@property (assign, nonatomic) int agree;
@property (strong, nonatomic) IBOutlet UITextField *textfield_phone;
@property (strong, nonatomic) IBOutlet UITextField *textfield_pwd;
@property (strong, nonatomic) IBOutlet UITextField *textfield_vcode;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIButton *button_vcode;
@property (strong, nonatomic) IBOutlet UIButton *button_reg;
@property (strong, nonatomic) IBOutlet UIButton *button_goLogin;
@property (strong, nonatomic) IBOutlet UILabel *label_goLogin;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
- (IBAction)view_touched:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_checkbox;
- (IBAction)button_checkbox_clicked:(id)sender;

- (IBAction)button_clicked:(id)sender;

@end
