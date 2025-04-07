import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MuseumObjectAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SubcategoryAdapter());
  Hive.registerAdapter(ExhibitGroupingAdapter());
  Hive.registerAdapter(AcquisitionAdapter());
  Hive.registerAdapter(LocationAdapter());

  // Open boxes
  await Hive.openBox<MuseumObject>('objects');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Subcategory>('subcategories');
  await Hive.openBox<ExhibitGrouping>('exhibitGroupings');
  await Hive.openBox<Acquisition>('acquisitions');
  await Hive.openBox<Location>('locations');

  // Initialize demo data
  await _initializeDemoData();

  runApp(const MuseumApp());
}

Future<void> _initializeDemoData() async {
  final categoriesBox = Hive.box<Category>('categories');
  if (categoriesBox.isEmpty) {
    await categoriesBox.addAll([
      Category(name: 'Hardware'),
      Category(name: 'Publications'),
    ]);
  }

  final subcategoriesBox = Hive.box<Subcategory>('subcategories');
  if (subcategoriesBox.isEmpty) {
    final hardwareCategory = categoriesBox.values.firstWhere((c) => c.name == 'Hardware');
    final publicationsCategory = categoriesBox.values.firstWhere((c) => c.name == 'Publications');

    await subcategoriesBox.addAll([
      Subcategory(categoryId: hardwareCategory.key!, name: 'Computer'),
      Subcategory(categoryId: hardwareCategory.key!, name: 'Peripherals'),
      Subcategory(categoryId: hardwareCategory.key!, name: 'Components'),
      Subcategory(categoryId: hardwareCategory.key!, name: 'Mass Storage'),
      Subcategory(categoryId: publicationsCategory.key!, name: 'Books'),
      Subcategory(categoryId: publicationsCategory.key!, name: 'Magazines'),
    ]);
  }

  final locationsBox = Hive.box<Location>('locations');
  if (locationsBox.isEmpty) {
    await locationsBox.addAll([
      Location(name: 'Storage Room A', description: 'Main storage area'),
      Location(name: 'Display Case 1', description: 'Entrance display'),
      Location(name: 'Loaned Out', description: 'Currently on loan'),
    ]);
  }

  final objectsBox = Hive.box<MuseumObject>('objects');
  if (objectsBox.isEmpty) {
    final computerSubcategory = subcategoriesBox.values.firstWhere((s) => s.name == 'Computer');
    final peripheralSubcategory = subcategoriesBox.values.firstWhere((s) => s.name == 'Peripherals');
    final booksSubcategory = subcategoriesBox.values.firstWhere((s) => s.name == 'Books');
    final magazinesSubcategory = subcategoriesBox.values.firstWhere((s) => s.name == 'Magazines');
    final storageLocation = locationsBox.values.firstWhere((l) => l.name == 'Storage Room A');
    final displayLocation = locationsBox.values.firstWhere((l) => l.name == 'Display Case 1');

    final demoObjects = [
      MuseumObject(
        uniqueId: 'OBJ-001',
        name: 'Apple Macintosh 128K',
        categoryId: categoriesBox.values.firstWhere((c) => c.name == 'Hardware').key!,
        subcategoryId: computerSubcategory.key!,
        description: 'The original Macintosh computer released in 1984',
        manufacturerAuthor: 'Apple Inc.',
        modelSerialIsbn: 'M0001',
        dateOfProductionPublication: DateTime(1984, 1, 24),
        condition: 'Good',
        locationId: displayLocation.key!,
        notes: 'Fully functional, includes original keyboard and mouse',
        imagePaths: ['assets/images/macintosh.jpg'],
      ),
      MuseumObject(
        uniqueId: 'OBJ-002',
        name: 'IBM Model M Keyboard',
        categoryId: categoriesBox.values.firstWhere((c) => c.name == 'Hardware').key!,
        subcategoryId: peripheralSubcategory.key!,
        description: 'Legendary mechanical keyboard known for its durability',
        manufacturerAuthor: 'IBM',
        modelSerialIsbn: '1391401',
        dateOfProductionPublication: DateTime(1985),
        condition: 'Excellent',
        locationId: storageLocation.key!,
        notes: 'Needs PS/2 to USB adapter for modern computers',
        imagePaths: ['assets/images/ibm_keyboard.jpg'],
      ),
      MuseumObject(
        uniqueId: 'OBJ-003',
        name: 'The Art of Computer Programming',
        categoryId: categoriesBox.values.firstWhere((c) => c.name == 'Publications').key!,
        subcategoryId: booksSubcategory.key!,
        description: 'Comprehensive computer programming reference by Donald Knuth',
        manufacturerAuthor: 'Donald Knuth',
        modelSerialIsbn: '978-0201896831',
        dateOfProductionPublication: DateTime(1968),
        condition: 'Fair',
        locationId: storageLocation.key!,
        notes: 'First edition, volume 1',
        imagePaths: ['assets/images/knuth_book.jpg'],
      ),
      MuseumObject(
        uniqueId: 'OBJ-004',
        name: 'Byte Magazine - January 1984',
        categoryId: categoriesBox.values.firstWhere((c) => c.name == 'Publications').key!,
        subcategoryId: magazinesSubcategory.key!,
        description: 'Issue featuring the Apple Macintosh',
        manufacturerAuthor: 'Byte Publications',
        modelSerialIsbn: '0360-5280-84-01',
        dateOfProductionPublication: DateTime(1984, 1),
        condition: 'Good',
        locationId: displayLocation.key!,
        notes: 'Cover slightly worn',
        imagePaths: ['assets/images/byte_magazine.jpg'],
      ),
    ];

    final objectKeys = await objectsBox.addAll(demoObjects);

    // Add demo acquisitions
    final acquisitionsBox = Hive.box<Acquisition>('acquisitions');
    if (acquisitionsBox.isEmpty) {
      final demoAcquisitions = [
        Acquisition(
          acquisitionDate: DateTime(2020, 5, 15),
          source: 'Private Donation',
          lotDescription: 'Vintage Apple collection',
          objectIds: [objectKeys.elementAt(0)],
          notes: 'Donated by John Smith',
          conditionUponArrival: 'Good',
        ),
        Acquisition(
          acquisitionDate: DateTime(2021, 2, 10),
          source: 'Estate Sale',
          lotDescription: 'Various computing items',
          objectIds: [objectKeys.elementAt(1)],
          notes: 'Purchased at auction',
          appraisalInformation: 'Appraised at \$200',
        ),
        Acquisition(
          acquisitionDate: DateTime(2022, 8, 3),
          source: 'Library Donation',
          lotDescription: 'Technical books and magazines',
          objectIds: [objectKeys.elementAt(2), objectKeys.elementAt(3)],
          notes: 'Donated by City Library',
        ),
      ];

      final acquisitionKeys = await acquisitionsBox.addAll(demoAcquisitions);

      // Update objects with acquisition references
      for (int i = 0; i < demoObjects.length; i++) {
        if (i == 0) demoObjects[i].acquisitionId = acquisitionKeys.elementAt(0);
        if (i == 1) demoObjects[i].acquisitionId = acquisitionKeys.elementAt(1);
        if (i >= 2) demoObjects[i].acquisitionId = acquisitionKeys.elementAt(2);
        await objectsBox.put(objectKeys.elementAt(i), demoObjects[i]);
      }
    }    // Add demo exhibit groupings
    final groupingsBox = Hive.box<ExhibitGrouping>('exhibitGroupings');
    if (groupingsBox.isEmpty) {
      final demoGroupings = [
        ExhibitGrouping(
          name: 'The Personal Computer Revolution',
          description: 'Exhibit showcasing the evolution of personal computers',
          objectIds: [objectKeys.elementAt(0), objectKeys.elementAt(1)],
        ),
        ExhibitGrouping(
          name: 'Historical Publications',
          description: 'Important books and magazines in computing history',
          objectIds: [objectKeys.elementAt(2), objectKeys.elementAt(3)],
        ),
      ];

      final groupingKeys = await groupingsBox.addAll(demoGroupings);

      // Update objects with grouping references
      for (int i = 0; i < demoObjects.length; i++) {
        demoObjects[i].exhibitGroupingIds = [i < 2 ? groupingKeys.elementAt(0) : groupingKeys.elementAt(1)];
        await objectsBox.put(objectKeys.elementAt(i), demoObjects[i]);
      }
    }
  }
}

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museum Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ObjectsScreen(),
    const ExhibitGroupingsScreen(),
    const AcquisitionsScreen(),
    const CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Museum Collection Management')),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Objects'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Exhibits'),
          BottomNavigationBarItem(icon: Icon(Icons.input), label: 'Acquisitions'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
        ],
      ),
    );
  }
}

