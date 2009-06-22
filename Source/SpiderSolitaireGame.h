

#import "Game.h"
@class Deck, Stack;


/** The classic card solitaire game Klondike.
 See: http://en.wikipedia.org/wiki/Klondike_(solitaire) */
@interface SpiderSolitaireGame : Game {
    Deck *_deck, *_sink;
    Deck *_aces[4];
}

@end
