//
//  HomeViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

- (IBAction)priceCheck:(UIButton *)button;
- (IBAction)performStocktake:(UIButton *)button;
- (IBAction)purchaseOrder:(UIButton *)button;
- (IBAction)downloadProducts:(UIButton *)button;

@end
