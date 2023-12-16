import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_tes/data/local_data.dart';
import 'package:mobile_tes/presentation/pages/auth/login_page.dart';
import 'package:mobile_tes/presentation/provider/data_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? handphoneController;
  String? selectedDocumentId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    handphoneController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference data = firestore.collection('data');

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              final pref = SharedServices();
              pref.deleteToken();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          if (dataProvider.documents.isEmpty) {
            return const Center(
              child: Text('No Data'),
            );
          }

          List<DocumentSnapshot> docs = dataProvider.documents;
          RequestState state = dataProvider.state;

          return SingleChildScrollView(
            child: Column(
              children: [
                if (state == RequestState.Loaded)
                  Column(
                    children: docs
                        .map(
                          (e) => CustomCard(
                            name: (e.data() as Map<String, dynamic>)['name'] ??
                                'No Name',
                            email:
                                (e.data() as Map<String, dynamic>)['email'] ??
                                    'No Email',
                            phone: (e.data() as Map<String, dynamic>)['phone']
                                    as int? ??
                                0,
                            onUpdatePressed: () {
                              setState(() {
                                selectedDocumentId = e.id;
                                nameController!.text =
                                    (e.data() as Map<String, dynamic>)['name'];
                                emailController!.text =
                                    (e.data() as Map<String, dynamic>)['email'];
                                handphoneController!.text =
                                    (e.data() as Map<String, dynamic>)['phone']
                                            ?.toString() ??
                                        '';
                              });
                            },
                            onDeletePressed: () async {
                              await data.doc(e.id).delete();

                              Provider.of<DataProvider>(context, listen: false)
                                  .fetchData();
                            },
                          ),
                        )
                        .toList(),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            TextFormField(
              controller: handphoneController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'No Hp',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedDocumentId != null) {
                    await data.doc(selectedDocumentId!).update({
                      'name': nameController!.text,
                      'email': emailController!.text,
                      'phone': int.tryParse(handphoneController!.text) ?? 0,
                    });
                  } else {
                    await data.add({
                      'name': nameController!.text,
                      'email': emailController!.text,
                      'phone': int.tryParse(handphoneController!.text) ?? 0,
                    });
                  }
                  setState(() {
                    nameController!.text = '';
                    emailController!.text = '';
                    handphoneController!.text = '';
                    selectedDocumentId = null;
                  });

                  Provider.of<DataProvider>(context, listen: false).fetchData();
                },
                child: Text(selectedDocumentId != null ? 'Update' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String name;
  final String email;
  final int phone;
  final VoidCallback onUpdatePressed;
  final VoidCallback onDeletePressed;

  const CustomCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.onUpdatePressed,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $name',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Email: $email', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    color: Colors.amber,
                    icon: const Icon(Icons.edit),
                    onPressed: onUpdatePressed,
                  ),
                  IconButton(
                    color: Colors.red,
                    icon: const Icon(Icons.delete),
                    onPressed: onDeletePressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
