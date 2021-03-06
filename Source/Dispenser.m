/*

File: Dispenser.m

Abstract: Provides a supply of identical copies of a particular Bit, one at a time.

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


#import "Dispenser.h"
#import "Piece.h"
#import "QuartzUtils.h"


/**  WARNING: THIS CODE REQUIRES GARBAGE COLLECTION!
 **  This sample application uses Objective-C 2.0 garbage collection.
 **  Therefore, the source code in this file does NOT perform manual object memory management.
 **  If you reuse any of this code in a process that isn't garbage collected, you will need to
 **  add all necessary retain/release/autorelease calls, and implement -dealloc methods,
 **  otherwise unpleasant leakage will occur!
 **/


@implementation Dispenser


- (id) initWithPrototype: (Bit*)prototype quantity: (unsigned)quantity frame: (CGRect)frame
{
    self = [super init];
    if (self != nil) {
        self.backgroundColor = kTranslucentLightGrayColor;
        self.borderColor = kTranslucentGrayColor;
        self.borderWidth = 3;
        self.cornerRadius = 16;
        self.zPosition = kBoardZ;
        self.masksToBounds = YES;
        self.frame = frame;
        [self setPrototype: prototype];
        self.quantity = quantity;
    }
    return self;
}


- (Bit*) bit                {return _bit;}
- (void) setBit: (Bit*)bit  {_bit = bit;}


- (Bit*) createBit
{
    if( _prototype ) {
        Bit *bit = [_prototype copy];
        CGRect bounds = self.bounds;
        bit.position = GetCGRectCenter(bounds);
        return bit;
    } else
        return nil;
}

- (void) x_regenerateCurrentBit
{
    NSAssert(_bit==nil,@"Already have a currentBit");

    [CATransaction begin];
    [CATransaction setValue: (id)kCFBooleanTrue
                     forKey: kCATransactionDisableActions];
    _bit = [self createBit];
    CGPoint pos = _bit.position;
    _bit.position = CGPointMake(pos.x, pos.y+70);
    [self addSublayer: _bit];
    [CATransaction commit];
    
    _bit.position = pos;
}


- (Bit*) prototype
{
    return _prototype;
}

- (void) setPrototype: (Bit*)prototype
{
    _prototype = prototype;
    if( _bit ) {
        [_bit removeFromSuperlayer];
        _bit = nil;
        if( prototype )
            [self x_regenerateCurrentBit];
    }
}


- (unsigned) quantity
{
    return _quantity;
}

- (void) setQuantity: (unsigned)quantity
{
    _quantity = quantity;
    if( quantity > 0 && !_bit )
        [self x_regenerateCurrentBit];
    else if( quantity==0 && _bit ) {
        [_bit removeFromSuperlayer];
        _bit = nil;
    }
}


#pragma mark -
#pragma mark DRAGGING BITS:


- (Bit*) canDragBit: (Bit*)bit
{
    bit = [super canDragBit: bit];
    if( bit==_bit )
        _bit = nil;
    return bit;
}

- (void) cancelDragBit: (Bit*)bit
{
    if( ! _bit )
        _bit = bit;
    else
        [bit removeFromSuperlayer];
}

- (void) draggedBit: (Bit*)bit to: (id<BitHolder>)dst
{
    if( --_quantity > 0 )
        [self performSelector: @selector(x_regenerateCurrentBit) withObject: nil afterDelay: 0.0];
}

- (BOOL) canDropBit: (Bit*)bit atPoint: (CGPoint)point  
{
    return [bit isEqual: _bit];
}

- (BOOL) dropBit: (Bit*)bit atPoint: (CGPoint)point
{
    [bit removeFromSuperlayer];
    return YES;
}


#pragma mark -
#pragma mark DRAG-AND-DROP:


// An image from another app can be dragged onto a Dispenser to change the Piece's appearance.


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if( ! [_prototype isKindOfClass: [Piece class]] )
        return NSDragOperationNone;
    NSPasteboard *pb = [sender draggingPasteboard];
    if( [NSImage canInitWithPasteboard: pb] )
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if( ! [_prototype isKindOfClass: [Piece class]] )
        return NO;
    CGImageRef image = GetCGImageFromPasteboard([sender draggingPasteboard]);
    if( image ) {
        [(Piece*)_prototype setImage: image];
        self.prototype = _prototype;
        return YES;
    } else
        return NO;
}


@end