// Data Models
@HiveType(typeId: 0)
class MuseumObject extends HiveObject {
  @HiveField(0) String uniqueId;
  @HiveField(1) String name;
  @HiveField(2) int categoryId;
  @HiveField(3) int subcategoryId;
  @HiveField(4) String description;
  @HiveField(5) String manufacturerAuthor;
  @HiveField(6) String modelSerialIsbn;
  @HiveField(7) DateTime dateOfProductionPublication;
  @HiveField(8) String condition;
  @HiveField(9) int? locationId;
  @HiveField(10) String notes;
  @HiveField(11) List<String> imagePaths;
  @HiveField(12) int? acquisitionId;
  @HiveField(13) List<int> exhibitGroupingIds;

  MuseumObject({
    required this.uniqueId,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    required this.description,
    required this.manufacturerAuthor,
    required this.modelSerialIsbn,
    required this.dateOfProductionPublication,
    required this.condition,
    this.locationId,
    this.notes = '',
    this.imagePaths = const [],
    this.acquisitionId,
    this.exhibitGroupingIds = const [],
  });
}

class MuseumObjectAdapter extends TypeAdapter<MuseumObject> {
  @override
  final int typeId = 0;

  @override
  MuseumObject read(BinaryReader reader) {
    return MuseumObject(
      uniqueId: reader.read(),
      name: reader.read(),
      categoryId: reader.read(),
      subcategoryId: reader.read(),
      description: reader.read(),
      manufacturerAuthor: reader.read(),
      modelSerialIsbn: reader.read(),
      dateOfProductionPublication: reader.read(),
      condition: reader.read(),
      locationId: reader.read(),
      notes: reader.read(),
      imagePaths: List<String>.from(reader.read()),
      acquisitionId: reader.read(),
      exhibitGroupingIds: List<int>.from(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, MuseumObject obj) {
    writer.write(obj.uniqueId);
    writer.write(obj.name);
    writer.write(obj.categoryId);
    writer.write(obj.subcategoryId);
    writer.write(obj.description);
    writer.write(obj.manufacturerAuthor);
    writer.write(obj.modelSerialIsbn);
    writer.write(obj.dateOfProductionPublication);
    writer.write(obj.condition);
    writer.write(obj.locationId);
    writer.write(obj.notes);
    writer.write(obj.imagePaths);
    writer.write(obj.acquisitionId);
    writer.write(obj.exhibitGroupingIds);
  }
}

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0) String name;
  Category({required this.name});
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;
  @override
  Category read(BinaryReader reader) => Category(name: reader.read());
  @override
  void write(BinaryWriter writer, Category obj) => writer.write(obj.name);
}

