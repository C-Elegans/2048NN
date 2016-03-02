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
	lock = [NSLock new];
}
- (void)drawRect:(NSRect)dirtyRect {
	[lock lock];
	
	CGPoint topLeft;
	topLeft.x = dirtyRect.size.width/2 - 2*TileSize;
	topLeft.y = dirtyRect.size.height/2 - 3*TileSize;
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
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
				}
			}
		}
	}
}
-(void)keyDown:(NSEvent *)theEvent{
	[lock lock];
	switch ([theEvent keyCode])
	{
		case 123:
			[self moveTilesLeft];
			break;
		case 124:
			[self moveTilesRight];
			break;
		case 125:
			[self moveTilesDown];
			break;
		case 126:
			[self moveTilesUp];
			break;
		
	}
	[lock unlock];
	[self setNeedsDisplay:YES];
}
@end
