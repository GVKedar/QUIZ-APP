import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => QuizProvider(),
        child: const QuizApp(),
      ),
    );

// ================= MODEL =================
const int quizSize = 10; // questions per attempt
const int timeLimit = 15; // seconds per question
const String mixed = 'Mixed';

class Question {
  final String text;
  final List<String> options;
  final int answer;
  const Question(this.text, this.options, this.answer);

  // returns a copy with options in a random order
  Question shuffled() {
    final correct = options[answer];
    final o = List<String>.of(options)..shuffle();
    return Question(text, o, o.indexOf(correct));
  }
}

class Entry {
  final String name, cat;
  final int points, correct, total;
  Entry(this.name, this.cat, this.points, this.correct, this.total);
}

// ================= QUESTION DATABASE (100) =================
const List<Question> flutterQs = [
  Question('Which language is used to write Flutter apps?', ['Java', 'Kotlin', 'Dart', 'Swift'], 2),
  Question('Which widget is used for a scrollable list?', ['ListView', 'Stack', 'Row', 'Positioned'], 0),
  Question('Which method updates the UI in a StatefulWidget?', ['build()', 'setState()', 'dispose()', 'initState()'], 1),
  Question('Which widget layers children on top of each other?', ['Column', 'Row', 'Stack', 'Wrap'], 2),
  Question('Which class is used with push() and pop()?', ['Navigator', 'Scaffold', 'Theme', 'Provider'], 0),
  Question('Which widget arranges children horizontally?', ['Column', 'Row', 'Stack', 'Center'], 1),
  Question('Which widget gives a screen an app bar and body?', ['Scaffold', 'Container', 'Card', 'Padding'], 0),
  Question('Which keyword makes a compile-time constant in Dart?', ['final', 'const', 'static', 'var'], 1),
  Question('What is the entry point of a Dart program?', ['start()', 'run()', 'main()', 'init()'], 2),
  Question('Which widget shows a floating circular button?', ['FloatingActionButton', 'ElevatedButton', 'IconButton', 'TextButton'], 0),
  Question('Which file lists a Flutter project\'s dependencies?', ['main.dart', 'pubspec.yaml', 'build.gradle', 'package.json'], 1),
  Question('Which widget fills the remaining space in a Row or Column?', ['Padding', 'Expanded', 'Align', 'SizedBox'], 1),
  Question('Which class gives you the screen width and height?', ['MediaQuery', 'Theme', 'Navigator', 'Scaffold'], 0),
  Question('Which package provides ChangeNotifierProvider?', ['provider', 'http', 'sqflite', 'intl'], 0),
  Question('Which method tells listeners that data has changed?', ['setState()', 'notifyListeners()', 'markDirty()', 'refresh()'], 1),
  Question('Which widget is used to build a grid layout?', ['GridView', 'ListTile', 'Stack', 'Divider'], 0),
  Question('Which widget type cannot change its state?', ['StatefulWidget', 'StatelessWidget', 'State', 'AnimatedWidget'], 1),
  Question('Which command creates a new Flutter project?', ['flutter new', 'flutter create', 'flutter init', 'dart start'], 1),
  Question('Which key triggers hot reload in the flutter run terminal?', ['r', 'q', 'h', 'c'], 0),
  Question('Which widget adds empty space around its child?', ['Margin', 'Padding', 'Gap', 'Space'], 1),
  Question('Which widget displays a string on screen?', ['Label', 'Text', 'TextView', 'Title'], 1),
  Question('Which widget detects taps on its child?', ['GestureDetector', 'Scaffold', 'Divider', 'Spacer'], 0),
  Question('What does Navigator.pop() do?', ['Opens a new screen', 'Removes the current screen', 'Restarts the app', 'Closes the app'], 1),
  Question('Which widget implicitly animates changes to its properties?', ['AnimatedContainer', 'Scaffold', 'Stack', 'Divider'], 0),
  Question('Which method runs once when a State object is created?', ['build()', 'initState()', 'dispose()', 'setState()'], 1),
];

