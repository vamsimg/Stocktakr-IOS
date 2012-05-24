//
//  PriceCheckViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PriceCheckViewController.h"
#import "ProductManager.h"


@interface PriceCheckViewController ()

@end

@implementation PriceCheckViewController

@synthesize barcodeField = barcodeField_;
@synthesize descriptionLabel = descriptionLabel_;
@synthesize barcodeLabel = barcodeLabel_;
@synthesize priceLabel = priceLabel_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Price Check";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.barcodeField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSString *barcode = textField.text;
	textField.text = @"";
	
	NSDictionary *product = [[ProductManager sharedManager] productForBarcode:barcode];
	if (!product) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid barcode" message:@"Unable to find a product matching barcode" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
		return YES;
	}
	
	self.descriptionLabel.text = [product valueForKey:@"description"];
	self.barcodeLabel.text = [product valueForKey:@"barcode"];
	self.priceLabel.text = [product valueForKey:@"price"];
	
	return YES;
}

@end
