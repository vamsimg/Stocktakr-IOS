//
//  ScanViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScanViewController.h"
#import "ProductManager.h"
#import "QuantityViewController.h"
#import "Constants.h"


@interface ScanViewController ()

@end

@implementation ScanViewController

@synthesize barcodeField = barcodeField_;
@synthesize quantityField = quantityField_;
@synthesize descriptionLabel = descriptionLabel_;
@synthesize barcodeLabel = barcodeLabel_;
@synthesize priceLabel = priceLabel_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Scan Item";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.barcodeField becomeFirstResponder];
	
	self.quantityField.userInteractionEnabled = NO;
	
	// If there's a barcode in the label then we're returning from the quantity screen so we want to update the quantity to make sure it's correct
	if ([self.barcodeLabel.text length]) {
		self.quantityField.text = [[[ProductManager sharedManager] quantityForBarcode:self.barcodeLabel.text] stringValue];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.barcodeField) {
		NSString *barcode = textField.text;
		textField.text = @"";
		
		ProductManager *productManager = [ProductManager sharedManager];
		
		NSDictionary *product = [productManager productForBarcode:barcode];
		if (!product) {
			[[[UIAlertView alloc] initWithTitle:@"Invalid barcode" message:@"Unable to find a product matching barcode" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
			return YES;
		}
		
		self.descriptionLabel.text = [product valueForKey:@"description"];
		self.barcodeLabel.text = [product valueForKey:@"barcode"];
		self.priceLabel.text = [product valueForKey:@"price"];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:SET_QUANTITY_KEY]) {
			NSString *barcode = [product valueForKey:@"barcode"];
			
			NSNumber *quantity = [productManager quantityForBarcode:barcode];
			if ([quantity isEqualToNumber:[NSNumber numberWithInt:0]]) {
				// If this is the first entry then we'll initialize the quantity to 1
				quantity = [productManager incrementQuantityForBarcode:barcode];
			}
			self.quantityField.text = [quantity stringValue];
			
			QuantityViewController *viewController = [[QuantityViewController alloc] initWithNibName:nil bundle:nil];
			viewController.product = product;
			viewController.initialQuantity = quantity;
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			self.quantityField.text = [[productManager incrementQuantityForBarcode:barcode] stringValue];
		}
	} else {
		NSNumber *quantity = [NSNumber numberWithDouble:[textField.text doubleValue]];
		
		[[ProductManager sharedManager] setQuantity:quantity forBarcode:self.barcodeLabel.text];
		
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end
