part of flashcards_app.frontend.deck_dashboard_screen;

class _CardRow extends StatelessWidget {
  const _CardRow(this.metaCard, this.controller, {super.key});

  final MetaCard metaCard;
  final CardsTableController controller;

  /// function called when checkbox is clicked
  onChanged(bool? newValue) {
    if (newValue == true) {
      controller.addSelected({metaCard.id});
    } else {
      controller.removeSelected({metaCard.id});
    }
  }

  /// formats the card text for display in the text box
  static String formatCardText(String cardText) =>
      cardText.replaceAll("\n", "...\t");

  @override
  Widget build(BuildContext context) => Row(
        children: [
          // check box
          IntrinsicHeight(
            child: Checkbox(
              value: controller.selected.contains(metaCard.id),
              onChanged: onChanged,
            ),
          ),
          // view and button
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatCardText(metaCard.card.frontText),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: Util.borderRadius,
                              color: metaCard.card.front2backScore.color,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Text(
                                  metaCard.card.front2backScore
                                      .formatPercent(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatCardText(metaCard.card.backText),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: Util.borderRadius,
                              color: metaCard.card.back2frontScore.color,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Text(
                                  metaCard.card.back2frontScore
                                      .formatPercent(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}
