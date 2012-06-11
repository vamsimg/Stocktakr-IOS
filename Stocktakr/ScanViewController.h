//
//  ScanViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ProductDataSource;

@interface ScanViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<ProductDataSource> dataSource;

@property (nonatomic, strong) IBOutlet UITextField *barcodeField;
@property (nonatomic, strong) IBOutlet UITextField *quantityField;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *barcodeLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;

@end
