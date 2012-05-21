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
#import "Constants.h"
#import "MBProgressHUD.h"


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
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *storeId = [userDefaults valueForKey:STORE_ID_KEY];
	NSString *password = [userDefaults valueForKey:PASSWORD_KEY];
	NSString *name = [userDefaults valueForKey:NAME_KEY];
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = @"Submitting";
	[[ProductManager sharedManager] uploadStocktakeRecordsWithStoreId:storeId password:password name:name complete:^(BOOL success) {
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