const List<Question> pythonQs = [
  Question('Which keyword defines a function in Python?', ['func', 'def', 'function', 'fun'], 1),
  Question('What is the output of len("abc")?', ['2', '3', '4', 'Error'], 1),
  Question('Which symbol starts a single-line comment?', ['//', '#', '/*', '--'], 1),
  Question('Which data type is immutable?', ['list', 'dict', 'tuple', 'set'], 2),
  Question('Which function reads user input?', ['scan()', 'read()', 'input()', 'get()'], 2),
  Question('Which brackets create a list?', ['()', '[]', '{}', '<>'], 1),
  Question('What is the value of 2 ** 3?', ['6', '8', '9', '5'], 1),
  Question('Which keyword is used to loop over items?', ['loop', 'foreach', 'for', 'iterate'], 2),
  Question('Which block handles exceptions in Python?', ['try-catch', 'try-except', 'catch-throw', 'do-handle'], 1),
  Question('Which function returns the type of a value?', ['typeof()', 'type()', 'kind()', 'class()'], 1),
  Question('What is the output of "Hi" * 2?', ['HiHi', 'Hi2', 'Error', 'Hi Hi'], 0),
  Question('Which method adds an item to the end of a list?', ['add()', 'push()', 'append()', 'insert_end()'], 2),
  Question('What is the file extension of a Python file?', ['.pt', '.pyt', '.py', '.python'], 2),
  Question('Which is a valid variable name?', ['2name', 'my_name', 'my-name', 'class'], 1),
  Question('Which library is popular for data frames?', ['pandas', 'pygame', 'flask', 'tkinter'], 0),
  Question('What is the result of 10 // 3?', ['3.33', '3', '4', '1'], 1),
  Question('Which keyword exits a loop early?', ['stop', 'exit', 'break', 'end'], 2),
  Question('Python code is mostly:', ['Compiled to machine code first', 'Interpreted', 'Written in assembly', 'Only markup'], 1),
  Question('A dictionary stores data as:', ['Key-value pairs', 'Only numbers', 'Rows and columns', 'Single values'], 0),
  Question('Which module generates random numbers?', ['math', 'random', 'sys', 'os'], 1),
  Question('What does range(3) produce?', ['1,2,3', '0,1,2', '0,1,2,3', '3 only'], 1),
  Question('Which keyword creates a class?', ['struct', 'class', 'object', 'define'], 1),
  Question('Which keyword adds a second condition after if?', ['else if', 'elif', 'elseif', 'elsif'], 1),
  Question('Which operator checks equality?', ['=', '==', '===', '!=='], 1),
  Question('What does list(set([1,1,2])) contain?', ['[1,1,2]', '[1,2]', '[2]', 'Error'], 1),
];

