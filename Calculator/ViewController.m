//
//  ViewController.m
//  Calculator
//
//  Created by danielle vass on 16/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"


@interface ViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userHasOneDotAlready;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) int diagnosis;
@end

@implementation ViewController

@synthesize display;
@synthesize history;

@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize userHasOneDotAlready;
@synthesize brain = _brain;
@synthesize diagnosis = _diagnosis;


// Does the bar button item transfer from existing detail view controller to destination


- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter {
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = (id<UISplitViewControllerDelegate>)self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Calculator";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewBarButtonItemPresenter] splitViewBarButtonItem];
    [[self splitViewBarButtonItemPresenter] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (GraphViewController *)splitViewGraphViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([self splitViewController]) {
        return YES;
    }
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)viewDidUnload {
    [self setHistory:nil];
    [super viewDidUnload];
}

- (IBAction)graphPressed {
    
    if ([self splitViewGraphViewController]) {
        [self splitViewGraphViewController].program = self.brain;  
    } else {
        [self performSegueWithIdentifier:@"showGraph" sender:self]; 
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showGraph"]) {
        [segue.destinationViewController setProgram:self.brain];
    }
}


- (CalculatorBrain *)brain
{
    if(!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)updateLabels {
    
   self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.brain.variableValues]];
    
    self.history.text = [NSString stringWithFormat:@"%@ =", [CalculatorBrain descriptionOfProgram:self.brain.program]];
    
}

- (NSString *)getVariableString {
    
    NSSet * variablesUsed = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    
    NSDictionary *variableValues = self.brain.variableValues;
    NSString *variables = @"";
    NSEnumerator * enumerator = [variablesUsed objectEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        if (![variables isEqualToString:@""]) {
            variables = [variables stringByAppendingFormat:@", "];
        }
        variables = [variables stringByAppendingFormat:@"%@ = %g",key, [[variableValues objectForKey:key] doubleValue]];
    }
    return variables;
}

- (IBAction)digitPressed:(UIButton *)sender 
{

    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingFormat:@"%@", sender.currentTitle];
    } else {
        self.display.text = sender.currentTitle;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}
- (IBAction)clearPressed {
    
    [self.brain newStack];
    
    self.history.text = @"";
    self.display.text = @"0"; 

    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]]; //add value to stack

    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasOneDotAlready = NO;
    
    [self updateLabels]; 
    
}

- (IBAction)dotPressed{
    
    if (!self.userHasOneDotAlready) {
        self.userHasOneDotAlready = YES;
        
        if (!self.userIsInTheMiddleOfEnteringANumber) {
            self.userIsInTheMiddleOfEnteringANumber = YES;
            self.display.text = @"0";
        }
        
        self.display.text = [self.display.text stringByAppendingFormat:@"."];
    }
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    [self.brain performOperation:sender.currentTitle];
    
    [self updateLabels];
    
}

- (IBAction)backPressed {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([[self.display.text substringFromIndex:([self.display.text length] - 1)] isEqualToString:@"."]) {
            self.userHasOneDotAlready = NO;
        }
        self.display.text = [self.display.text substringToIndex:([self.display.text length] - 1)];
        if (![self.display.text length]) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            [self backPressed];
        }
    } else {
        [self.brain removeLastOp];
        [self updateLabels];
    }
    
}
- (IBAction)varPressed:(UIButton *)sender {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *var = sender.currentTitle;
    [self.brain performOperation:var];
    [self updateLabels];
    
}


@end
