//
//  GameBoard.h
//  2048NN
//
//  Created by Michael Nolan on 3/8/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameBoard : NSObject
@property (readonly) int *tiles;
@property float score;
@property bool didMove;
-(void)getFloats:(float*)results;
-(void)pressKey:(short)key display:(BOOL)display;
-(void)activate:(float*) values display:(BOOL)display;
#define LEFT 123
#define RIGHT 124
#define DOWN 125
#define UP 126
@end
