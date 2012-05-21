//
//  SettingsViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *storeIdField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

@property (nonatomic, strong) IBOutlet UISwitch *setQuantitySwitch;

- (IBAction)testConnection:(UIButton *)button;
- (IBAction)setQuantityChanged:(UISwitch *)toggleSwitch;

@end
