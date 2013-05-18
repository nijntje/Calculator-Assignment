//
//  CalculatorBrain.h
//  Calculator
//
//  Created by danielle vass on 19/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushOperand:(id)operand usingvariableValues:(NSDictionary *)variableValues;
- (double)performOperation:(NSString *)op;
- (void)newStack; //clear everything
- (void)removeLastOp; //take the last thing element off the stack
- (void)addVariable:(NSString *)variable withValue:(double)value;
- (void)removeVariable:(NSString *)variable;
- (NSDictionary *)variableValues;

@property (nonatomic, readonly) id program;
@property (readonly) NSDictionary *variableValues;

+ (NSString *)descriptionOfProgram:(id)program;
+ (NSString *)describeProgramStack:(NSMutableArray *)stack withPreviousOp:(id)previousOp;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
