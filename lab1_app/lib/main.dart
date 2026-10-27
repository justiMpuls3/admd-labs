import 'package:flutter/material.dart';

import 'models/user.dart';
import 'models/bank_account.dart';
import 'models/library_item.dart';
import 'models/book.dart';
import 'models/magazine.dart';
import 'models/library.dart';
import 'screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Laborator 1 ADMD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  late final List<User> users;
  late final List<BankAccount> accounts;
  late final Library library;

  @override
  void initState() {
    super.initState();

    final user1 = User(name: 'Alex');
    final user2 = User(name: 'Maria', age: 22, email: 'maria@example.com');
    final user3 = User(name: 'Dan', email: 'dan@company.ro');
    users = [user1, user2, user3];

    final acc1 = BankAccount(
      holderName: 'Ion Popescu',
      bankBranch: 'Bucharest, Sector 1',
    );
    acc1.initializeAccount('RO49INGB0000999912345678');

    final acc2 = BankAccount(
      holderName: 'Elena Dumitru',
    );
    accounts = [acc1, acc2];

    library = Library();
    final book1 = Book(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      pageCount: 464,
      isbn: '978-0132350884',
    );
    final book2 = Book(title: 'Dart Apprentice');
    final mag1 = Magazine(
      title: 'IEEE Software',
      publisher: 'IEEE Computer Society',
      issueNumber: 142,
    );

    library.addItem(book1);
    library.addItem(book2);
    library.addItem(mag1);

    library.borrowItem(book1, user2);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TodoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ...users.map((u) => ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(u.name),
                        subtitle: Text(
                          'Age: ${u.getDisplayAge()} | Email: ${u.email ?? "Not provided"}',
                        ),
                      )),
                  const Divider(),
                  ...accounts.map((a) => ListTile(
                        leading: const Icon(Icons.account_balance),
                        title: Text('${a.holderName} (${a.displayAccountNumber})'),
                        subtitle: Text(
                          'Branch: ${a.bankBranch ?? "N/A"} | Balance: \$${a.balance.toStringAsFixed(2)}',
                        ),
                      )),
                  const Divider(),
                  ...library.items.map((item) {
                    final isBorrowed = item.borrower != null;
                    return ListTile(
                      leading: Icon(item is Book ? Icons.book : Icons.newspaper),
                      title: Text(item.title),
                      subtitle: Text(
                        'Author: ${item.author ?? "Unknown"} | '
                        'Status: ${isBorrowed ? "Borrowed by ${item.borrower?.name ?? 'Unknown'}" : "Available"}',
                      ),
                      trailing: Text(
                        isBorrowed ? 'Checked out' : 'In Library',
                        style: TextStyle(
                          color: isBorrowed ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}