const List<Question> javaCQs = [
  Question('What does JVM stand for?', ['Java Variable Method', 'Java Virtual Machine', 'Joint Visual Model', 'Java Verified Module'], 1),
  Question('Which keyword creates an object in Java?', ['new', 'make', 'create', 'alloc'], 0),
  Question('Which is the entry point of a Java program?', ['main()', 'start()', 'run()', 'init()'], 0),
  Question('Which keyword is used for inheritance in Java?', ['implements', 'extends', 'inherits', 'super'], 1),
  Question('What is the default value of an int field in Java?', ['null', '0', '1', 'undefined'], 1),
  Question('Which of these is NOT a primitive type in Java?', ['int', 'boolean', 'String', 'char'], 2),
  Question('Which keyword prevents a method from being overridden?', ['static', 'final', 'abstract', 'void'], 1),
  Question('Which collection stores only unique elements?', ['ArrayList', 'HashSet', 'LinkedList', 'Vector'], 1),
  Question('Which keyword refers to the current object in Java?', ['self', 'this', 'me', 'current'], 1),
  Question('Java\'s \'write once, run anywhere\' is possible because of:', ['Pointers', 'Bytecode', 'Macros', 'Header files'], 1),
  Question('Which keyword handles exceptions in Java?', ['catch', 'handle', 'rescue', 'except'], 0),
  Question('How should you compare the content of two Strings in Java?', ['==', 'equals()', 'compare==', 'is()'], 1),
  Question('What is the size of int in Java?', ['2 bytes', '4 bytes', '8 bytes', 'Depends on OS'], 1),
  Question('Which header file is needed for printf() in C?', ['stdlib.h', 'stdio.h', 'string.h', 'math.h'], 1),
  Question('Which operator gives the address of a variable in C?', ['*', '&', '#', '@'], 1),
  Question('Which operator dereferences a pointer in C?', ['&', '*', '%', '^'], 1),
  Question('What does sizeof(char) return in C?', ['1', '2', '4', '8'], 0),
  Question('Which function allocates memory dynamically in C?', ['alloc()', 'malloc()', 'new()', 'create()'], 1),
  Question('Which loop always runs at least once?', ['for', 'while', 'do-while', 'foreach'], 2),
  Question('Which format specifier prints an int in C?', ['%f', '%d', '%c', '%s'], 1),
  Question('C is mainly which type of language?', ['Object-oriented only', 'Procedural', 'Markup', 'Scripting only'], 1),
  Question('What ends a statement in C?', ['.', ',', ';', ':'], 2),
  Question('Which function copies one string into another in C?', ['strcat()', 'strcpy()', 'strlen()', 'strcmp()'], 1),
  Question('In C, array indexing starts at:', ['0', '1', '-1', 'Depends'], 0),
  Question('Which keyword declares a constant in C?', ['final', 'const', 'let', 'readonly'], 1),
];

const List<Question> csQs = [
  Question('Which data structure follows LIFO?', ['Queue', 'Stack', 'Array', 'Tree'], 1),
  Question('Which OSI layer handles routing?', ['Transport', 'Data Link', 'Network', 'Session'], 2),
  Question('What does SQL stand for?', ['Structured Query Language', 'Simple Query Logic', 'Sequential Query Language', 'Strong Question Language'], 0),
  Question('What is the time complexity of binary search?', ['O(n)', 'O(log n)', 'O(n^2)', 'O(1)'], 1),
  Question('Which scheduling algorithm is non-preemptive?', ['Round Robin', 'SRTF', 'FCFS', 'Multilevel Feedback'], 2),
  Question('A primary key must be:', ['Repeated', 'Unique and not null', 'Always text', 'Optional'], 1),
  Question('Which SQL command retrieves data?', ['GET', 'SELECT', 'FETCH', 'PULL'], 1),
  Question('What is the purpose of normalization?', ['Increase redundancy', 'Reduce redundancy', 'Encrypt data', 'Speed up the CPU'], 1),
  Question('In ACID, what does \'A\' stand for?', ['Atomicity', 'Accuracy', 'Access', 'Authority'], 0),
  Question('Processes waiting on each other forever is called:', ['Starvation', 'Deadlock', 'Thrashing', 'Paging'], 1),
  Question('Which technique divides memory into fixed-size blocks?', ['Segmentation', 'Paging', 'Swapping', 'Spooling'], 1),
  Question('Which protocol loads web pages securely?', ['FTP', 'HTTPS', 'SMTP', 'Telnet'], 1),
  Question('How many bits are in an IPv4 address?', ['16', '32', '64', '128'], 1),
  Question('Which device connects different networks together?', ['Hub', 'Switch', 'Router', 'Repeater'], 2),
  Question('TCP is a:', ['Connectionless protocol', 'Connection-oriented protocol', 'Broadcast-only protocol', 'Hardware device'], 1),
  Question('What is the default port of HTTP?', ['21', '25', '80', '443'], 2),
  Question('A queue follows which order?', ['LIFO', 'FIFO', 'Random', 'Priority only'], 1),
  Question('Worst-case time complexity of bubble sort?', ['O(n)', 'O(n log n)', 'O(n^2)', 'O(log n)'], 2),
  Question('Which traversal uses a queue?', ['DFS', 'BFS', 'Inorder', 'Preorder'], 1),
  Question('Supervised learning uses:', ['Unlabeled data', 'Labeled data', 'No data', 'Only images'], 1),
  Question('Overfitting means the model:', ['Performs well on new data', 'Memorizes training data and fails on new data', 'Is too small to learn', 'Has no features'], 1),
  Question('Which algorithm is used for classification?', ['Linear Regression', 'Logistic Regression', 'K-Means', 'PCA'], 1),
  Question('Average lookup time in a hash table?', ['O(1)', 'O(n)', 'O(log n)', 'O(n^2)'], 0),
  Question('Threads of a process:', ['Have separate memory', 'Share the process memory', 'Are heavier than processes', 'Cannot run together'], 1),
  Question('Which scheduling algorithm uses a time quantum?', ['FCFS', 'SJF', 'Round Robin', 'Priority'], 2),
];



