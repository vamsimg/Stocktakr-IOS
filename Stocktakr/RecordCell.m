//
//  RecordCell.m
//  Stocktakr
//
//  Created by Sherman Lo on 24/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordCell.h"

@interface RecordCell ()

@property (nonatomic, strong) UILabel *quantityLabel;

@end


@implementation RecordCell

@synthesize quantityLabel = quantityLabel_;


#pragma mark - Init / Dealloc

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.quantityLabel = [[UILabel alloc] init];
		self.accessoryView = self.quantityLabel;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	self.quantityLabel.textColor = (selected ? [UIColor whiteColor] : [UIColor blackColor]);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	self.quantityLabel.textColor = (highlighted ? [UIColor whiteColor] : [UIColor blackColor]);
}

@end
