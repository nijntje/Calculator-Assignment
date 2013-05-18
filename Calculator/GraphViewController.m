//
//  GraphViewController.m
//  Calculator
//
//  Created by danielle vass on 09/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController() <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *barTitle;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem; 
@synthesize toolbar = _toolbar;
@synthesize barTitle = _barTitle;
@synthesize popoverController;



- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

#define FAVORITES_KEY @"CalculatorGraphViewController.Favorites"

- (IBAction)addToFavorites:(id)sender
{
    CalculatorBrain *brain = self.program;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    [favorites addObject:brain.program];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]) {
        // this if statement added after lecture to prevent multiple popovers
        // appearing if the user keeps touching the Favorites button over and over
        // simply remove the last one we put up each time we segue to a new one
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = popoverSegue.popoverController; // might want to be popover's delegate and self.popoverController = nil on dismiss?
        }
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}
*/

/*
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program
{
    self.program = program;
    
    // if you wanted to close the popover when a graph was selected
    // you could uncomment the following line
    // you'd probably want to set self.popoverController = nil after doing so
    // [self.popoverController dismissPopoverAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES]; // added after lecture to support iPhone
}
*/
 
// added after lecture to support deletion from the table
// deletes the given program from NSUserDefaults (including duplicates)
// then resets the Model of the sender
/*
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                               deletedProgram:(id)program
{
    CalculatorBrain *brain = program;
    
    NSString *deletedProgramDescription = [CalculatorBrain descriptionOfProgram:program];
    NSMutableArray *favorites = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (id program in [defaults objectForKey:FAVORITES_KEY]) {
        if (![[CalculatorBrain descriptionOfProgram:brain.program] isEqualToString:deletedProgramDescription]) {
            [favorites addObject:brain];
        }
    }
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
    sender.programs = favorites;
}

*/
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)setProgram:(CalculatorBrain *)program
{
    _program = program;
    
    CalculatorBrain *brain = self.program;
    if ([self splitViewController]) {
        //barButtonItem.title = @"Calculator";
        self.barTitle.title = [NSString stringWithFormat:@"f(x) = %@", [CalculatorBrain descriptionOfProgram:brain.program]];
    } else {
        self.title = [NSString stringWithFormat:@"f(x) = %@", [CalculatorBrain descriptionOfProgram:brain.program]];
    }
    
    [self.graphView setNeedsDisplay]; // any time our Model changes, redraw our View
}


- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:3];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.graphView addGestureRecognizer:tapGestureRecognizer];
    
    
    self.graphView.dataSource = self;
}


- (CalculatorBrain *)programForGraphView:(GraphView *)sender
{
    return (self.program);
}

- (float)functionX:(float)x forGraphView:(GraphView *)sender {
    
    CalculatorBrain *brain = self.program;
    [brain addVariable:@"x" withValue:x];
    
    return [CalculatorBrain runProgram:brain.program usingVariableValues:brain.variableValues];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.graphView setNeedsDisplay];
    return YES; // support all orientations
}


@end
