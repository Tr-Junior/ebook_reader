import 'package:ebook_reader/src/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:ebook_reader/src/models/book.dart';
import 'package:ebook_reader/src/widgets/book_card.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteBooksScreen extends StatefulWidget {
  final List<Book> books;
  final Function(Book) onFavoriteToggled;

  const FavoriteBooksScreen({
    Key? key,
    required this.books,
    required this.onFavoriteToggled,
  }) : super(key: key);

  @override
  _FavoriteBooksScreenState createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros Favoritos'),
      ),
      body: _buildBookList(),
    );
  }

  Widget _buildBookList() {
    return widget.books.isNotEmpty
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 0.6,
            ),
            itemCount: widget.books.length,
            itemBuilder: (context, index) {
              final book = widget.books[index];
              return BookCard(
                book: book,
                isFavorite: true,
                onFavoritePressed: () {
                  widget.onFavoriteToggled(book);
                  setState(() {
                    widget.books.remove(book);
                  });
                  _updateFavorites();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Livro removido dos favoritos: ${book.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onReadPressed: (Book selectedBook) {
                  _downloadAndOpenBook(context, selectedBook);
                },
              );
            },
          )
        : const Center(
            child: Text('Nenhum livro favorito.'),
          );
  }

  Future<void> _downloadAndOpenBook(BuildContext context, Book book) async {
    try {
      final String downloadedBookPath =
          await BookService().downloadOrOpenBook(book);

      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "ABook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: true,
      );

      VocsyEpub.open(downloadedBookPath);
    } catch (error) {
      print('Erro ao abrir o livro: $error');
    }
  }

  Future<void> _updateFavorites() async {
    final List<int> favoriteBookIds =
        widget.books.map((book) => book.id).toList();
    await prefs.setStringList(
        'favoriteBookIds', favoriteBookIds.map((id) => id.toString()).toList());
  }
}
