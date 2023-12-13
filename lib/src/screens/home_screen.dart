import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:read_up/src/models/book.dart';
import 'package:read_up/src/screens/favorite_book_screen.dart';
import 'package:read_up/src/services/book_service.dart';
import 'package:read_up/src/utils/book_utils.dart';
import 'package:read_up/src/utils/error_handling.dart';
import 'package:read_up/src/widgets/book_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<Book> books = [];
  List<int> favoriteBookIds = [];
  late TabController _tabController;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBooks();
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
      appBar: AppBar(
        title: const Text('Estante de livros'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lista de livros'),
            Tab(text: 'Favoritos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookList(),
          FavoriteBooksScreen(
            key: const Key('FavoriteBooksScreen'),
            books: books
                .where((book) => favoriteBookIds.contains(book.id))
                .toList(),
            onFavoriteToggled: _toggleFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return books.isNotEmpty
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 0.7,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                isFavorite: favoriteBookIds.contains(book.id),
                onFavoritePressed: () => _toggleFavorite(book),
                onReadPressed: _downloadAndOpenBook,
              );
            },
          )
        : const Center(
            child: Text('Nenhum livro disponível.'),
          );
  }

  Future<void> _loadBooks() async {
    try {
      final List<Book> fetchedBooks = await BookService().getBooks();
      setState(() {
        books = fetchedBooks;
      });
    } on AppException catch (e) {
      logger.e('Erro ao carregar livros: $e');
    }
  }

  void _downloadAndOpenBook(Book book) async {
    try {
      await BookUtils.downloadAndOpenBook(context, book);
    } on AppException catch (e) {
      logger.e('Erro ao baixar/abrir o livro: $e');
    }
  }

  void _toggleFavorite(Book book) async {
    await FavoriteBookManager.toggleFavorite(
      book: book,
      favoriteBookIds: favoriteBookIds,
      prefs: await _prefs,
      onFavoritesUpdated: (updatedFavorites) {
        setState(() {
          favoriteBookIds = updatedFavorites;
        });
      },
    );
  }
}