final Map<String, List<Question>> bank = {
  'Flutter & Dart': flutterQs,
  'Python': pythonQs,
  'Java & C': javaCQs,
  'CS Core': csQs,
};

List<Question> poolFor(String c) =>
    c == mixed ? bank.values.expand((l) => l).toList() : bank[c]!;

int get totalQuestions => bank.values.fold(0, (s, l) => s + l.length);

const Map<String, List<Color>> catColors = {
  'Flutter & Dart': [Color(0xFF00C6FF), Color(0xFF0072FF)],
  'Python': [Color(0xFF11998E), Color(0xFF38EF7D)],
  'Java & C': [Color(0xFFFF512F), Color(0xFFF09819)],
  'CS Core': [Color(0xFF8E2DE2), Color(0xFFE040FB)],
  mixed: [Color(0xFFEC008C), Color(0xFFFC6767)],
};
const Map<String, String> catEmoji = {
  'Flutter & Dart': '🐦',
  'Python': '🐍',
  'Java & C': '☕',
  'CS Core': '🧠',
  mixed: '🎲',
};
const Map<String, String> catDesc = {
  'Flutter & Dart': 'Widgets, state, navigation',
  'Python': 'Syntax, data types, libraries',
  'Java & C': 'OOP, pointers, memory',
  'CS Core': 'DBMS, OS, CN, DSA, ML',
  mixed: '10 random from all 100',
};
const List<Color> optColors = [
  Color(0xFFFF6B6B),
  Color(0xFF1DD1A1),
  Color(0xFFFFA502),
  Color(0xFF7C4DFF),
];
const List<Color> brandColors = [Color(0xFF7C4DFF), Color(0xFFE040FB), Color(0xFFFF6E7F)];

// ================= STATE (PROVIDER) =================
class QuizProvider extends ChangeNotifier {
  String name = '';
  String email = '';
  bool isDark = false;
  String category = '';
  List<Question> questions = [];
  List<int?> picked = [];
  int index = 0;
  int points = 0;
  int streak = 0;
  int bestStreak = 0;
  int lastGain = 0;
  final List<Entry> board = [];
  final Map<String, Set<int>> used = {}; // rotation: questions already shown

  void login(String n, String e) {
    name = n;
    email = e;
    notifyListeners();
  }

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  void start(String cat) {
    category = cat;
    final pool = poolFor(cat);
    final seen = used.putIfAbsent(cat, () => <int>{});
    var fresh = [
      for (int i = 0; i < pool.length; i++)
        if (!seen.contains(i)) i
    ];
    if (fresh.length < quizSize) {
      // everything has been seen: reset the rotation
      seen.clear();
      fresh = [for (int i = 0; i < pool.length; i++) i];
    }
    fresh.shuffle();
    final chosen = fresh.take(quizSize).toList();
    seen.addAll(chosen);
    questions = [for (final i in chosen) pool[i].shuffled()];
    picked = List<int?>.filled(questions.length, null);
    index = 0;
    points = 0;
    streak = 0;
    bestStreak = 0;
    lastGain = 0;
    notifyListeners();
  }

  void pick(int i, int timeLeft) {
    if (picked[index] != null) return;
    picked[index] = i;
    if (i == questions[index].answer) {
      streak++;
      if (streak > bestStreak) bestStreak = streak;
      lastGain = 10 + timeLeft; // 10 base + 1 per second left
      points += lastGain;
    } else {
      streak = 0;
      lastGain = 0;
    }
    notifyListeners();
  }

