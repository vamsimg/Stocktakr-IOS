//
//  KeypadView.h
//  Stocktakr
//
//  Created by Sherman Lo on 21/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KeypadViewDelegate <NSObject>

- (void)keyTapped:(NSString *)character;
- (void)backspaceKeyTapped;

@end


@interface KeypadView : UIView

@property (nonatomic, weak) id<KeypadViewDelegate> delegate;

@end
