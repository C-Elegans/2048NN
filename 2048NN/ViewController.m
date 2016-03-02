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
@implementation ViewController
float output[4];
float input[17];
NSMutableArray<CENeuralNetwork*>* networks;
- (void)viewDidLoad {
	[super viewDidLoad];
	networks = [NSMutableArray new];
	for(int i=0;i<100;i++){
		[networks addObject:[[CENeuralNetwork alloc]init:17 outputs:4 layers:5 layerSize:80]];
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self trainNetworks];
	});
	
	// Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
	
}
-(void)sortNetworks{
	[networks sortUsingComparator:^NSComparisonResult(CENeuralNetwork* one, CENeuralNetwork* two) {
		return one.score - two.score;
	}];
}
-(void)breedNetworks{
	NSMutableArray<CENeuralNetwork*>* newNetworks = [NSMutableArray new];
	for(int i=0;i<10;i++){
		for(int j=i+1;j<10;j++){
			[newNetworks addObject:[CENeuralNetwork breedNetwork:[networks objectAtIndex:i] with:[networks objectAtIndex:j]]];
		}
	}
	for(int i=0;i<30;i++){
		[newNetworks addObject:[CENeuralNetwork breedNetwork:[networks objectAtIndex:i] with:[networks objectAtIndex:[networks count]-(i+1)]]];
	}
	for(int i=0;i<20;i++){
		[newNetworks addObject:[[CENeuralNetwork alloc]init:17 outputs:4 layers:5 layerSize:80]];
	}
	networks = newNetworks;
}
-(void)trainNetworks{
	GameView* gv = (GameView*)self.view;
	int epoch = 0;
	while(1){
		
		for(CENeuralNetwork* net in networks){
			int stopped = 0;
			[gv reset];
			int i;
			for(i=0;i<100;i++){
				
				[gv getFloats:input];
				[net solve:input outputs:output];
				dispatch_group_t group = dispatch_group_create();
				dispatch_group_enter(group);
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)/100), dispatch_get_main_queue(), ^{
					
					[gv activate:output];
					dispatch_group_leave(group);
				});
				dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
				
				
				
				if(!gv.didMove)stopped++;
				if(stopped>5)break;
			}
			net.score = (float)gv.score;
		}
		[self sortNetworks];
		NSLog(@"Epoch: %d max score: %f",epoch,[networks firstObject].score);
		[self breedNetworks];
		epoch++;
	}
}

@end
