part of flashcards_app.frontend.deck_dashboard_screen;

class _CardsDashboard extends StatefulWidget {
  const _CardsDashboard(this.deckDao, this.controller,
      {super.key, required this.whileChange});

  final DeckDao deckDao;
  final CardsTableController controller;
  final Future Function(Future Function()) whileChange;

  @override
  State<_CardsDashboard> createState() => _CardsDashboardState();
}

class _CardsDashboardState extends State<_CardsDashboard> {
  // controllers
  final TextEditingController searchController = TextEditingController();

  // getters
  String get searchText => searchController.text.trim().toLowerCase();

  @override
  void initState() {
    widget.controller._observer = () => setState(() {});
    searchController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// filters the cards according to search parameters
  Iterable<MetaCard> filteredMetaCards() => widget.deckDao
      .cards()
      // filter with search bar
      .where((metaCard) =>
          metaCard.card.frontText.toLowerCase().contains(searchText) ||
          metaCard.card.backText.toLowerCase().contains(searchText));

  /// create a new card
  Future _newCard() => widget.whileChange(() async {
        if (mounted) {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewCardScreen(widget.deckDao),
            ),
          );
        }
      });

  /// deletes cards
  Future _deleteCards() => widget.whileChange(() async {
        var hasPermission = await Dialogs.permission(
          "Are you sure you want to delete these cards?",
        );
        if (hasPermission != true) {
          return;
        }
        widget.deckDao.removeCards(widget.controller.selected);
        widget.controller.clearSelected();
      });

  // card buttons
  late final Map<String, Function()> cardButtons = {
    "New Card": _newCard,
    "Delete Cards": _deleteCards,
  };

  @override
  Widget build(BuildContext context) => Row(
        children: [
          // side bar
          IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cardButtons.entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: OutlinedButton(
                            onPressed: entry.value,
                            child: Text(entry.key),
                          ),
                        ))
                    .toList()),
          ),
          const VerticalDivider(),
          // main area
          Expanded(
            child: Column(
              children: [
                // search parameters
                Row(
                  children: [
                    // search bar
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: searchController,
                          decoration: Util.searchDecoration,
                        ),
                      ),
                    ),
                  ],
                ),
                // cards table
                const Divider(),
                Expanded(
                  child: ListView(
                    children: filteredMetaCards()
                        .map((metaCard) => _CardRow(
                              metaCard,
                              widget.controller,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

/// a controller for the cards table
class CardsTableController {
  final Set<String> _selected = {};
  Function() _observer = () {};

  /// edit function calls the observer
  T _edit<T>(T Function() f) {
    T result = f();
    _observer();
    return result;
  }

  /// getters
  Set<String> get selected => Set.unmodifiable(_selected);

  /// selected modifiers
  addSelected(Iterable<String> newSelected) =>
      _edit(() => _selected.addAll(newSelected));
  removeSelected(Iterable<String> oldSelected) =>
      _edit(() => _selected.removeAll(oldSelected));
  clearSelected() => _edit(() => _selected.clear());
}
