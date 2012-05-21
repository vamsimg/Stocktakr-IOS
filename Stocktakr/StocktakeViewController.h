//
//  StocktakeViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StocktakeViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *productCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *recordCountLabel;

- (IBAction)scanItems:(UIButton *)button;
- (IBAction)recordsList:(UIButton *)button;
- (IBAction)submitRecords:(UIButton *)button;

@end
