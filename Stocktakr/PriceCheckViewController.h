//
//  PriceCheckViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriceCheckViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *barcodeField;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *barcodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;

@end
