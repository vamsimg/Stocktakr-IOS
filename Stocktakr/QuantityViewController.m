//
//  QuantityViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 23/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuantityViewController.h"
#import "ProductManager.h"


@interface QuantityViewController ()

@property (nonatomic, strong) KeypadView *keypadView;

- (void)done:(UIBarButtonItem *)barButton;

@end

@implementation QuantityViewController

@synthesize product = product_;
@synthesize initialQuantity = initialQuantity_;
@synthesize descriptionLabel = nameLabel_;
@synthesize quantityField = quantityField_;
@synthesize keypadView = keypadView_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Quantity";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	
	self.quantityField.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.descriptionLabel.text = [self.product valueForKey:@"description"];
	self.quantityField.placeholder = [self.initialQuantity stringValue];
	
	[self.view addSubview:self.keypadView];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self.keypadView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - KeypadViewDelegate

- (void)backspaceKeyTapped {
	NSString *prevQuantity = self.quantityField.text;
	if (![prevQuantity length]) {
		return;
	}
	
	self.quantityField.text = [prevQuantity substringToIndex:[prevQuantity length] - 1];
}

- (void)keyTapped:(NSString *)character {
	NSString *prevQuantity = self.quantityField.text;
	self.quantityField.text = [prevQuantity stringByAppendingString:character];
}


#pragma mark - Getters / Setters

- (KeypadView *)keypadView {
	if (!keypadView_) {
		self.keypadView = [[KeypadView alloc] initWithFrame:CGRectMake(0, 211, 320, 205)];
		self.keypadView.delegate = self;
	}
	return keypadView_;
}


#pragma mark - Private methods

- (void)done:(UIBarButtonItem *)barButton {
	if ([self.quantityField.text length]) {
		NSNumber *quantity = [NSNumber numberWithDouble:[self.quantityField.text doubleValue]];
		
		[[ProductManager sharedManager] setQuantity:quantity forBarcode:[self.product valueForKey:@"barcode"]];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
