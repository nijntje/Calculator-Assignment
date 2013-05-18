//
//  CalculatorBrain.m
//  Calculator
//
//  Created by danielle vass on 19/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import <math.h>

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableDictionary *variables;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize variables = _variables;

#pragma mark - Getters and Setters

- (NSMutableArray *) programStack {
    //initialise a program stack
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}
- (NSMutableDictionary *) variables {
    //initialise a variable set
    if (!_variables) {
        _variables = [[NSMutableDictionary alloc] init];
    }
    return _variables;
}

- (id)program
{   //get the program
    return [self.programStack copy];
}

- (NSDictionary *)variableValues {
    //get variables
    return [self.variables copy];
}

- (void) newStack 
{  //resets the program
    self.programStack = nil;
    self.variables = nil;
}

#pragma mark - descriptions

+ (NSString *)descriptionOfProgram:(id)program {
    //get a description of the program
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    //send the copy of the stack to a method to translate
    return [self describeProgramStack:stack withPreviousOp:nil];
}

+ (NSString *)describeProgramStack:(NSMutableArray *)stack withPreviousOp:(id)previousOp {
    
    NSString *result = @"0";
    id topOfStack = [stack lastObject];
    
    //if element isn't nil
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        //if top is a number
        
        NSNumber *operand = topOfStack;
        result = [NSString stringWithFormat:@"%@", operand];
        
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        //if the top is a string
        
        NSString * operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            NSString *add = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ + %@", [self describeProgramStack:stack withPreviousOp:operation], add];
            if ([previousOp isEqualToString:@"*"] || [previousOp isEqualToString:@"/"]) {
                result = [NSString stringWithFormat:@"(%@)", result];
            }
        } else if ([operation isEqualToString:@"*"]) {
            NSString *mul = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ * %@", [self describeProgramStack:stack withPreviousOp:operation], mul];
        } else if ([operation isEqualToString:@"/"]) {
            NSString *div = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ / %@", [self describeProgramStack:stack withPreviousOp:operation], div];
        } else if ([operation isEqualToString:@"-"]) {
            NSString *sub = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ - %@", [self describeProgramStack:stack withPreviousOp:operation], sub];
            if ([previousOp isEqualToString:@"*"] || [previousOp isEqualToString:@"/"]) {
                result = [NSString stringWithFormat:@"(%@)", result];
            }
        } else if ([operation isEqualToString:@"sin"] || [operation isEqualToString:@"cos"] || [operation isEqualToString:@"sqrt"]) {
            result = [NSString stringWithFormat:@"%@(%@)", operation, [self describeProgramStack:stack withPreviousOp:operation]];
        } else {
            result = [NSString stringWithFormat:@"%@", operation];
        }
    }
    
    if ([stack count] && previousOp == nil) {
        result = [NSString stringWithFormat:@"%@, %@", [self describeProgramStack:stack withPreviousOp:nil], result];
    }
    
    return result;
}

#pragma mark - Calculator operations
    
- (void)pushOperand:(double)operand
{   //put an item on to the stack
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
    [[self class] descriptionOfProgram:self.program];
}

- (void)pushOperand:(id)operand
    usingvariableValues:(NSDictionary *)variableValues
{
    id tempValue = 0;
    if(operand) tempValue = operand;
    
    if ([operand isKindOfClass:[NSNumber class]]) {
        [self.programStack addObject:tempValue];
    }else if ([operand isKindOfClass:[NSString class]]){
         //loook up what the variable is in the dictionary 
        NSDictionary *tempDictionary =nil;
        if(self.variableValues) tempDictionary = self.variableValues;
    
        NSNumber *result =0;
        result = [tempDictionary objectForKey:tempValue];
        [self.programStack addObject:result];
    }
    
}

- (double)performOperation:(NSString *)operation
{   //take an item off the stack
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
    
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)variableValues
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            
            result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] +
            [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            
        } else if ([@"*" isEqualToString:operation]) {
            
            result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] *
            [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            
        } else if ([operation isEqualToString:@"-"]) {
            
            double subtrahend = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] - subtrahend;
            
        } else if ([operation isEqualToString:@"/"]) {
            
            double divisor = [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
            if (divisor) result = [self popOperandOffProgramStack:stack usingVariableValues:variableValues] / divisor;
            
        } else if ([@"π" isEqualToString:operation]) {
            result = 3.1459;
            
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
            
        }else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffProgramStack:stack usingVariableValues:variableValues]);
        }else {
            //dictionary lookup
            id variable = [variableValues objectForKey:operation];
            if ([variable isKindOfClass:[NSNumber class]]) {
                result = [variable doubleValue];
            }
        }

    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues{
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack usingVariableValues:variableValues];
    
}

- (void)removeLastOp {
    //take off the last item
    id lastObject = [self.programStack lastObject];
    if (lastObject) {
        [self.programStack removeLastObject];
    }
}

#pragma mark - Variable operations


- (void)addVariable:(NSString *)variable withValue:(double)value {
    //add variable
    [self.variables setObject:[NSNumber numberWithDouble:value] forKey:variable];
}

- (void)removeVariable:(NSString *)variable {
    //remove a variable
    [self.variables removeObjectForKey:variable];
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    //returns a set of variables used
    NSMutableSet *vars = [[NSMutableSet alloc] init];
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program copy];
    }
    
    for (id op in stack) {
        if ([op isKindOfClass:[NSString class]]) {
            if ([op isEqualToString:@"*"]) {
            } else  if ([op isEqualToString:@"/"]) {
            } else  if ([op isEqualToString:@"-"]) {
            } else  if ([op isEqualToString:@"+"]) {
            } else  if ([op isEqualToString:@"sin"]) {
            } else  if ([op isEqualToString:@"cos"]) {
            } else  if ([op isEqualToString:@"sqrt"]) {
            } else  if ([op isEqualToString:@"π"]) {
            } else {
                [vars addObject:op];
            }
        }
    }
    
    if ([vars count]) {
        return [vars copy];
    } else {
        return nil;
    }
    
}




@end


