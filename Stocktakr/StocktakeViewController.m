//
//  StocktakeViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StocktakeViewController.h"
#import "ProductManager.h"
#import "ScanViewController.h"
#import "RecordsViewController.h"
#import "SubmitViewController.h"


@interface StocktakeViewController ()

@end

@implementation StocktakeViewController

@synthesize productCountLabel = productCountLabel_;
@synthesize recordCountLabel = recordCountLabel_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Stocktake";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	ProductManager *productManager = [ProductManager sharedManager];
	self.productCountLabel.text = [NSString stringWithFormat:@"%d", [productManager numberOfProducts]];
	self.recordCountLabel.text = [NSString stringWithFormat:@"%d", [productManager numberOfRecords]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public methods

- (IBAction)scanItems:(UIButton *)button {
	ScanViewController *viewController = [[ScanViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)recordsList:(UIButton *)button {
	RecordsViewController *viewController = [[RecordsViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)submitRecords:(UIButton *)button {
	SubmitViewController *viewController = [[SubmitViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
