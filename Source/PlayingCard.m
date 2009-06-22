/*

File: PlayingCard.m

Abstract: A standard Western playing card.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright © 2007 Apple Inc. All Rights Reserved.

*/


#import "PlayingCard.h"
#import "QuartzUtils.h"


/**  WARNING: THIS CODE REQUIRES GARBAGE COLLECTION!
 **  This sample application uses Objective-C 2.0 garbage collection.
 **  Therefore, the source code in this file does NOT perform manual object memory management.
 **  If you reuse any of this code in a process that isn't garbage collected, you will need to
 **  add all necessary retain/release/autorelease calls, and implement -dealloc methods,
 **  otherwise unpleasant leakage will occur!
 **/


@implementation PlayingCard


+ (NSRange) serialNumberRange;
{
    return NSMakeRange(1,52);
}


- (CALayer*) createFront
{
    CALayer *front = [super createFront];
    NSString *name = [NSString stringWithFormat: @"%@%@",
                      self.rankString, self.suitString];
    
    CGColorRef suitColor = self.suitColor;
    CATextLayer *label;
    label = AddTextLayer(front, name, [NSFont systemFontOfSize: 18],
                         kCALayerMaxXMargin | kCALayerMinYMargin);
    label.foregroundColor = suitColor;
    label = AddTextLayer(front, name, [NSFont systemFontOfSize: 18],
                         kCALayerMaxXMargin | kCALayerMaxYMargin);
    label.foregroundColor = suitColor;
    label.anchorPoint = CGPointMake(1,1);
    [label setValue: [NSNumber numberWithFloat: M_PI] forKeyPath: @"transform.rotation"];
    
    label = AddTextLayer(front, self.faceSymbol, [NSFont systemFontOfSize: 80],
                         kCALayerWidthSizable | kCALayerHeightSizable);
    label.foregroundColor = suitColor;
    return front;
}


- (CardRank) rank       {return (self.serialNumber-1)%13 + 1;}
- (CardSuit) suit       {return (self.serialNumber-1)/13;}

- (CardColor) color
{
    CardSuit suit = self.suit;
    return suit==kSuitDiamonds || suit==kSuitHearts ?kColorRed :kColorBlack;
}

-(id) initWithSuit:(CardSuit) suit rank:(CardRank) rank andPosition:(CGPoint)pos {
	int serialNumber = suit*13 + rank;
	return [super initWithSerialNumber:serialNumber position:pos];
}

- (NSString*) suitString
{
    return [@"\u2663\u2666\u2665\u2660" substringWithRange: NSMakeRange(self.suit,1)];
}

- (NSString*) rankString
{
    CardRank rank = self.rank;
    if( rank == 10 )
        return @"10";
    else
        return [@"A234567890JQK" substringWithRange: NSMakeRange(rank-1,1)];
}

- (CGColorRef) suitColor
{
    static CGColorRef kSuitColor[4];
    if( ! kSuitColor[0] ) {
        kSuitColor[0] = kSuitColor[3] = kBlackColor;
        kSuitColor[1] = kSuitColor[2] = CGColorCreateGenericRGB(1, 0, 0, 1);
    }
    return kSuitColor[self.suit];
}


- (NSString*) faceSymbol
{
    int rank = self.rank;
    if( rank < kRankJack )
        return self.suitString;
    else
        return [@"\u265E\u265B\u265A" substringWithRange: NSMakeRange(rank-kRankJack,1)]; // actually chess symbols
}


- (NSString*) description
{
    return [NSString stringWithFormat: @"%@[%@%@]",self.class,self.rankString,self.suitString];
}


@end
