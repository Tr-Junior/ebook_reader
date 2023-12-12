import 'package:ebook_reader/src/screens/favorite_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebook_reader/src/models/book.dart';
import 'package:ebook_reader/src/widgets/book_card.dart';
import 'package:ebook_reader/src/services/book_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Book> books = [];
  List<int> favoriteBookIds = [];
  late SharedPreferences prefs;
  late int crossAxisCount;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    loadBooks();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    crossAxisCount = _calculateCrossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Livros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _navigateToFavoriteBooks(),
          ),
        ],
      ),
      body: _buildBookList(),
    );
  }

  Widget _buildBookList() {
    return books.isNotEmpty
        ? GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0,
                childAspectRatio: 0.6),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                isFavorite: favoriteBookIds.contains(book.id),
                onFavoritePressed: () => _toggleFavorite(book),
                onReadPressed: (Book selectedBook) =>
                    _downloadAndOpenBook(selectedBook),
              );
            },
          )
        : const Center(
            child: Text('Nenhum livro disponível.'),
          );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3;
  }

  Future<void> loadBooks() async {
    try {
      final List<Book> fetchedBooks = await BookService().getBooks();
      setState(() {
        books = fetchedBooks;
      });
    } catch (error) {
      print('Erro ao carregar livros: $error');
    }
  }

  Future<void> _downloadAndOpenBook(Book book) async {
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

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadFavorites() async {
    final String favoritesString = prefs.getString('favoriteBookIds') ?? '[]';
    setState(() {
      favoriteBookIds = List<int>.from(json.decode(favoritesString));
    });
  }

  Future<void> _updateFavorites() async {
    await prefs.setString('favoriteBookIds', json.encode(favoriteBookIds));
  }

  void _toggleFavorite(Book book) {
    setState(() {
      favoriteBookIds.contains(book.id)
          ? favoriteBookIds.remove(book.id)
          : favoriteBookIds.add(book.id);
      _updateFavorites();
    });
  }

  void _navigateToFavoriteBooks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteBooksScreen(
          books:
              books.where((book) => favoriteBookIds.contains(book.id)).toList(),
          onFavoriteToggled: _toggleFavorite,
        ),
      ),
    );
  }
}
