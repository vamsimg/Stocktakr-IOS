//
//  PurchaseOrderViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 9/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurchaseOrderViewController.h"
#import "PurchaseOrderDataSource.h"


@implementation PurchaseOrderViewController


#pragma mark - Init / Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:@"ProductActionViewController" bundle:nibBundleOrNil]) {
		self.title = @"Purchase Order";
		self.dataSource = [[PurchaseOrderDataSource alloc] init];
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.scanButton setTitle:@"Scan Item" forState:UIControlStateNormal];
	[self.listButton setTitle:@"Item List" forState:UIControlStateNormal];
	[self.submitButton setTitle:@"Upload Order" forState:UIControlStateNormal];
}

@end
