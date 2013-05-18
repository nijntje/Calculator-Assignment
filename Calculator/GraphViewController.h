//
//  GraphViewController.h
//  Calculator
//
//  Created by danielle vass on 09/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "CalculatorBrain.h"

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic) CalculatorBrain *program;

@end
