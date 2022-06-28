import 'dart:convert';

import 'package:flashcards_app/src/algorithms/pick_cards.dart';
import 'package:flashcards_app/src/algorithms/process_review.dart';
import 'package:flashcards_app/src/backend/app_data_access.dart';
import 'package:flashcards_app/src/data/card.dart';
import 'package:flashcards_app/src/data/deck.dart';
import 'package:flashcards_app/src/frontend/card_display.dart';

class DeckDao {
  final Deck _deck;
  final String _path;
  // bool _edited = false;

  DeckDao(this._path, this._deck);

  // getters
  // bool get edited => _edited;

  // gets the cards in the deck as key value pairs
  List<MetaCard> cards() => _deck.cards
      .asMap()
      .entries
      .map((entry) => MetaCard(entry.key, entry.value))
      .toList();

  /// edit function sets the deckDao as edited
  T _edit<T>(T Function() f) {
    // _edited = true;
    var result = f();
    save();
    return result;
  }

  /// saves the deck in its proper location
  save() async {
    await AppDao.saveDeck(_path, _deck);
    // _edited = false;
  }

  /// adds a card to the deck
  addCard(Card card) => _edit(() {
        _deck.cards.insert(0, card);
      });

  addCards(Iterable<Card> cards) => _edit(() {
        _deck.cards.insertAll(0, cards);
      });

  /// deletes a set of cards from the deck
  removeCards(Iterable<int> cardIndices) => _edit(() {
        var reversedCardIndices =
            (cardIndices.toSet().toList()..sort()).reversed;
        for (final cardIndex in reversedCardIndices) {
          _deck.cards.removeAt(cardIndex);
        }
      });

  /// picks a list of cards for review
  List<ReviewCard> pickCards(PickCardsAlgo algo,
      {int? numCards, FlipDirection? flipDirection}) {
    numCards ??= _deck.cards.length;
    if (numCards > _deck.cards.length) {
      throw Exception(
          "Can't pick $numCards cards from a deck with only ${_deck.cards.length} cards");
    }
    return algo.pick(numCards, cards(), flipDirection).toList();
  }

  /// processes the results of a review and incorporates them into the deck
  processReview(ProcessReviewAlgo algo, List<ReviewCard> reviewCards) =>
      _edit(() {
        var processedMetaCards = reviewCards.map(algo.process).toList();
        removeCards(processedMetaCards.map(
          (processedMetaCard) => processedMetaCard.index,
        ));
        addCards(processedMetaCards.map(
          (processedMetaCard) => processedMetaCard.card,
        ));
      });

  /// Json Serialization
  String getJson() => jsonEncode(_deck.toJson());
}
