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
#define LAYERS 3
#define LAYERSIZE 32

@implementation ViewController
float output[2];
float input[17];
float highScore;
NSMutableArray<CENeuralNetwork*>* networks;
- (void)viewDidLoad {
	[super viewDidLoad];
	networks = [NSMutableArray new];
	[self initNetworks];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self trainNetworks];
	});
	highScore = 0;
	// Do any additional setup after loading the view.
}
-(void)initNetworks{
	[networks removeAllObjects];
	for(int i=0;i<150;i++){
		[networks addObject:[[CENeuralNetwork alloc]init:17 outputs:2 layers:LAYERS layerSize:LAYERSIZE]];
	}
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
	NSLock* lock = [NSLock new];
	NSMutableArray<CENeuralNetwork*>* newNetworks = [NSMutableArray new];
	dispatch_group_t group = dispatch_group_create();
	for(int i=1;i<3;i++){
		[newNetworks addObject:[networks objectAtIndex:[networks count]-i]];
	}
	for(int i=1;i<25;i++){
		for(int j=i+1;j<25;j++){
			dispatch_group_enter(group);
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			CENeuralNetwork* net = [CENeuralNetwork breedNetwork:[networks objectAtIndex:[networks count]-i] with:[networks objectAtIndex:[networks count]-j]];
			[lock lock];
			[newNetworks addObject:net];
			[lock unlock];
			dispatch_group_leave(group);
		});
		}
	}
	for(int i=0;i<10;i++){
	dispatch_group_enter(group);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		CENeuralNetwork* net =[CENeuralNetwork breedNetwork:[networks objectAtIndex:i] with:[networks objectAtIndex:[networks count]-(i+1)]];
		[lock lock];
		[newNetworks addObject: net];
		[lock unlock];
		dispatch_group_leave(group);
	});
	}
	/*for(int i=0;i<20;i++){
	dispatch_group_enter(group);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		CENeuralNetwork* net = [[CENeuralNetwork alloc]init:17 outputs:2 layers:LAYERS layerSize:LAYERSIZE];
		[lock lock];
		[newNetworks addObject:net];
		[lock unlock];
		dispatch_group_leave(group);
	});
		
	}*/
	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	
	networks = newNetworks;
}
-(void)mutateNetworks{
	[networks enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(CENeuralNetwork * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[obj mutate];
	}];
}
-(void)trainNetworks{
	GameView* gv = (GameView*)self.view;
	int epoch = 0;
	dispatch_group_t group = dispatch_group_create();
	AppDelegate* delegate = (AppDelegate*)[NSApp delegate];
	while(1){
		[gv reseed];
		for(CENeuralNetwork* net in networks){
			int stopped = 0;
			[gv reset];
			
			while(stopped<2){
				
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
				else stopped = 0;
				
			}
			net.score = (float)gv.score;
			if(gv.score>highScore){
				highScore = gv.score;
			}
		}
		[self sortNetworks];
		NSLog(@"Epoch: %d max score: %.0f, high: %.0f",epoch,[networks lastObject].score, highScore);
		[self breedNetworks];
		[self mutateNetworks];
		
		epoch++;
		if(epoch>50 && highScore<2000){
			[self initNetworks];
			epoch = 0;
			highScore = 0;
		}
		if(epoch>100 && highScore<7000){
			[self initNetworks];
			epoch = 0;
			highScore = 0;
		}
	}
}

@end
