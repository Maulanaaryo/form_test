import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum RequestState {
  Loading,
  Loaded,
  Error,
}

class DataProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference _data =
      FirebaseFirestore.instance.collection('data');

  List<DocumentSnapshot> _documents = [];
  String? _selectedDocumentId;
  RequestState _state = RequestState.Loading;

  List<DocumentSnapshot> get documents => _documents;
  String? get selectedDocumentId => _selectedDocumentId;
  RequestState get state => _state;

  DataProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      _state = RequestState.Loading;
      notifyListeners();

      var snapshot = await _data.get();
      _documents = snapshot.docs;

      _state = RequestState.Loaded;
      notifyListeners();
    } catch (error) {
      print('Error fetching data: $error');

      _state = RequestState.Error;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _data.doc(documentId).delete();
      await fetchData();
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  void setSelectedDocumentId(String? documentId) {
    _selectedDocumentId = documentId;
    notifyListeners();
  }

  void resetSelectedDocumentId() {
    _selectedDocumentId = null;
    notifyListeners();
  }
}
