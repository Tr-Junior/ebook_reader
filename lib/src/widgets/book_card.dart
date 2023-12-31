import 'package:flutter/material.dart';
import 'package:read_up/src/models/book.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final Function(Book) onReadPressed;

  const BookCard({
    Key? key,
    required this.book,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onReadPressed,
  }) : super(key: key);

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    ThemeData theme = Theme.of(context);
    Color textColor = theme.textTheme.bodyText1?.color ?? Colors.black;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(4),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await widget.onReadPressed(widget.book);

                      setState(() {
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Livro clicado: ${widget.book.title}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: isHorizontal ? 235 : 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.book.coverUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: isLoading
                              ? Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : null,
                        ),
                        if (!isLoading)
                          Container(
                            height: isHorizontal ? 235 : 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isHorizontal ? 12 : 12,
                        color: textColor, // Troquei para a cor do texto do tema
                      ),
                    ),
                    Text(
                      'by ${widget.book.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isHorizontal ? 10 : 12,
                        fontStyle: FontStyle.italic,
                        color: textColor, // Troquei para a cor do texto do tema
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: isHorizontal ? -12 : -11,
            right: isHorizontal ? -16 : -14,
            child: IconButton(
              icon: Icon(
                Icons.bookmark,
                color: widget.isFavorite
                    ? Colors.red
                    : theme
                        .iconTheme.color, // Troquei para a cor do ícone do tema
              ),
              iconSize: isHorizontal ? 45 : 35,
              onPressed: () {
                widget.onFavoritePressed();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.isFavorite
                          ? 'Livro removido dos favoritos: ${widget.book.title}'
                          : 'Livro adicionado aos favoritos: ${widget.book.title}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
