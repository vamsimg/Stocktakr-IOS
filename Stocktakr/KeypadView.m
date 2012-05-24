//
//  KeypadView.m
//  Stocktakr
//
//  Created by Sherman Lo on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeypadView.h"


#define MARGIN 5
#define BUTTON_SPACING 5


@interface KeypadView ()

- (void)keypadButtonTapped:(UIButton *)button;

@end


@implementation KeypadView

@synthesize delegate = delegate_;


#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		NSArray *labels = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @".", @"0", @"⌫", nil];
		
		self.backgroundColor = [UIColor lightGrayColor];
		
		int buttonWidth = ((CGRectGetWidth(frame) - (MARGIN * 2) - (BUTTON_SPACING * 2)) / 3);
		int buttonHeight = ((CGRectGetHeight(frame) - (MARGIN * 2) - (BUTTON_SPACING * 3)) / 4);
		
		for (int i = 0; i < [labels count]; i++) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[button setTitle:[labels objectAtIndex:i] forState:UIControlStateNormal];
			[button addTarget:self action:@selector(keypadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
			
			int xPos = i % 3;
			int yPos = i / 3;
			button.frame = CGRectMake(MARGIN + (xPos * (buttonWidth + BUTTON_SPACING)), MARGIN + (yPos * (buttonHeight + BUTTON_SPACING)), buttonWidth, buttonHeight);
			[self addSubview:button];
		}
	}
	return self;
}


#pragma mark - Private methods

- (void)keypadButtonTapped:(UIButton *)button {
	if ([button.titleLabel.text isEqualToString:@"⌫"]) {
		[self.delegate backspaceKeyTapped];
	} else {
		[self.delegate keyTapped:button.titleLabel.text];
	}
}

@end