@HiveType(typeId: 2)
class Subcategory extends HiveObject {
  @HiveField(0) int categoryId;
  @HiveField(1) String name;
  Subcategory({required this.categoryId, required this.name});
}

class SubcategoryAdapter extends TypeAdapter<Subcategory> {
  @override
  final int typeId = 2;
  @override
  Subcategory read(BinaryReader reader) => Subcategory(
    categoryId: reader.read(),
    name: reader.read(),
  );
  @override
  void write(BinaryWriter writer, Subcategory obj) {
    writer.write(obj.categoryId);
    writer.write(obj.name);
  }
}

@HiveType(typeId: 3)
class ExhibitGrouping extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String description;
  @HiveField(2) List<int> objectIds;

  ExhibitGrouping({
    required this.name,
    required this.description,
    this.objectIds = const [],
  });
}

class ExhibitGroupingAdapter extends TypeAdapter<ExhibitGrouping> {
  @override
  final int typeId = 3;
  @override
  ExhibitGrouping read(BinaryReader reader) => ExhibitGrouping(
    name: reader.read(),
    description: reader.read(),
    objectIds: List<int>.from(reader.read()),
  );
  @override
  void write(BinaryWriter writer, ExhibitGrouping obj) {
    writer.write(obj.name);
    writer.write(obj.description);
    writer.write(obj.objectIds);
  }
}

@HiveType(typeId: 4)
class Acquisition extends HiveObject {
  @HiveField(0) DateTime acquisitionDate;
  @HiveField(1) String source;
  @HiveField(2) String lotDescription;
  @HiveField(3) List<int> objectIds;
  @HiveField(4) String notes;
  @HiveField(5) String? conditionUponArrival;
  @HiveField(6) String? appraisalInformation;

  Acquisition({
    required this.acquisitionDate,
    required this.source,
    required this.lotDescription,
    this.objectIds = const [],
    this.notes = '',
    this.conditionUponArrival,
    this.appraisalInformation,
  });
}

class AcquisitionAdapter extends TypeAdapter<Acquisition> {
  @override
  final int typeId = 4;
  @override
  Acquisition read(BinaryReader reader) => Acquisition(
    acquisitionDate: reader.read(),
    source: reader.read(),
    lotDescription: reader.read(),
    objectIds: List<int>.from(reader.read()),
    notes: reader.read(),
    conditionUponArrival: reader.read(),
    appraisalInformation: reader.read(),
  );
  @override
  void write(BinaryWriter writer, Acquisition obj) {
    writer.write(obj.acquisitionDate);
    writer.write(obj.source);
    writer.write(obj.lotDescription);
    writer.write(obj.objectIds);
    writer.write(obj.notes);
    writer.write(obj.conditionUponArrival);
    writer.write(obj.appraisalInformation);
  }
}

@HiveType(typeId: 5)
class Location extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String description;
  Location({required this.name, this.description = ''});
}

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 5;
  @override
  Location read(BinaryReader reader) => Location(
    name: reader.read(),
    description: reader.read(),
  );
  @override
  void write(BinaryWriter writer, Location obj) {
    writer.write(obj.name);
    writer.write(obj.description);
  }
}

