import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box("MY_BOX");
  final txtctrl = TextEditingController();
  final searchController = TextEditingController();

  List todos = [];
  List delTodos = [];
  List filteredTodos = [];
  int _index = 0;
  bool showSearch = false;

  @override
  void initState() {
    todos = _myBox.get("TODO_LIST") ?? [];
    delTodos = _myBox.get("DELETED_TODO_LIST") ?? [];
    filteredTodos = List.from(todos);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: _index == 0
            ? [
                IconButton(
                  onPressed: showSearchBar,
                  icon: Icon(Icons.search),
                ),
              ]
            : null,
        toolbarHeight: 70,
        backgroundColor: Colors.blue.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: _index == 0 ? Text('Notes') : Text('Bin'),
        bottom: showSearch
            ? _index == 0
                ? AppBar(
                    toolbarHeight: 80,
                    backgroundColor: Colors.transparent,
                    title: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          controller: searchController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Search...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: _index == 0 ? searchTodos : null,
                        ),
                      ),
                    ),
                  )
                : null
            : null,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.blue.withAlpha(18),
        child: Container(
          margin: EdgeInsets.only(right: _index == 0 ? 60 : 0),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => setState(() => _index = 0),
                icon: const Icon(Icons.home),
                color: _index == 0 ? Colors.blue[900] : Colors.white,
              ),
              IconButton(
                onPressed: () => setState(() => _index = 1),
                icon: const Icon(Icons.delete),
                color: _index == 1 ? Colors.red : Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: _index == 0
          ? Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return ListTile(
                        title: Text(todo),
                        trailing: IconButton(
                            onPressed: () => deleteTodo(index),
                            icon: Icon(Icons.clear)),
                      );
                    },
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: delTodos.length,
                    itemBuilder: (context, index) {
                      final deltodo = delTodos[index];
                      return ListTile(
                        title: Text(deltodo),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => restore(index),
                                icon: Icon(Icons.restore)),
                            IconButton(
                                onPressed: () => deletePermanently(index),
                                icon: Icon(Icons.delete)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: const Color.fromARGB(137, 0, 21, 92),
              onPressed: openNewTodo,
              child: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void saveToDatabase() {
    _myBox.put("TODO_LIST", todos);
    _myBox.put("DELETED_TODO_LIST", delTodos);
  }

  void addTodo() {
    String todo = txtctrl.text.trim();
    if (todo.isNotEmpty) {
      setState(() {
        todos.add(todo);
        filteredTodos = List.from(todos);
      });
      saveToDatabase();
      txtctrl.clear();
    }
  }

  void deleteTodo(int index) {
    setState(() {
      delTodos.add(todos[index]);
      todos.removeAt(index);
      filteredTodos = List.from(todos);
    });
    saveToDatabase();
  }

  void restore(int index) {
    setState(() {
      todos.add(delTodos[index]);
      delTodos.removeAt(index);
      filteredTodos = List.from(todos);
    });
    saveToDatabase();
  }

  void deletePermanently(int index) {
    setState(() {
      delTodos.removeAt(index);
    });
    saveToDatabase();
  }

  void searchTodos(String query) {
    setState(() {
      filteredTodos = todos
          .where((todo) => todo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showSearchBar() {
    setState(() {
      showSearch = !showSearch;
    });
  }

  void openNewTodo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Note'),
          content: TextField(
            controller: txtctrl,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                txtctrl.clear();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addTodo();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
