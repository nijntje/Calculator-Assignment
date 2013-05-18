//
//  GraphView.h
//  Calculator
//
//  Created by danielle vass on 09/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"

@class GraphView;

@protocol GraphViewDataSource
- (CalculatorBrain *)programForGraphView:(GraphView *)sender;
- (float)functionX:(float)x forGraphView:(GraphView *)sender;
@end


@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)tap:(UITapGestureRecognizer *)gesture;



@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;


@end
