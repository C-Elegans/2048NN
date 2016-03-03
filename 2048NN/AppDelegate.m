//
//  AppDelegate.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_delay = YES;
	_display = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}
- (IBAction)toggleDelay:(id)sender {
	_delay = ! _delay;
}
- (IBAction)toggleView:(id)sender {
	_display = ! _display;
}

@end
