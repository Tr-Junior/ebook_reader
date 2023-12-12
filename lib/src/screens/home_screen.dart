import 'dart:convert';

import 'package:ebook_reader/src/models/book.dart';
import 'package:ebook_reader/src/screens/favorite_book_screen.dart';
import 'package:ebook_reader/src/services/book_service.dart';
import 'package:ebook_reader/src/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vocsy_epub_viewer/epub_viewer.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadBooks();
    getPrefs();
  }

  void getPrefs() {
    _prefs.then((SharedPreferences prefs) {
      String value = prefs.getString('books_id') ?? '';
      favoriteBookIds = utf8.encode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estante de Livros'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lista de Livros'),
            Tab(text: 'Favoritos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookList(),
          FavoriteBooksScreen(
            key: Key('FavoriteBooksScreen'),
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
      print('Erro ao abrir o livro  asdasd: $error');
    }
  }

  void _toggleFavorite(Book book) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      var tempOutput = new List<int>.from(favoriteBookIds);
      tempOutput.contains(book.id)
          ? tempOutput.remove(book.id)
          : tempOutput.add(book.id);
      favoriteBookIds = tempOutput;
      prefs.setString('books_id', utf8.decode(tempOutput));
    });
  }
}
