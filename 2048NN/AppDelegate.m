//
//  AppDelegate.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "AppDelegate.h"
#import "CENeuralNetwork.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	CENeuralNetwork* network = [[CENeuralNetwork alloc] init:17 outputs:4 layers:5 layerSize:80];
	float input[17] = {0,0,1,0,0,0,2,0,3,0,0,0,0,0,0,0,0};
	float output[4];
	[network solve:input outputs:output];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
