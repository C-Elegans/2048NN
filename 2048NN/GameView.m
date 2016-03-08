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

int seed = 0;
NSDictionary<NSNumber*,NSColor*>* colors;
NSLock *lock;
-(void)reseed{
	arc4random_stir();
	seed = arc4random();
}
-(void)awakeFromNib{
	colors = @{@2:[NSColor colorWithRed:239/255.0 green:228/255.0 blue:218/255.0 alpha:255/255.0],
			   @4:[NSColor colorWithRed:238/255.0 green:224/255.0 blue:200/255.0 alpha:255/255.0],
			   @0:[NSColor darkGrayColor],
			   @8:[NSColor colorWithRed:243/255.0 green:178/255.0 blue:121/255.0 alpha:255/255.0],
			   @16:[NSColor colorWithRed:245/255.0 green:149/255.0 blue:99/255.0 alpha:255/255.0],
			   @32:[NSColor colorWithRed:247/255.0 green:125/255.0 blue:95/255.0 alpha:255/255.0],
			   @64:[NSColor colorWithRed:247/255.0 green:95/255.0 blue:58/255.0 alpha:255/255.0],
			   @128:[NSColor colorWithRed:235/255.0 green:206/255.0 blue:113/255.0 alpha:255/255.0],
			   @256:[NSColor colorWithRed:235/255.0 green:206/255.0 blue:113/255.0 alpha:255/255.0],
			   @512:[NSColor colorWithRed:236/255.0 green:199/255.0 blue:80/255.0 alpha:255/255.0],
			   @1024:[NSColor colorWithRed:237/255.0 green:197/255.0 blue:64/255.0 alpha:255/255.0],
			   @2048:[NSColor colorWithRed:237/255.0 green:196/255.0 blue:4/255.0 alpha:255/255.0]
			   };
	
	[self reset];
	lock = [NSLock new];
}
-(void)reset{
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		seed =arc4random();
	});
	srand(seed);
	_score = 0;
	memset(tiles, 0, sizeof(float)*4*4);
	
}
-(int *)tiles{
	return  (int*)tiles;
}
-(void)setTiles:(int *)t{
	memcpy(tiles, t,sizeof(int)*4*4);
}
- (void)drawRect:(NSRect)dirtyRect {
	
	
	CGPoint topLeft;
	topLeft.x = dirtyRect.size.width/2 - 2*TileSize;
	topLeft.x = MIN(topLeft.x, 100);
	topLeft.y = dirtyRect.size.height/2 - 3*TileSize;
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect scoreRect = CGRectMake(10, dirtyRect.size.height-50, 200, 50);
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
	
}



@end
