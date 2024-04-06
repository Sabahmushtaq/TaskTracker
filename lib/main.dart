import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasktracker/boxes/boxes.dart';
import 'package:tasktracker/models/notes_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  Directory document =
      await getApplicationDocumentsDirectory(); // Get app documents directory
  Hive.init(document.path); // Initialize Hive with the app documents path
  Hive.registerAdapter(
      NotesModelAdapter()); // Register Hive adapter for NotesModel
  await Hive.openBox<NotesModel>(
      "tasks"); // Open "tasks" box of type NotesModel
  runApp(const MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      debugShowCheckedModeBanner: false,
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 183, 125)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Task Tracker'),
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
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  //Box? taskBox;

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder<Box<NotesModel>>(
        valueListenable: Boxes.getdata().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<NotesModel>();
          return ListView.builder(
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                height: 100,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data[index].title.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            InkWell(
                                onTap: () {
                                  _editDialog(
                                      data[index],
                                      data[index].title.toString(),
                                      data[index].description.toString());
                                },
                                child: Icon(Icons.edit)),
                            InkWell(
                                onTap: () {
                                  delete(data[index]);
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ))
                          ],
                        ),
                        Text(data[index].description.toString())
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: box.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _editDialog(
      NotesModel notesModel, String Title, String Description) async {
    titleController.text = Title;
    descriptionController.text = Description;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("edit NOTES"),
            content: SingleChildScrollView(
              child: Column(children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "enter title"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "enter description"),
                ),
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    titleController.clear();
                    descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL")),
              TextButton(
                  onPressed: () async {
                    notesModel.title = titleController.text.toString();
                    notesModel.description =
                        descriptionController.text.toString();
                    notesModel.save();
                    titleController.clear();
                    descriptionController.clear();

                    Navigator.pop(context);
                  },
                  child: Text("Edit"))
            ],
          );
        });
  }

  Future<void> _showDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("ADD NOTES"),
            content: SingleChildScrollView(
              child: Column(children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "enter title"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "enter description"),
                ),
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    titleController.clear();
                    descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL")),
              TextButton(
                  onPressed: () {
                    final data = NotesModel(
                        title: titleController.text,
                        description: descriptionController.text);
                    final box = Boxes.getdata();
                    box.add(data);
                    data.save();
                    titleController.clear();
                    descriptionController.clear();

                    Navigator.pop(context);
                  },
                  child: Text("ADD"))
            ],
          );
        });
  }

  void delete(NotesModel notesModel) async {
    await notesModel.delete();
  }
}
