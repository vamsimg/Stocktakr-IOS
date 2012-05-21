//
//  SubmitViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 17/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UILabel *stocktakeRecordsLabel;

- (IBAction)submit:(UIButton *)button;

@end
