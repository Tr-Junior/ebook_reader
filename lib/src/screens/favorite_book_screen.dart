import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:read_up/src/screens/book_list_screen.dart';
import 'package:read_up/src/utils/book_utils.dart';
import 'package:read_up/src/utils/error_handling.dart';
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
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Scaffold(
        body: BookListScreen(
          books: widget.books,
          favoriteBookIds: favoriteBookIds,
          toggleFavorite: widget.onFavoriteToggled,
          downloadAndOpenBook: _downloadAndOpenBook,
          isFavoriteScreen: true,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    _initSharedPreferences();
  }

  void _downloadAndOpenBook(Book book) async {
    try {
      await BookUtils.downloadAndOpenBook(context, book);
    } on AppException catch (e) {
      logger.e('Erro ao baixar/abrir o livro: $e');
    }
  }
}
