import 'library_item.dart';

class Book extends LibraryItem {
  final int? pageCount;
  final String? isbn;

  Book({
    required super.title,
    super.author,
    super.publishDate,
    this.pageCount,
    this.isbn,
  });
}