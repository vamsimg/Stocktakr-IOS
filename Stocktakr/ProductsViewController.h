//
//  RecordsViewController.h
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductDataSource;

@interface ProductsViewController : UITableViewController

@property (nonatomic, weak) id<ProductDataSource> dataSource;

@end