  bool get answered => picked[index] != null;
  bool get isLast => index == questions.length - 1;

  void next() {
    if (!isLast) {
      index++;
      notifyListeners();
    }
  }

  int get correct {
    int s = 0;
    for (int i = 0; i < questions.length; i++) {
      if (picked[i] == questions[i].answer) s++;
    }
    return s;
  }

  int get best {
    int b = 0;
    for (final e in board) {
      if (e.name == name && e.points > b) b = e.points;
    }
    return b;
  }

  void finish() {
    board.add(Entry(name, category, points, correct, questions.length));
    board.sort((a, b) => b.points.compareTo(a.points));
    notifyListeners();
  }
}

// ================= APP + THEME + ROUTES =================
ThemeData buildTheme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7C4DFF),
        brightness: b,
      ),
    );

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final pages = <String, WidgetBuilder>{
      '/': (_) => const LoginScreen(),
      '/home': (_) => const HomeScreen(),
      '/quiz': (_) => const QuizScreen(),
      '/result': (_) => const ResultScreen(),
      '/leaderboard': (_) => const LeaderboardScreen(),
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuizVerse - Online Quiz App',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: p.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (s) {
        final builder = pages[s.name] ?? pages['/']!;
        return PageRouteBuilder(
          settings: s,
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (c, a, b) => builder(c),
          transitionsBuilder: (c, a, b, child) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(a),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ================= CUSTOM REUSABLE WIDGETS =================
class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF12082B), Color(0xFF1F1147), Color(0xFF2B0F3A)]
              : const [Color(0xFFFFF0F6), Color(0xFFEAF2FF), Color(0xFFF3EBFF)],
        ),
      ),
      child: child,
    );
  }
}

PreferredSizeWidget gBar(String title,
    {List<Widget>? actions, bool back = true}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    centerTitle: true,
    automaticallyImplyLeading: back,
    actions: actions,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      decoration:
          const BoxDecoration(gradient: LinearGradient(colors: brandColors)),
    ),
  );
}

class Frame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const Frame({super.key, required this.child, this.maxWidth = 700});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final List<Color> colors;
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.colors = const [Color(0xFF7C4DFF), Color(0xFFE040FB)],
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    return IconButton(
      tooltip: 'Toggle theme',
      icon: Icon(p.isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => context.read<QuizProvider>().toggleTheme(),
    );
  }
}

