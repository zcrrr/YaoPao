//
//  CNVCodeViewController.h
//  YaoPao
//
//  Created by zc on 14-12-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionsViewController.h"

@interface CNVCodeViewController : UIViewController<UITextFieldDelegate,SecondViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIButton *button_vcode;
@property (strong, nonatomic) IBOutlet UIButton *button_ok;
@property (strong, nonatomic) IBOutlet UITextField *textfield_phone;
@property (strong, nonatomic) IBOutlet UITextField *textfield_vcode;
@property (strong, nonatomic) IBOutlet UILabel *label_country;
@property (strong, nonatomic) IBOutlet UILabel *label_code;
- (IBAction)button_clicked:(id)sender;
- (IBAction)view_touched:(id)sender;
- (IBAction)button_country_clicked:(id)sender;

@end
