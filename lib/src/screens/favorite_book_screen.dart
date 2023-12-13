import 'dart:convert';
import 'package:ReadUP/src/utils/book_utils.dart';
import 'package:ReadUP/src/utils/error_handling.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';

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
  List<int> favoriteBookIds = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    final SharedPreferences prefs = await _prefs;
    final String value = prefs.getString('books_id') ?? '';
    setState(() {
      favoriteBookIds = utf8.encode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBookList(),
    );
  }

  Widget _buildBookList() {
    final List<Book> favoriteBooksCopy = List.from(widget.books);

    return favoriteBooksCopy.isNotEmpty
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 0.7,
            ),
            itemCount: favoriteBooksCopy.length,
            itemBuilder: (context, index) {
              final book = favoriteBooksCopy[index];
              return BookCard(
                book: book,
                isFavorite: true,
                onFavoritePressed: () async {
                  widget.onFavoriteToggled(book);

                  await Future.delayed(Duration(milliseconds: 300));

                  setState(() {
                    widget.books.remove(book);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Livro removido dos favoritos: ${book.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onReadPressed: _downloadAndOpenBook,
              );
            },
          )
        : const Center(
            child: Text('Nenhum livro favorito.'),
          );
  }

  void _downloadAndOpenBook(Book book) async {
    try {
      await BookUtils.downloadAndOpenBook(context, book);
    } on AppException catch (e) {
      logger.e('Erro ao baixar/abrir o livro: $e');
    }
  }
}
