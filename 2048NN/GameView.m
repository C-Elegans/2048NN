//
//  GameView.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "GameView.h"
#define TileSize 50
@implementation GameView
int tiles[4][4];
NSDictionary<NSNumber*,NSColor*>* colors;
NSLock *lock;

-(void)awakeFromNib{
	colors = @{@2:[NSColor colorWithRed:239/255.0 green:228/255.0 blue:218/255.0 alpha:255/255.0],
			   @4:[NSColor colorWithRed:238/255.0 green:224/255.0 blue:200/255.0 alpha:255/255.0],
			   @0:[NSColor darkGrayColor],
			   @8:[NSColor colorWithRed:243/255.0 green:178/255.0 blue:121/255.0 alpha:255/255.0],
			   @16:[NSColor colorWithRed:245/255.0 green:149/255.0 blue:99/255.0 alpha:255/255.0],
			   @32:[NSColor colorWithRed:247/255.0 green:125/255.0 blue:95/255.0 alpha:255/255.0]
			   };
	tiles[1][2]=4;
	tiles[1][1] = 2;
	tiles[2][1] = 2;
	_score = 0;
	lock = [NSLock new];
}
- (void)drawRect:(NSRect)dirtyRect {
	[lock lock];
	
	CGPoint topLeft;
	topLeft.x = dirtyRect.size.width/2 - 2*TileSize;
	topLeft.y = dirtyRect.size.height/2 - 3*TileSize;
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect scoreRect = CGRectMake(10, 10, 200, 50);
	[[NSString stringWithFormat:@"%d",_score]drawInRect:scoreRect withAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial Black" size:20]}];
    [super drawRect:dirtyRect];
	for(int i=0;i<4;i++){
		for(int j=0;j<4;j++){
			int val = tiles[j][i];
			
			CGRect rect = CGRectMake(i*50 + topLeft.x +2, (200-(j*50)) + topLeft.y +2, 46, 46);
			CGContextSetFillColorWithColor(context, [colors[@(val)] CGColor]);
			NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:0 yRadius:0];
			[path fill];
			[path stroke];
			NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
			[paragraphStyle setAlignment:NSTextAlignmentCenter];
			if(val >0)[[NSString stringWithFormat:@"%d",val]drawInRect:rect withAttributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[NSFont fontWithName:@"Arial Black" size:20]}];
			
		}
	}
	[lock unlock];
}
-(BOOL)acceptsFirstResponder{
	return YES;
}
-(void)moveTilesDown{
	for(int k=0;k<3;k++){
		for(int i=0;i<4;i++){
			for(int j=2;j>=0;j--){
				int val = tiles[j][i];
				if (tiles[j+1][i] == 0 && val >0){
					tiles[j][i] = 0;
					tiles[j+1][i] = val;
				}
				else if(tiles[j+1][i] == val && val >0){
					tiles[j][i] = 0;
					tiles[j+1][i] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(void)moveTilesUp{
	for(int k=0;k<3;k++){
		for(int i=0;i<4;i++){
			for(int j=1;j<4;j++){
				int val = tiles[j][i];
				if (tiles[j-1][i] == 0 && val >0){
					tiles[j][i] = 0;
					tiles[j-1][i] = val;
				}else if(tiles[j-1][i] == val && val >0){
					tiles[j][i] = 0;
					tiles[j-1][i] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(void)moveTilesRight{
	for(int k=0;k<3;k++){
		for(int j=0;j<4;j++){
			for(int i=2;i>=0;i--){
				int val=tiles[j][i];
				if(tiles[j][i+1]==0 &&val>0){
					tiles[j][i] = 0;
					tiles[j][i+1] = val;
				}
				else if(tiles[j][i+1] == val && val >0){
					tiles[j][i] = 0;
					tiles[j][i+1] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(void)moveTilesLeft{
	for(int k=0;k<3;k++){
		for(int j=0;j<4;j++){
			for(int i=1;i<4;i++){
				int val=tiles[j][i];
				if(tiles[j][i-1]==0 &&val>0){
					tiles[j][i] = 0;
					tiles[j][i-1] = val;
				}
				else if(tiles[j][i-1] == val && val >0){
					tiles[j][i] = 0;
					tiles[j][i-1] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(int)countEmpty{
	int sum=0;
	for(int i=0;i<4;i++){
		for(int j=0;j<4;j++){
			if(tiles[i][j] == 0)sum++;
		}
	}
	return sum;
}
-(void) addRandomTiles{
	int tileToAdd = arc4random_uniform([self countEmpty]);
	int val = arc4random_uniform(2);
	for(int i=0;i<4;i++){
		for(int j=0;j<4;j++){
			if(tiles[j][i] == 0){
				if(tileToAdd == 0){
					tiles[j][i] = val!=0?2:4;
					tileToAdd--;
					
					
				}
				tileToAdd--;
			}
		}
	}
}
-(void)pressKey:(short)key{
	[lock lock];
	int tempArray[4][4];
	memcpy(tempArray, tiles, sizeof(tempArray));
	switch (key)
	{
		case LEFT:
		[self moveTilesLeft];
		break;
		case RIGHT:
		[self moveTilesRight];
		break;
		case DOWN:
		[self moveTilesDown];
		break;
		case UP:
		[self moveTilesUp];
		break;
		
	}
	
	if(memcmp(tempArray, tiles, sizeof(tempArray))){
		[self addRandomTiles];
		//if(arc4random_uniform(7)==0)[self addRandomTiles];
	}
	
	[lock unlock];
	[self setNeedsDisplay:YES];
}
-(void)keyDown:(NSEvent *)theEvent{
	[self pressKey:[theEvent keyCode]];
}
@end
