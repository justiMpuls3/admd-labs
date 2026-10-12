import 'library_item.dart';
import 'user.dart';

class Library {
  final List<LibraryItem> items = [];

  void addItem(LibraryItem? item) {
    if (item != null && item.title.trim().isNotEmpty) {
      items.add(item);
    }
  }

  List<LibraryItem> searchByTitle(String? query) {
    if (query == null || query.trim().isEmpty) return [];
    return items
        .where((i) => i.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<LibraryItem> getItemsByAuthor(String? author) {
    if (author == null || author.trim().isEmpty) return [];
    return items
        .where((i) =>
            i.author != null &&
            i.author!.toLowerCase().contains(author.toLowerCase()))
        .toList();
  }

  bool borrowItem(LibraryItem item, User user, {int days = 14}) {
    if (item.borrower != null) {
      return false; // Este deja împrumutat
    }
    item.borrower = user;
    item.dueDate = DateTime.now().add(Duration(days: days));
    return true;
  }

  void returnItem(LibraryItem item) {
    item.borrower = null;
    item.dueDate = null;
  }
}