//
//  NetDisplayView.h
//  2048NN
//
//  Created by Michael Nolan on 3/4/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CENeuralNetwork.h"
#import "CENetworkLayer.h"
@interface NetDisplayView : NSView
@property CENeuralNetwork* netToDisplay;
@end
