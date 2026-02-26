import 'package:hive/hive.dart';

import '../models/search_model.dart';

class SearchLocalRepo {
  final String _dataBaseName = 'search_data';
  final String _key = 'search_key';

  Future<SearchLocalRepo> init() async {
    await Hive.openBox(_dataBaseName);
    return SearchLocalRepo();
  }

  Future<void> saveEntry({required String query}) async {
    var box = Hive.box(_dataBaseName);
    final list = await getEntries();

    /// Removes old value if have any
    final filteredList =
        list.where((element) => element.query != query).toList();
    final data = SearchModel(query: query, time: DateTime.now());
    filteredList.add(data);
    filteredList.sort((a, b) => b.time.compareTo(a.time));
    final dataInMap = filteredList.map((e) => e.toMap()).toList();
    box.put(_key, dataInMap);
  }

  Future<void> deleteEntry({required SearchModel query}) async {
    var box = Hive.box(_dataBaseName);
    final theList = await getEntries();
    final data = theList.where((element) => element != query).toList();
    final convertedList = data.map((e) => e.toMap()).toList();
    await box.put(_key, convertedList);
  }

  Future<void> deleteAll() async {
    var box = Hive.box(_dataBaseName);
    await box.put(_key, []);
  }

  Future<List<SearchModel>> getEntries() async {
    var box = Hive.box(_dataBaseName);
    final List data = await box.get(_key) ?? [];
    final theList = data.map((e) => SearchModel.fromMap(Map.from(e))).toList();
    return List<SearchModel>.from(theList);
  }
}
