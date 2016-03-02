//
//  GameView.h
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GameView : NSView
@property int score;
@property bool didMove;
#define LEFT 123
#define RIGHT 124
#define DOWN 125
#define UP 126
@end