class InfoPill extends StatelessWidget {
  final String text;
  final List<Color> colors;
  const InfoPill(this.text, this.colors, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CategoryCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cols = catColors[title]!;
    final count = title == mixed ? totalQuestions : bank[title]!.length;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: cols,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cols.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Text(catEmoji[title]!,
                      style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(catDesc[title]!,
                          style: const TextStyle(color: Colors.white70)),
                      Text('$count in database',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum OptState { idle, correct, wrong, dim }

class OptionTile extends StatelessWidget {
  final String label;
  final int idx;
  final OptState state;
  final VoidCallback onTap;
  const OptionTile({
    super.key,
    required this.label,
    required this.idx,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg = cs.surface;
    Color border = cs.outlineVariant;
    IconData? ic;
    if (state == OptState.correct) {
      bg = Colors.green.withOpacity(0.18);
      border = Colors.green;
      ic = Icons.check_circle;
    } else if (state == OptState.wrong) {
      bg = Colors.red.withOpacity(0.18);
      border = Colors.red;
      ic = Icons.cancel;
    } else if (state == OptState.dim) {
      bg = cs.surface.withOpacity(0.5);
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: optColors[idx % optColors.length],
                child: Text(String.fromCharCode(65 + idx),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
              if (ic != null) Icon(ic, color: border),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 1: LOGIN (FORM + VALIDATION) =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (_key.currentState!.validate()) {
      context.read<QuizProvider>().login(_name.text.trim(), _email.text.trim());
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gBar('Online Quiz App', back: false, actions: const [ThemeButton()]),
      body: GradientBg(
        child: Center(
          child: SingleChildScrollView(
            child: Frame(
              maxWidth: 440,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _key,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.elasticOut,
                          builder: (context, v, child) =>
                              Transform.scale(scale: v, child: child),
                          child: Container(
                            width: 90,
                            height: 90,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: brandColors),
                            ),
                            child: const Text('🧠', style: TextStyle(fontSize: 44)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ShaderMask(
                          shaderCallback: (r) =>
                              const LinearGradient(colors: brandColors)
                                  .createShader(r),
                          child: const Text('QuizVerse',
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                        ),
                        const Text('Test your skills. Beat the clock.'),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your name';
                            }
                            if (v.trim().length < 3) {
                              return 'At least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: _hide,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_hide
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() => _hide = !_hide),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter a password';
                            }
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        AppButton(
                          label: "Let's Go!",
                          icon: Icons.rocket_launch,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 2: HOME (GRIDVIEW + RESPONSIVE) =================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final cats = [...bank.keys, mixed];
    final w = MediaQuery.of(context).size.width;
    final cols = w >= 1000 ? 3 : (w >= 600 ? 2 : 1); // breakpoints
    return Scaffold(
      appBar: gBar(
        'Hi, ${p.name} 👋',
        back: false,
        actions: [
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          const ThemeButton(),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
          ),
        ],
      ),
      body: GradientBg(
        child: Frame(
          maxWidth: 1100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: brandColors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏆 Your best score: ${p.best} pts',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                        '📚 $totalQuestions questions in the database • $quizSize random ones every attempt',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Pick your arena',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: cats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisExtent: 112,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, i) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + i * 150),
                    builder: (context, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                          offset: Offset(0, 30 * (1 - v)), child: child),
                    ),
                    child: CategoryCard(
                      title: cats[i],
                      onTap: () {
                        context.read<QuizProvider>().start(cats[i]);
                        Navigator.pushNamed(context, '/quiz');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 3: QUIZ (TIMER + SCORE + ANIMATIONS) =================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _t;
  int _left = timeLimit;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _t?.cancel();
    _left = timeLimit;
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final p = context.read<QuizProvider>();
      if (p.answered) {
        _t?.cancel();
        return;
      }
      setState(() => _left--);
      if (_left <= 0) {
        _t?.cancel();
        p.pick(-1, 0); // time up = no answer
      }
    });
  }

  void _answer(int i) {
    final p = context.read<QuizProvider>();
    if (p.answered) return;
    _t?.cancel();
    p.pick(i, _left);
  }

  void _next(QuizProvider p) {
    if (p.isLast) {
      _t?.cancel();
      p.finish();
      Navigator.pushReplacementNamed(context, '/result');
    } else {
      p.next();
      _startTimer();
      setState(() {});
    }
  }

  OptState _stateFor(QuizProvider p, Question q, int i) {
    final pk = p.picked[p.index];
    if (pk == null) return OptState.idle;
    if (i == q.answer) return OptState.correct;
    if (i == pk) return OptState.wrong;
    return OptState.dim;
  }

  String _feedback(QuizProvider p, Question q) {
    final pk = p.picked[p.index];
    if (pk == q.answer) {
      return p.streak >= 3
          ? '+${p.lastGain} pts 🔥 ${p.streak} in a row!'
          : '+${p.lastGain} pts 🎉';
    }
    if (pk == -1) return "⏰ Time's up!";
    return '❌ Not quite!';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final q = p.questions[p.index];
    final cols = catColors[p.category] ?? catColors[mixed]!;
    final low = _left <= 5 && !p.answered;
    return Scaffold(
      appBar: gBar('${catEmoji[p.category]} ${p.category}'),
      body: GradientBg(
        child: SingleChildScrollView(
          child: Frame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    InfoPill('⭐ ${p.points} pts',
                        const [Color(0xFFFF9800), Color(0xFFFF5722)]),
                    InfoPill('🔥 ${p.streak}',
                        const [Color(0xFFEC008C), Color(0xFFFC6767)]),
                    InfoPill(
                      '⏱ $_left s',
                      low
                          ? const [Color(0xFFFF1744), Color(0xFFFF5252)]
                          : const [Color(0xFF2979FF), Color(0xFF00B0FF)],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Question ${p.index + 1} of ${p.questions.length}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween:
                      Tween(begin: 0, end: (p.index + 1) / p.questions.length),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 12,
                    color: cols.last,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    key: ValueKey(p.index),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: cols,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(q.text,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 14),
                      for (int i = 0; i < q.options.length; i++)
                        OptionTile(
                          label: q.options[i],
                          idx: i,
                          state: _stateFor(p, q, i),
                          onTap: () => _answer(i),
                        ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: p.answered
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 6),
                          child: Center(
                            child: Text(_feedback(p, q),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 10),
                Center(
                  child: AppButton(
                    label: p.isLast ? 'Finish' : 'Next',
                    icon: p.isLast ? Icons.flag : Icons.arrow_forward,
                    colors: cols,
                    onPressed: p.answered ? () => _next(p) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 4: RESULT (STACK + LISTVIEW) =================
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    final correct = p.correct;
    final total = p.questions.length;
    final pct = correct / total;
    final msg = pct >= 0.8
        ? 'Excellent! 🎉'
        : (pct >= 0.5 ? 'Good job! 👍' : 'Keep practicing! 💪');
    return Scaffold(
      appBar: gBar('Result', back: false, actions: const [ThemeButton()]),
      body: GradientBg(
        child: SingleChildScrollView(
          child: Frame(
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 1300),
                  builder: (context, v, _) => SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: v,
                            strokeWidth: 14,
                            color: const Color(0xFFE040FB),
                            backgroundColor: Colors.black12,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$correct/$total',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            Text('${(v * 100).round()}% correct'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(msg,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    InfoPill('⭐ ${p.points} pts',
                        const [Color(0xFFFF9800), Color(0xFFFF5722)]),
                    InfoPill('✅ $correct correct',
                        const [Color(0xFF11998E), Color(0xFF38EF7D)]),
                    InfoPill('🔥 best streak ${p.bestStreak}',
                        const [Color(0xFFEC008C), Color(0xFFFC6767)]),
                  ],
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Review',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: total,
                  itemBuilder: (context, i) {
                    final q = p.questions[i];
                    final pk = p.picked[i];
                    final ok = pk == q.answer;
                    final chosen =
                        (pk == null || pk < 0) ? 'Time up' : q.options[pk];
                    return Card(
                      child: ListTile(
                        leading: Icon(ok ? Icons.check_circle : Icons.cancel,
                            color: ok ? Colors.green : Colors.red),
                        title: Text(q.text),
                        subtitle: Text(ok
                            ? 'Correct: ${q.options[q.answer]}'
                            : 'Correct: ${q.options[q.answer]}\nYou chose: $chosen'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    AppButton(
                      label: 'Play Again',
                      icon: Icons.replay,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (r) => false),
                    ),
                    AppButton(
                      label: 'Leaderboard',
                      icon: Icons.leaderboard,
                      colors: const [Color(0xFFFF9800), Color(0xFFFF5722)],
                      onPressed: () =>
                          Navigator.pushNamed(context, '/leaderboard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 5: LEADERBOARD (LISTVIEW) =================
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<QuizProvider>();
    const medals = ['🥇', '🥈', '🥉'];
    return Scaffold(
      appBar: gBar('Leaderboard', actions: const [ThemeButton()]),
      body: GradientBg(
        child: Frame(
          child: p.board.isEmpty
              ? const Center(child: Text('No scores yet. Play a quiz first!'))
              : ListView.builder(
                  itemCount: p.board.length,
                  itemBuilder: (context, i) {
                    final e = p.board[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(i < 3 ? medals[i] : '${i + 1}',
                              style: TextStyle(fontSize: i < 3 ? 26 : 18)),
                        ),
                        title: Text(e.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text('${e.cat} • ${e.correct}/${e.total} correct'),
                        trailing: Text('${e.points} pts',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
