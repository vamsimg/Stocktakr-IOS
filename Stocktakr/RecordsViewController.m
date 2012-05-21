//
//  RecordsViewController.m
//  Stocktakr
//
//  Created by Sherman Lo on 16/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordsViewController.h"
#import "ProductManager.h"


@interface RecordsViewController ()

@property (nonatomic, strong) NSArray *records;

@end

@implementation RecordsViewController

@synthesize records = records_;


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Records";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.records = [[ProductManager sharedManager] records];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryView = [[UILabel alloc] init];
	}
	
	NSDictionary *record = [self.records objectAtIndex:indexPath.row];
	
	UILabel *quantityLabel = (UILabel *)cell.accessoryView;
	quantityLabel.text = [[record valueForKey:@"quantity"] stringValue];
	[quantityLabel sizeToFit];
	
	cell.textLabel.text = [record objectForKey:@"description"];
	cell.detailTextLabel.text = [record objectForKey:@"barcode"];
	
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *quantityLabel = (UILabel *)[[self.tableView cellForRowAtIndexPath:indexPath] accessoryView];
	quantityLabel.textColor = [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UILabel *quantityLabel = (UILabel *)[[self.tableView cellForRowAtIndexPath:indexPath] accessoryView];
	quantityLabel.textColor = [UIColor whiteColor];
}

@end
