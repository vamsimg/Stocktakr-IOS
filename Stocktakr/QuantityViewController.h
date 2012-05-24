//
//  QuantityViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 23/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeypadView.h"


@interface QuantityViewController : UIViewController <KeypadViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UITextField *quantityField;

@property (nonatomic, strong) NSDictionary *product;
@property (nonatomic, strong) NSNumber *initialQuantity;

@end
