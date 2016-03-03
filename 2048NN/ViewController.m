//
//  ViewController.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "ViewController.h"
#import "CENeuralNetwork.h"
#import "GameView.h"
#import "AppDelegate.h"
#define LAYERS 10
#define LAYERSIZE 128

@implementation ViewController
float output[4];
float input[17];
float highScore;
NSMutableArray<CENeuralNetwork*>* networks;
- (void)viewDidLoad {
	[super viewDidLoad];
	networks = [NSMutableArray new];
	for(int i=0;i<150;i++){
		[networks addObject:[[CENeuralNetwork alloc]init:17 outputs:4 layers:LAYERS layerSize:LAYERSIZE]];
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self trainNetworks];
	});
	highScore = 0;
	// Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
	
}
-(void)sortNetworks{
	[networks sortUsingComparator:^NSComparisonResult(CENeuralNetwork* one, CENeuralNetwork* two) {
		return [@(one.score) compare:@(two.score)];
	}];
}
-(IBAction) toggleDelay:(id)sender{
	
}
-(void)breedNetworks{
	NSMutableArray<CENeuralNetwork*>* newNetworks = [NSMutableArray new];
	for(int i=1;i<15;i++){
		[newNetworks addObject:[networks objectAtIndex:[networks count]-i]];
	}
	for(int i=1;i<20;i++){
		for(int j=i+1;j<20;j++){
			[newNetworks addObject:[CENeuralNetwork breedNetwork:[networks objectAtIndex:[networks count]-i] with:[networks objectAtIndex:[networks count]-j]]];
		}
	}
	for(int i=0;i<30;i++){
		[newNetworks addObject:[CENeuralNetwork breedNetwork:[networks objectAtIndex:i] with:[networks objectAtIndex:[networks count]-(i+1)]]];
	}
	for(int i=0;i<20;i++){
		[newNetworks addObject:[[CENeuralNetwork alloc]init:17 outputs:4 layers:LAYERS layerSize:LAYERSIZE]];
	}
	networks = newNetworks;
}
-(void)trainNetworks{
	GameView* gv = (GameView*)self.view;
	int epoch = 0;
	dispatch_group_t group = dispatch_group_create();
	AppDelegate* delegate = (AppDelegate*)[NSApp delegate];
	while(1){
		
		for(CENeuralNetwork* net in networks){
			int stopped = 0;
			[gv reset];
			
			while(stopped<5){
				
				[gv getFloats:input];
				[net solve:input outputs:output];
				if(delegate.delay){
				dispatch_group_enter(group);
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)/100), dispatch_get_main_queue(), ^{
					
					[gv activate:output display:delegate.display];
					dispatch_group_leave(group);
				});
				dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
				}else{
					dispatch_sync(dispatch_get_main_queue(), ^{
						[gv activate:output display:delegate.display];
					});
				}
				
				
				if(!gv.didMove)stopped++;
				
			}
			net.score = (float)gv.score;
			if(gv.score>highScore){
				highScore = gv.score;
			}
		}
		[self sortNetworks];
		NSLog(@"Epoch: %d max score: %.0f, high: %.0f",epoch,[networks lastObject].score, highScore);
		[self breedNetworks];
		epoch++;
	}
}

@end
