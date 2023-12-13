import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:read_up/src/models/book.dart';
import 'package:read_up/src/screens/book_list_screen.dart';
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
  late BookService _bookService;

  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bookService = BookService(DioBookDownloader(), FileBookStorage());
    _loadBooks();
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    final SharedPreferences prefs = await _prefs;
    final String value = prefs.getString('books_id') ?? '';
    setState(() {
      favoriteBookIds = utf8.encode(value);
      _isDarkTheme = prefs.getBool('darkTheme') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Estante de Livros'),
          actions: [
            IconButton(
              icon:
                  Icon(_isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: _toggleTheme,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.library_books), text: 'Lista de Livros'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              child: BookListScreen(
                books: books,
                favoriteBookIds: favoriteBookIds,
                toggleFavorite: _toggleFavorite,
                downloadAndOpenBook: _downloadAndOpenBook,
                isFavoriteScreen: false,
              ),
            ),
            FavoriteBooksScreen(
              key: const Key('FavoriteBooksScreen'),
              books: books
                  .where((book) => favoriteBookIds.contains(book.id))
                  .toList(),
              onFavoriteToggled: _toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final List<Book> fetchedBooks = await _bookService.getBooks();
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

  void _toggleTheme() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      prefs.setBool('darkTheme', _isDarkTheme);
    });
  }
}
