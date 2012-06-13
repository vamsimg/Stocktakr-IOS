//
//  ProductActionViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 9/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductActionViewController.h"
#import "ProductManager.h"
#import "ScanViewController.h"
#import "ProductsViewController.h"
#import "ProductDataSource.h"
#import "Constants.h"
#import "MBProgressHUD.h"


@interface ProductActionViewController ()

@end

@implementation ProductActionViewController

@synthesize dataSource = _dataSource;
@synthesize productCountLabel = _productCountLabel;
@synthesize scanButton = _scanButton;
@synthesize listButton = _listButton;
@synthesize submitButton = _submitButton;


#pragma mark - UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	
	ProductManager *productManager = [ProductManager sharedManager];
	self.productCountLabel.text = [NSString stringWithFormat:@"%d", [productManager numberOfProducts]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public methods

- (IBAction)scan:(UIButton *)button {
	ScanViewController *viewController = [[ScanViewController alloc] init];
	viewController.dataSource = self.dataSource;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)list:(UIButton *)button {
	ProductsViewController *viewController = [[ProductsViewController alloc] init];
	viewController.dataSource = self.dataSource;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)submit:(UIButton *)button {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *storeId = [userDefaults valueForKey:STORE_ID_KEY];
	NSString *password = [userDefaults valueForKey:PASSWORD_KEY];
	NSString *name = [userDefaults valueForKey:NAME_KEY];
	
	if (![storeId length] || ![password length] || ![name length]) {
		[[[UIAlertView alloc] initWithTitle:@"Details missing" message:@"Please fill in details in the settings screen to submit records" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		return;
	}
	
	if ([self.dataSource numberOfRecords] == 0) {
		[[[UIAlertView alloc] initWithTitle:@"No Records" message:@"No records to upload" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		return;
	}
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = @"Submitting";
	[self.dataSource uploadWithStoreId:storeId password:password name:name complete:^(BOOL success) {
		if (success) {
			hud.labelText = @"Successful";
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
				[MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
			});
		} else {
			[MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
			
			[[[UIAlertView alloc] initWithTitle:@"Error Submitting" message:@"An error occurred while submitting records" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		}
	}];
}

@end
