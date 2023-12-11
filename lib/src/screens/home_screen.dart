// home_screen.dart
import 'package:ebook_reader/src/models/book.dart';
import 'package:ebook_reader/src/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:ebook_reader/src/services/book_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Book> books = [];

  @override
  void initState() {
    super.initState();
    books = [];
    loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Livros'),
      ),
      body: books != null
          ? books.isNotEmpty
              ? ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(book: book);
                  },
                )
              : const Center(
                  child: Text('Nenhum livro disponível.'),
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> loadBooks() async {
    try {
      final List<Book> fetchedBooks = await BookService().getBooks();
      setState(() {
        books = fetchedBooks;
      });
    } catch (error) {
      // Tratar erro ao carregar livros
      print('Erro ao carregar livros: $error');
    }
  }
}