// Screens
class ObjectsScreen extends StatefulWidget {
  const ObjectsScreen({super.key});

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search objects',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<Box<Category>>(
                  valueListenable: Hive.box<Category>('categories').listenable(),
                  builder: (context, box, _) {
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Categories')),
                        ...box.values.map((category) => DropdownMenuItem(
                          value: category.key as int,
                          child: Text(category.name),
                        )).toList(),
                      ],
                      onChanged: (value) => setState(() {
                        _selectedCategoryId = value;
                        _selectedSubcategoryId = null;
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder<Box<Subcategory>>(
                  valueListenable: Hive.box<Subcategory>('subcategories').listenable(),
                  builder: (context, box, _) {
                    final subcategories = _selectedCategoryId != null
                        ? box.values.where((sub) => sub.categoryId == _selectedCategoryId).toList()
                        : box.values.toList();
                    return DropdownButtonFormField<int>(
                      value: _selectedSubcategoryId,
                      decoration: const InputDecoration(labelText: 'Subcategory'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Subcategories')),
                        ...subcategories.map((subcategory) => DropdownMenuItem(
                          value: subcategory.key as int,
                          child: Text(subcategory.name),
                        )).toList(),
                      ],
                      onChanged: (value) => setState(() => _selectedSubcategoryId = value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<Box<MuseumObject>>(
            valueListenable: Hive.box<MuseumObject>('objects').listenable(),
            builder: (context, box, _) {
              var objects = box.values.toList();

              if (_searchQuery.isNotEmpty) {
                objects = objects.where((obj) {
                  return obj.name.toLowerCase().contains(_searchQuery) ||
                      obj.description.toLowerCase().contains(_searchQuery) ||
                      obj.manufacturerAuthor.toLowerCase().contains(_searchQuery) ||
                      obj.modelSerialIsbn.toLowerCase().contains(_searchQuery) ||
                      obj.notes.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              if (_selectedCategoryId != null) {
                objects = objects.where((obj) => obj.categoryId == _selectedCategoryId).toList();
              }

              if (_selectedSubcategoryId != null) {
                objects = objects.where((obj) => obj.subcategoryId == _selectedSubcategoryId).toList();
              }

              return ListView.builder(
                itemCount: objects.length,
                itemBuilder: (context, index) {
                  final obj = objects[index];
                  final category = Hive.box<Category>('categories').get(obj.categoryId);
                  final subcategory = Hive.box<Subcategory>('subcategories').get(obj.subcategoryId);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(obj.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${category?.name} > ${subcategory?.name}'),
                          Text(obj.manufacturerAuthor),
                          if (obj.modelSerialIsbn.isNotEmpty) Text(obj.modelSerialIsbn),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ObjectDetailScreen(objectKey: obj.key as int),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditObjectScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }}

class ObjectDetailScreen extends StatelessWidget {
  final int objectKey;

  const ObjectDetailScreen({super.key, required this.objectKey});

  @override
  Widget build(BuildContext context) {
    final object = Hive.box<MuseumObject>('objects').get(objectKey);
    if (object == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Object not found')),
        body: const Center(child: Text('The requested object could not be found.')),
      );
    }

    final category = Hive.box<Category>('categories').get(object.categoryId);
    final subcategory = Hive.box<Subcategory>('subcategories').get(object.subcategoryId);
    final location = object.locationId != null
        ? Hive.box<Location>('locations').get(object.locationId)
        : null;
    final acquisition = object.acquisitionId != null
        ? Hive.box<Acquisition>('acquisitions').get(object.acquisitionId)
        : null;

    final exhibitGroupings = Hive.box<ExhibitGrouping>('exhibitGroupings')
        .values
        .where((eg) => object.exhibitGroupingIds.contains(eg.key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(object.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditObjectScreen(objectKey: objectKey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Object'),
                  content: const Text('Are you sure you want to delete this object?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // Remove from exhibit groupings
                for (final eg in exhibitGroupings) {
                  eg.objectIds.remove(objectKey);
                  eg.save();
                }

                // Remove from acquisition
                if (acquisition != null) {
                  acquisition.objectIds.remove(objectKey);
                  acquisition.save();
                }

                object.delete();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (object.imagePaths.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: object.imagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        object.imagePaths[index],
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
            Text('Unique ID: ${object.uniqueId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Category: ${category?.name ?? 'Unknown'} > ${subcategory?.name ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Manufacturer/Author: ${object.manufacturerAuthor}'),
            const SizedBox(height: 8),
            Text('Model/Serial/ISBN: ${object.modelSerialIsbn}'),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(object.dateOfProductionPublication)}'),
            const SizedBox(height: 8),
            Text('Condition: ${object.condition}'),
            const SizedBox(height: 8),
            if (location != null) Text('Location: ${location.name}'),
            const SizedBox(height: 16),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(object.description),
            const SizedBox(height: 16),
            if (object.notes.isNotEmpty) ...[
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(object.notes),
              const SizedBox(height: 16),
            ],
            if (acquisition != null) ...[
              const Text('Acquisition:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Date: ${DateFormat('yyyy-MM-dd').format(acquisition.acquisitionDate)}'),
              Text('Source: ${acquisition.source}'),
              Text('Lot Description: ${acquisition.lotDescription}'),
              if (acquisition.conditionUponArrival != null)
                Text('Condition Upon Arrival: ${acquisition.conditionUponArrival}'),
              if (acquisition.appraisalInformation != null)
                Text('Appraisal Information: ${acquisition.appraisalInformation}'),
              if (acquisition.notes.isNotEmpty) Text('Notes: ${acquisition.notes}'),
              const SizedBox(height: 16),
            ],
            if (exhibitGroupings.isNotEmpty) ...[
              const Text('Exhibit Groupings:', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exhibitGroupings.map((eg) {
                  return ListTile(
                    title: Text(eg.name),
                    subtitle: Text(eg.description),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExhibitGroupingDetailScreen(exhibitGroupingKey: eg.key!),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AddEditObjectScreen extends StatefulWidget {
  final int? objectKey;

  const AddEditObjectScreen({super.key, this.objectKey});

  @override
  State<AddEditObjectScreen> createState() => _AddEditObjectScreenState();
}

class _AddEditObjectScreenState extends State<AddEditObjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late MuseumObject _object;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  DateTime _selectedDate = DateTime.now();
  String _selectedCondition = 'Good';
  int? _selectedLocationId;
  int? _selectedAcquisitionId;

  final List<String> _imagePaths = [];
  final List<int> _selectedExhibitGroupingIds = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.objectKey != null;

    if (_isEditing) {
      final object = Hive.box<MuseumObject>('objects').get(widget.objectKey!)!;
      _object = object;

      _nameController.text = object.name;
      _descriptionController.text = object.description;
      _manufacturerController.text = object.manufacturerAuthor;
      _modelController.text = object.modelSerialIsbn;
      _notesController.text = object.notes;

      _selectedCategoryId = object.categoryId;
      _selectedSubcategoryId = object.subcategoryId;
      _selectedDate = object.dateOfProductionPublication;
      _selectedCondition = object.condition;
      _selectedLocationId = object.locationId;
      _selectedAcquisitionId = object.acquisitionId;

      _imagePaths.addAll(object.imagePaths);
      _selectedExhibitGroupingIds.addAll(object.exhibitGroupingIds);
    } else {
      _object = MuseumObject(
        uniqueId: 'OBJ-${DateTime.now().millisecondsSinceEpoch}',
        name: '',
        categoryId: -1,
        subcategoryId: -1,
        description: '',
        manufacturerAuthor: '',
        modelSerialIsbn: '',
        dateOfProductionPublication: DateTime.now(),
        condition: 'Good',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Object' : 'Add New Object'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name/Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Box<Category>>(
                valueListenable: Hive.box<Category>('categories').listenable(),
                builder: (context, box, _) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Select a category')),
                      ...box.values.map((category) => DropdownMenuItem(
                        value: category.key as int?,
                        child: Text(category.name),
                      )).toList(),
                    ],
                    validator: (value) => value == null ? 'Please select a category' : null,
                    onChanged: (value) => setState(() {
                      _selectedCategoryId = value;
                      _selectedSubcategoryId = null;
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_selectedCategoryId != null)
                ValueListenableBuilder<Box<Subcategory>>(
                  valueListenable: Hive.box<Subcategory>('subcategories').listenable(),
                  builder: (context, box, _) {
                    final subcategories = box.values
                        .where((sub) => sub.categoryId == _selectedCategoryId)
                        .toList();
                    return DropdownButtonFormField<int>(
                      value: _selectedSubcategoryId,
                      decoration: const InputDecoration(labelText: 'Subcategory'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select a subcategory')),
                        ...subcategories.map((subcategory) => DropdownMenuItem(
                          value: subcategory.key as int?,
                          child: Text(subcategory.name),
                        )).toList(),
                      ],
                      validator: (value) => value == null ? 'Please select a subcategory' : null,
                      onChanged: (value) => setState(() => _selectedSubcategoryId = value),
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Manufacturer/Author'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a manufacturer/author' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model/Serial/ISBN'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Date: '),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        setState(() => _selectedDate = selectedDate);
                      }
                    },
                    child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: const [
                  DropdownMenuItem(value: 'Excellent', child: Text('Excellent')),
                  DropdownMenuItem(value: 'Good', child: Text('Good')),
                  DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                  DropdownMenuItem(value: 'Poor', child: Text('Poor')),
                  DropdownMenuItem(value: 'Needs Restoration', child: Text('Needs Restoration')),
                ],
                onChanged: (value) => setState(() => _selectedCondition = value!),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Box<Location>>(
                valueListenable: Hive.box<Location>('locations').listenable(),
                builder: (context, box, _) {
                  return DropdownButtonFormField<int>(
                    value: _selectedLocationId,
                    decoration: const InputDecoration(labelText: 'Location (optional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No location selected')),
                      ...box.values.map((location) => DropdownMenuItem(
                        value: location.key as int?,
                        child: Text(location.name),
                      )).toList(),
                    ],
                    onChanged: (value) => setState(() => _selectedLocationId = value),
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Box<Acquisition>>(
                valueListenable: Hive.box<Acquisition>('acquisitions').listenable(),
                builder: (context, box, _) {
                  return DropdownButtonFormField<int>(
                    value: _selectedAcquisitionId,
                    decoration: const InputDecoration(labelText: 'Acquisition (optional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No acquisition selected')),
                      ...box.values.map((acquisition) => DropdownMenuItem(
                        value: acquisition.key as int?,
                        child: Text('${acquisition.source} - ${DateFormat('yyyy-MM-dd').format(acquisition.acquisitionDate)}'),
                      )).toList(),
                    ],
                    onChanged: (value) => setState(() => _selectedAcquisitionId = value),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Exhibit Groupings:', style: TextStyle(fontWeight: FontWeight.bold)),
              ValueListenableBuilder<Box<ExhibitGrouping>>(
                valueListenable: Hive.box<ExhibitGrouping>('exhibitGroupings').listenable(),
                builder: (context, box, _) {
                  return Column(
                    children: box.values.map((grouping) {
                      return CheckboxListTile(
                        title: Text(grouping.name),
                        value: _selectedExhibitGroupingIds.contains(grouping.key),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selectedExhibitGroupingIds.add(grouping.key!);
                          } else {
                            _selectedExhibitGroupingIds.remove(grouping.key);
                          }
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (_imagePaths.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          _imagePaths[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              TextButton(
                onPressed: () => setState(() => _imagePaths.add('assets/placeholder.png')),
                child: const Text('Add Image'),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveObject();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_isEditing ? 'Update Object' : 'Add Object'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveObject() async {
    final objectBox = Hive.box<MuseumObject>('objects');
    final exhibitGroupingBox = Hive.box<ExhibitGrouping>('exhibitGroupings');

    _object.name = _nameController.text;
    _object.categoryId = _selectedCategoryId!;
    _object.subcategoryId = _selectedSubcategoryId!;
    _object.description = _descriptionController.text;
    _object.manufacturerAuthor = _manufacturerController.text;
    _object.modelSerialIsbn = _modelController.text;
    _object.dateOfProductionPublication = _selectedDate;
    _object.condition = _selectedCondition;
    _object.locationId = _selectedLocationId;
    _object.notes = _notesController.text;
    _object.imagePaths = _imagePaths;
    _object.acquisitionId = _selectedAcquisitionId;
    _object.exhibitGroupingIds = _selectedExhibitGroupingIds;

    if (_isEditing) {
      _object.save();

      // Update exhibit groupings
      for (final grouping in exhibitGroupingBox.values) {
        if (_selectedExhibitGroupingIds.contains(grouping.key) ){
        if (!grouping.objectIds.contains(widget.objectKey)) {
        grouping.objectIds.add(widget.objectKey!);
        grouping.save();
        }
        } else {
        if (grouping.objectIds.contains(widget.objectKey)) {
        grouping.objectIds.remove(widget.objectKey);
        grouping.save();
        }
        }
        }

        // Update acquisition
        if (_selectedAcquisitionId != null) {
          final acquisition = Hive.box<Acquisition>('acquisitions').get(_selectedAcquisitionId);
          if (acquisition != null && !acquisition.objectIds.contains(widget.objectKey)) {
            acquisition.objectIds.add(widget.objectKey!);
            acquisition.save();
          }
        }
      } else {
      final newKey = await objectBox.add(_object);

      // Add to exhibit groupings
      for (final grouping in exhibitGroupingBox.values) {
        if (_selectedExhibitGroupingIds.contains(grouping.key)) {
          grouping.objectIds.add(newKey);
          grouping.save();
        }
      }

      // Add to acquisition
      if (_selectedAcquisitionId != null) {
        final acquisition = Hive.box<Acquisition>('acquisitions').get(_selectedAcquisitionId);
        if (acquisition != null) {
          acquisition.objectIds.add(newKey);
          acquisition.save();
        }
      }
    }
  }
}

class ExhibitGroupingsScreen extends StatefulWidget {
  const ExhibitGroupingsScreen({super.key});

  @override
  State<ExhibitGroupingsScreen> createState() => _ExhibitGroupingsScreenState();
}

class _ExhibitGroupingsScreenState extends State<ExhibitGroupingsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search exhibit groupings',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<Box<ExhibitGrouping>>(
            valueListenable: Hive.box<ExhibitGrouping>('exhibitGroupings').listenable(),
            builder: (context, box, _) {
              var groupings = box.values.toList();

              if (_searchQuery.isNotEmpty) {
                groupings = groupings.where((grouping) {
                  return grouping.name.toLowerCase().contains(_searchQuery) ||
                      grouping.description.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              return ListView.builder(
                itemCount: groupings.length,
                itemBuilder: (context, index) {
                  final grouping = groupings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(grouping.name),
                      subtitle: Text('${grouping.objectIds.length} objects'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExhibitGroupingDetailScreen(exhibitGroupingKey: grouping.key!),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditExhibitGroupingScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class ExhibitGroupingDetailScreen extends StatelessWidget {
  final int exhibitGroupingKey;

  const ExhibitGroupingDetailScreen({super.key, required this.exhibitGroupingKey});

  @override
  Widget build(BuildContext context) {
    final grouping = Hive.box<ExhibitGrouping>('exhibitGroupings').get(exhibitGroupingKey);
    if (grouping == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grouping not found')),
        body: const Center(child: Text('The requested exhibit grouping could not be found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(grouping.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditExhibitGroupingScreen(exhibitGroupingKey: exhibitGroupingKey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Exhibit Grouping'),
                  content: const Text('Are you sure you want to delete this exhibit grouping?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // Remove grouping from objects
                final objectBox = Hive.box<MuseumObject>('objects');
                for (final objectId in grouping.objectIds) {
                  final object = objectBox.get(objectId);
                  if (object != null) {
                    object.exhibitGroupingIds.remove(exhibitGroupingKey);
                    object.save();
                  }
                }

                grouping.delete();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(grouping.description),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Objects in this grouping:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: grouping.objectIds.length,
              itemBuilder: (context, index) {
                final objectId = grouping.objectIds[index];
                final object = Hive.box<MuseumObject>('objects').get(objectId);
                return ListTile(
                  title: Text(object?.name ?? 'Object not found'),
                  subtitle: object != null ? Text(object.manufacturerAuthor) : null,
                  onTap: object != null
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObjectDetailScreen(objectKey: objectId),
                    ),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditExhibitGroupingScreen extends StatefulWidget {
  final int? exhibitGroupingKey;

  const AddEditExhibitGroupingScreen({super.key, this.exhibitGroupingKey});

  @override
  State<AddEditExhibitGroupingScreen> createState() => _AddEditExhibitGroupingScreenState();
}

class _AddEditExhibitGroupingScreenState extends State<AddEditExhibitGroupingScreen> {
  final _formKey = GlobalKey<FormState>();
  late ExhibitGrouping _grouping;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<int> _selectedObjectIds = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.exhibitGroupingKey != null;

    if (_isEditing) {
      _grouping = Hive.box<ExhibitGrouping>('exhibitGroupings').get(widget.exhibitGroupingKey!)!;
      _nameController.text = _grouping.name;
      _descriptionController.text = _grouping.description;
      _selectedObjectIds.addAll(_grouping.objectIds);
    } else {
      _grouping = ExhibitGrouping(name: '', description: '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Exhibit Grouping' : 'Add New Exhibit Grouping'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Grouping Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              const Text('Objects:', style: TextStyle(fontWeight: FontWeight.bold)),
              ValueListenableBuilder<Box<MuseumObject>>(
                valueListenable: Hive.box<MuseumObject>('objects').listenable(),
                builder: (context, box, _) {
                  return Column(
                    children: box.values.map((object) {
                      return CheckboxListTile(
                        title: Text(object.name),
                        subtitle: Text(object.manufacturerAuthor),
                        value: _selectedObjectIds.contains(object.key),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selectedObjectIds.add(object.key!);
                          } else {
                            _selectedObjectIds.remove(object.key);
                          }
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveGrouping();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_isEditing ? 'Update Grouping' : 'Add Grouping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGrouping() async {
    final groupingBox = Hive.box<ExhibitGrouping>('exhibitGroupings');
    final objectBox = Hive.box<MuseumObject>('objects');

    _grouping.name = _nameController.text;
    _grouping.description = _descriptionController.text;

    if (_isEditing) {
      // Remove grouping from objects no longer selected
      for (final objectId in _grouping.objectIds) {
        if (!_selectedObjectIds.contains(objectId)) {
          final object = objectBox.get(objectId);
          if (object != null) {
            object.exhibitGroupingIds.remove(widget.exhibitGroupingKey);
            object.save();
          }
        }
      }

      // Add grouping to newly selected objects
      for (final objectId in _selectedObjectIds) {
        if (!_grouping.objectIds.contains(objectId)) {
          final object = objectBox.get(objectId);
          if (object != null) {
            object.exhibitGroupingIds.add(widget.exhibitGroupingKey!);
            object.save();
          }
        }
      }

      _grouping.objectIds = _selectedObjectIds;
      _grouping.save();
    } else {
      final newKey = await groupingBox.add(_grouping);

      // Add grouping to all selected objects
      for (final objectId in _selectedObjectIds) {
        final object = objectBox.get(objectId);
        if (object != null) {
          object.exhibitGroupingIds.add(newKey);
          object.save();
        }
      }

      // Update grouping with correct object IDs
      _grouping.objectIds = _selectedObjectIds;
      _grouping.save();
    }
  }
}

class AcquisitionsScreen extends StatefulWidget {
  const AcquisitionsScreen({super.key});

  @override
  State<AcquisitionsScreen> createState() => _AcquisitionsScreenState();
}

class _AcquisitionsScreenState extends State<AcquisitionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search acquisitions',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<Box<Acquisition>>(
            valueListenable: Hive.box<Acquisition>('acquisitions').listenable(),
            builder: (context, box, _) {
              var acquisitions = box.values.toList();

              if (_searchQuery.isNotEmpty) {
                acquisitions = acquisitions.where((acquisition) {
                  return acquisition.source.toLowerCase().contains(_searchQuery) ||
                      acquisition.lotDescription.toLowerCase().contains(_searchQuery) ||
                      acquisition.notes.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              return ListView.builder(
                itemCount: acquisitions.length,
                itemBuilder: (context, index) {
                  final acquisition = acquisitions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(acquisition.source),
                      subtitle: Text('${DateFormat('yyyy-MM-dd').format(acquisition.acquisitionDate)} - ${acquisition.objectIds.length} objects'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcquisitionDetailScreen(acquisitionKey: acquisition.key!),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditAcquisitionScreen()),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class AcquisitionDetailScreen extends StatelessWidget {
  final int acquisitionKey;

  const AcquisitionDetailScreen({super.key, required this.acquisitionKey});

  @override
  Widget build(BuildContext context) {
    final acquisition = Hive.box<Acquisition>('acquisitions').get(acquisitionKey);
    if (acquisition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acquisition not found')),
        body: const Center(child: Text('The requested acquisition could not be found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(acquisition.source),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditAcquisitionScreen(acquisitionKey: acquisitionKey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Acquisition'),
                  content: const Text('Are you sure you want to delete this acquisition?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // Remove acquisition from objects
                final objectBox = Hive.box<MuseumObject>('objects');
                for (final objectId in acquisition.objectIds) {
                  final object = objectBox.get(objectId);
                  if (object != null) {
                    object.acquisitionId = null;
                    object.save();
                  }
                }

                acquisition.delete();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd').format(acquisition.acquisitionDate)}'),
                const SizedBox(height: 8),
                Text('Source: ${acquisition.source}'),
                const SizedBox(height: 8),
                Text('Lot Description: ${acquisition.lotDescription}'),
                if (acquisition.conditionUponArrival != null) ...[
                  const SizedBox(height: 8),
                  Text('Condition Upon Arrival: ${acquisition.conditionUponArrival}'),
                ],
                if (acquisition.appraisalInformation != null) ...[
                  const SizedBox(height: 8),
                  Text('Appraisal Information: ${acquisition.appraisalInformation}'),
                ],
                if (acquisition.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${acquisition.notes}'),
                ],
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Objects in this acquisition:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: acquisition.objectIds.length,
              itemBuilder: (context, index) {
                final objectId = acquisition.objectIds[index];
                final object = Hive.box<MuseumObject>('objects').get(objectId);
                return ListTile(
                  title: Text(object?.name ?? 'Object not found'),
                  subtitle: object != null ? Text(object.manufacturerAuthor) : null,
                  onTap: object != null
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObjectDetailScreen(objectKey: objectId),
                    ),
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditAcquisitionScreen extends StatefulWidget {
  final int? acquisitionKey;

  const AddEditAcquisitionScreen({super.key, this.acquisitionKey});

  @override
  State<AddEditAcquisitionScreen> createState() => _AddEditAcquisitionScreenState();
}

class _AddEditAcquisitionScreenState extends State<AddEditAcquisitionScreen> {
  final _formKey = GlobalKey<FormState>();
  late Acquisition _acquisition;
  bool _isEditing = false;

  final _sourceController = TextEditingController();
  final _lotDescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _conditionController = TextEditingController();
  final _appraisalController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<int> _selectedObjectIds = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.acquisitionKey != null;

    if (_isEditing) {
      _acquisition = Hive.box<Acquisition>('acquisitions').get(widget.acquisitionKey!)!;
      _sourceController.text = _acquisition.source;
      _lotDescriptionController.text = _acquisition.lotDescription;
      _notesController.text = _acquisition.notes;
      _conditionController.text = _acquisition.conditionUponArrival ?? '';
      _appraisalController.text = _acquisition.appraisalInformation ?? '';
      _selectedDate = _acquisition.acquisitionDate;
      _selectedObjectIds.addAll(_acquisition.objectIds);
    } else {
      _acquisition = Acquisition(
        acquisitionDate: DateTime.now(),
        source: '',
        lotDescription: '',
      );
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _lotDescriptionController.dispose();
    _notesController.dispose();
    _conditionController.dispose();
    _appraisalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Acquisition' : 'Add New Acquisition'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Date: '),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        setState(() => _selectedDate = selectedDate);
                      }
                    },
                    child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(labelText: 'Source'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a source' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lotDescriptionController,
                decoration: const InputDecoration(labelText: 'Lot Description'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a lot description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(labelText: 'Condition Upon Arrival (optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _appraisalController,
                decoration: const InputDecoration(labelText: 'Appraisal Information (optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Objects:', style: TextStyle(fontWeight: FontWeight.bold)),
              ValueListenableBuilder<Box<MuseumObject>>(
                valueListenable: Hive.box<MuseumObject>('objects').listenable(),
                builder: (context, box, _) {
                  return Column(
                    children: box.values.map((object) {
                      return CheckboxListTile(
                        title: Text(object.name),
                        subtitle: Text(object.manufacturerAuthor),
                        value: _selectedObjectIds.contains(object.key),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selectedObjectIds.add(object.key!);
                          } else {
                            _selectedObjectIds.remove(object.key);
                          }
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveAcquisition();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_isEditing ? 'Update Acquisition' : 'Add Acquisition'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAcquisition() async {
    final acquisitionBox = Hive.box<Acquisition>('acquisitions');
    final objectBox = Hive.box<MuseumObject>('objects');

    _acquisition.acquisitionDate = _selectedDate;
    _acquisition.source = _sourceController.text;
    _acquisition.lotDescription = _lotDescriptionController.text;
    _acquisition.notes = _notesController.text;
    _acquisition.conditionUponArrival = _conditionController.text.isEmpty ? null : _conditionController.text;
    _acquisition.appraisalInformation = _appraisalController.text.isEmpty ? null : _appraisalController.text;

    if (_isEditing) {
      // Remove acquisition from objects no longer selected
      for (final objectId in _acquisition.objectIds) {
        if (!_selectedObjectIds.contains(objectId)) {
          final object = objectBox.get(objectId);
          if (object != null) {
            object.acquisitionId = null;
            object.save();
          }
        }
      }

      // Add acquisition to newly selected objects
      for (final objectId in _selectedObjectIds) {
        if (!_acquisition.objectIds.contains(objectId)) {
          final object = objectBox.get(objectId);
          if (object != null) {
            object.acquisitionId = widget.acquisitionKey;
            object.save();
          }
        }
      }

      _acquisition.objectIds = _selectedObjectIds;
      _acquisition.save();
    } else {
      final newKey = await acquisitionBox.add(_acquisition);

      // Add acquisition to all selected objects
      for (final objectId in _selectedObjectIds) {
        final object = objectBox.get(objectId);
        if (object != null) {
          object.acquisitionId = newKey;
          object.save();
        }
      }

      // Update acquisition with correct object IDs
      _acquisition.objectIds = _selectedObjectIds;
      _acquisition.save();
    }
  }
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Category>>(
      valueListenable: Hive.box<Category>('categories').listenable(),
      builder: (context, box, _) {
        return ListView.builder(
          itemCount: box.values.length,
          itemBuilder: (context, index) {
            final category = box.getAt(index)!;
            return ExpansionTile(
              title: Text(category.name),
              children: [
                ValueListenableBuilder<Box<Subcategory>>(
                  valueListenable: Hive.box<Subcategory>('subcategories').listenable(),
                  builder: (context, subBox, _) {
                    final subcategories = subBox.values
                        .where((sub) => sub.categoryId == category.key)
                        .toList();
                    return Column(
                      children: subcategories.map((subcategory) {
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(subcategory.name),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editSubcategory(context, subcategory),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteSubcategory(context, subcategory),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: TextButton(
                    onPressed: () => _addSubcategory(context, category),
                    child: const Text('Add Subcategory'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addSubcategory(BuildContext context, Category category) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Subcategory'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Hive.box<Subcategory>('subcategories').add(
                    Subcategory(
                      categoryId: category.key!,
                      name: controller.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editSubcategory(BuildContext context, Subcategory subcategory) {
    final controller = TextEditingController(text: subcategory.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Subcategory'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Subcategory Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  subcategory.name = controller.text;
                  subcategory.save();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubcategory(BuildContext context, Subcategory subcategory) async {
    // Check if any objects are using this subcategory
    final isUsed = Hive.box<MuseumObject>('objects').values
        .any((obj) => obj.subcategoryId == subcategory.key);

    if (isUsed) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete'),
          content: const Text('This subcategory is in use by one or more objects and cannot be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: const Text('Are you sure you want to delete this subcategory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      subcategory.delete();
    }
  }
}