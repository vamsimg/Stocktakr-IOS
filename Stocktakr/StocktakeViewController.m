//
//  StocktakeViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StocktakeViewController.h"
#import "ProductManager.h"
#import "ProductsViewController.h"
#import "Constants.h"
#import "StocktakeDataSource.h"


@implementation StocktakeViewController


#pragma mark - Init / Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:@"ProductActionViewController" bundle:nil]) {
		self.title = @"Stocktake";
		self.dataSource = [[StocktakeDataSource alloc] init];
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.scanButton setTitle:@"Scan Item" forState:UIControlStateNormal];
	[self.listButton setTitle:@"Records List" forState:UIControlStateNormal];
	[self.submitButton setTitle:@"Submit Records" forState:UIControlStateNormal];
}

@end
