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
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros Favoritos'),
      ),
      body: ListView.builder(
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final book = widget.books[index];
          return BookCard(
            book: book,
            isFavorite: true,
            onFavoritePressed: () {
              widget.onFavoriteToggled(book);
              // Remover o livro dos favoritos e atualizar a lista
              setState(() {
                widget.books.remove(book);
              });
              updateFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Livro removido dos favoritos: ${book.title}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onReadPressed: (Book selectedBook) {
              downloadAndOpenBook(context, selectedBook);
            },
          );
        },
      ),
    );
  }

  Future<void> downloadAndOpenBook(BuildContext context, Book book) async {
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

  Future<void> updateFavorites() async {
    final List<int> favoriteBookIds =
        widget.books.map((book) => book.id).toList();
    await prefs.setStringList(
        'favoriteBookIds', favoriteBookIds.map((id) => id.toString()).toList());
  }
}
