#import "SpiderSolitaireGame.h"
#import "Deck.h"
#import "PlayingCard.h"
#import "Stack.h"


#define kStackHeight 500


/**  WARNING: THIS CODE REQUIRES GARBAGE COLLECTION!
 **  This sample application uses Objective-C 2.0 garbage collection.
 **  Therefore, the source code in this file does NOT perform manual object memory management.
 **  If you reuse any of this code in a process that isn't garbage collected, you will need to
 **  add all necessary retain/release/autorelease calls, and implement -dealloc methods,
 **  otherwise unpleasant leakage will occur!
 **/


@implementation SpiderSolitaireGame


- (id) initWithBoard: (CALayer*)board
{
    self = [super initWithBoard: board];
    if (self != nil) {
        [self setNumberOfPlayers: 1];
        
		stacks = [[NSMutableArray alloc] init];
		
        //_deck = [[Deck alloc] initWithPlayingCards:2 numberOfSuites:2];
		_deck = [[Deck alloc] initWithPlayingCards:2 numberOfSuites:2];
		NSUInteger i, count = [_deck.cards count];
		for (i = 0; i < count; i++) {
			PlayingCard * obj = [_deck.cards objectAtIndex:i];
			NSLog(@"added card: %@", obj);
		}
		
		[_deck shuffle];	
		CGPoint p = CGPointMake(kCardWidth/2+16,kCardHeight/2+16);
        _deck.position = p;
        [board addSublayer: _deck];        
		
		
        for( int s=0; s<10; s++ ) {
            Stack *stack = [[Stack alloc] initWithStartPos: CGPointMake(kCardWidth/2,
                                                                        kStackHeight-kCardHeight/2.0)
                                                   spacing: CGSizeMake(0,-22)];
            stack.frame = CGRectMake(100 + s*(kCardWidth+16),16, kCardWidth,kStackHeight);
            stack.backgroundColor = nil;
            stack.dragAsStacks = YES;
            [board addSublayer: stack];
            [stacks addObject:stack];
        }
		
		//dealing 54 cards
		for (int c=0; c<54; c++) {
			Stack *stack = [stacks objectAtIndex: c % [stacks count]];
			[stack addBit: [_deck removeTopCard]];
		}
		
		//setting the topmost cards to be faced up		
			for(Stack* stack in stacks)
				[self faceupTopmostCardOfStack:stack];    
		
        [self nextPlayer];
    }
    return self;
}

-(void) checkAndRemoveFullRowOfStack: (Stack* )stack {
	
	if([stack.bits count] < 13)
		return;
		
	PlayingCard *topCard = (PlayingCard*)[stack topBit];
	if(topCard.rank != kRankAce)
		return;
	
	int indexOfTopCard = [stack.bits indexOfObject:topCard];
	
	int index = indexOfTopCard;
	//index runterzählen
	
	for (int rank = kRankAce; rank <= kRankKing; rank++) {
		index = indexOfTopCard - (rank - kRankAce);
		
		PlayingCard *cardToCheck = [stack.bits objectAtIndex:index];
		if(cardToCheck.suit != topCard.suit)
			return;
		
		if(cardToCheck.rank != rank)
			return;

		//success
		if(cardToCheck.rank == kRankKing) 
		{
			NSLog(@"FOUND FULL ROW");		
			for(int indexOfCardToRemove = indexOfTopCard; indexOfCardToRemove >= index; indexOfCardToRemove --)
			{
				PlayingCard *cardToRemove = [stack.bits objectAtIndex:indexOfCardToRemove];
				[stack removeBit:cardToRemove];
			}
			//turn the remaining topmost-card facedUp
			[self faceupTopmostCardOfStack:stack];
			return;
		}
	}
}

-(void) checkForFullRows {
	for(Stack* stack in stacks)
		[self checkAndRemoveFullRowOfStack: stack];
}


- (BOOL) clickedBit: (Bit*)bit
{
    if( [bit isKindOfClass: [Card class]] ) {
        Card *card = (Card*)bit;
        if( card.holder == _deck ) {
            
			// Click on deck deals 1 card to each stack, if none of them is empty
			for (int i=0; i<[stacks count]; i++) {
				Card *card = [_deck removeTopCard];
				if(card) {
					Stack *stack = [stacks objectAtIndex:i];
					[stack addBit:card];
					card.faceUp=YES;
				}
			}		    
			[self checkForFullRows];
            [self endTurn];
            return YES;
        }
		else {
            // Click on a card elsewhere turns it face-up:
            if( ! card.faceUp ) {
                card.faceUp = YES;
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) canBit: (Bit*)bit moveFrom: (id<BitHolder>)src
{
    if( [bit isKindOfClass: [DraggedStack class]] ) {
		NSArray *draggedCards = [(DraggedStack*)bit bits];
		
		PlayingCard *bottomCard = [draggedCards objectAtIndex: 0];
		
		for (int carcIndex=0; carcIndex < [draggedCards count]; carcIndex++) {
			PlayingCard *card = [draggedCards objectAtIndex: carcIndex];
			if (bottomCard.suit != card.suit)
				return NO;
			if((bottomCard.rank - carcIndex) != card.rank)
				return NO;
		}
//        Card *bottomSrc = [[(DraggedStack*)bit bits] objectAtIndex: 0];
//        if( ! bottomSrc.faceUp )
//            return NO;
    }
	NSLog(@"Card %@ is allowed to get moved", bit);
    return YES;
}

- (BOOL) canBit: (Bit*)bit moveFrom: (id<BitHolder>)src to: (id<BitHolder>)dst
{
    if( src==_deck || dst==_deck)
        return NO;
    
    // Find the bottom card being moved, and the top card it's moving onto:
    PlayingCard *bottomSrc;
    if( [bit isKindOfClass: [DraggedStack class]] )
        bottomSrc = [[(DraggedStack*)bit bits] objectAtIndex: 0];
    else
        bottomSrc = (PlayingCard*)bit;
    
    PlayingCard *topDst;
    if( [dst isKindOfClass: [Deck class]] ) {
        // Dragging to an ace pile:
        if( ! [bit isKindOfClass: [Card class]] )
            return NO;
        topDst = (PlayingCard*) ((Deck*)dst).topCard;
        if( topDst == nil )
            return bottomSrc.rank == kRankAce;
        else
            return bottomSrc.suit == topDst.suit && bottomSrc.rank == topDst.rank+1;
        
    } else {
        // Dragging to a card stack:
        topDst = (PlayingCard*) ((Stack*)dst).topBit;
        if( topDst == nil )
            return YES ;//bottomSrc.rank == kRankKing;
        else
            //return bottomSrc.suit == topDst.suit && bottomSrc.rank == topDst.rank-1;
			return bottomSrc.rank == topDst.rank-1;
    }
}

- (void) faceupTopmostCardOfStack: (Stack *) stack  {
  if([stack.bits count] > 0)
		{
			((Card*)stack.bits.lastObject).faceUp = YES;
		}

}
- (void) bit: (Bit*)bit movedFrom: (id<BitHolder>)src to: (id<BitHolder>)dst {
	if( [src isKindOfClass: [Stack class]] ) {
		Stack *stack = (Stack*)src;
		NSLog(@"Stack is now: %@", stack);
		
		[self faceupTopmostCardOfStack: stack];
		
	}	
	[self checkForFullRows];
	[self endTurn];
}


- (Player*) checkForWinner
{
	for(Stack *stack in stacks)
	{
		if([stack.bits count] > 0)
			return nil;
	}
	
	return _currentPlayer;
}



@end
