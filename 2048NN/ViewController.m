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
#import "GameBoard.h"
#define LAYERS 5
#define LAYERSIZE 32

@implementation ViewController
float output[2];
float input[17];
float highScore;
float last8[8];
int avgindex = 0;
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
	for(int i=1;i<5;i++){
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
	for(int i=0;i<30;i++){
	dispatch_group_enter(group);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		CENeuralNetwork* net =[CENeuralNetwork breedNetwork:[networks objectAtIndex:i] with:[networks objectAtIndex:[networks count]-(i+1)]];
		[lock lock];
		[newNetworks addObject: net];
		[lock unlock];
		dispatch_group_leave(group);
	});
	}
	for(int i=0;i<20;i++){
	dispatch_group_enter(group);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		CENeuralNetwork* net = [[CENeuralNetwork alloc]init:17 outputs:2 layers:LAYERS layerSize:LAYERSIZE];
		[lock lock];
		[newNetworks addObject:net];
		[lock unlock];
		dispatch_group_leave(group);
	});
		
	}
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
		
		[networks enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(CENeuralNetwork * _Nonnull net, NSUInteger idx, BOOL * _Nonnull stop) {
			GameBoard *gb = [GameBoard new];
			
			int stopped = 0;
			
			
			while(stopped<2){
				
				[gb getFloats:input];
				[net solve:input outputs:output];
				
				[gb activate:output display:delegate.display];
			
				if(!gb.didMove)stopped++;
				else stopped = 0;
				
			}
			net.score = (float)gb.score;
			
		}];
		[self sortNetworks];
		if([networks lastObject].score > highScore){
			highScore = [networks lastObject].score;
		}
		
		last8[avgindex++&7] =  [networks lastObject].score;
		float sum = 0;
		for(int i=0;i<8;i++){
			sum += last8[i];
		}
		printf("%s", [[NSString stringWithFormat:@"Epoch: %5d max score: %7.0f, high: %8.0f, avg: %7.0f\n",epoch,[networks lastObject].score, highScore,sum/8] UTF8String]);
		
		if(!(epoch>50 && [networks lastObject].score < 4000))[self breedNetworks];
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
