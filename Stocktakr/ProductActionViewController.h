//
//  ProductActionViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 9/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ProductDataSource;

@interface ProductActionViewController : UIViewController

@property (nonatomic, strong) id<ProductDataSource> dataSource;

@property (nonatomic, strong) IBOutlet UILabel *productCountLabel;

@property (nonatomic, strong) IBOutlet UIButton *scanButton;
@property (nonatomic, strong) IBOutlet UIButton *listButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

- (IBAction)scan:(UIButton *)button;
- (IBAction)list:(UIButton *)button;
- (IBAction)submit:(UIButton *)button;

@end
