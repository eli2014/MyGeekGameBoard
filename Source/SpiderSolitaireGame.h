

#import "Game.h"
@class Deck, Stack;


/** The classic card solitaire game Klondike.
 See: http://en.wikipedia.org/wiki/Klondike_(solitaire) */
@interface SpiderSolitaireGame : Game {
    Deck *_deck;
    Deck *_aces[4];
	
	NSMutableArray *stacks;
}

- (void)faceupTopmostCardOfStack:(Stack *) stack;




@end
