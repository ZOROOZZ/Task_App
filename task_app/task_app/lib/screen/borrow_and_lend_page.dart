import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowAndLendPage extends StatefulWidget {
  const BorrowAndLendPage({super.key});

  @override
  State<BorrowAndLendPage> createState() => _BorrowAndLendPageState();
}

class _BorrowAndLendPageState extends State<BorrowAndLendPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Section with Borrowed and Lent Cards
          Row(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('Borrow').where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    double totalBorrowed = 0.0;
                    if (snapshot.hasData) {
                      totalBorrowed = snapshot.data!.docs.fold(
                          0.0,
                          (sum, doc) =>
                              sum + double.tryParse(doc['Amount'].toString())!);
                    }
                    return buildSummaryCard(
                        totalBorrowed, "Total Borrowed", Colors.green);
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('Lend').snapshots(),
                  builder: (context, snapshot) {
                    double totalLent = 0.0;
                    if (snapshot.hasData) {
                      totalLent = snapshot.data!.docs.fold(
                          0.0,
                          (sum, doc) =>
                              sum + double.tryParse(doc['Amount'].toString())!);
                    }
                    return buildSummaryCard(
                        totalLent, "Total Lent", Colors.red);
                  },
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Expanded(
            child: Row(
              children: [
                // Borrowed List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Borrowed List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('Borrow').where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text(
                                "No data available",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ));
                            }
                            return ListView(
                              children: snapshot.data!.docs.map((doc) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .green[200], // Light green background
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    title: Text(
                                      doc['Name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          "Amount: \$${doc['Amount']}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${doc['Date']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, color: Colors.grey),
                // Lent List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Lent List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('Lend').where("creator",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text(
                                "No data available",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ));
                            }
                            return ListView(
                              children: snapshot.data!.docs.map((doc) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.5), // Light green background
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    title: Text(
                                      doc['Name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          "Amount: \$${doc['Amount']}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${doc['Date']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isScrollControlled: true,
            builder: (context) {
              return const BorrowLendForm();
            },
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildSummaryCard(double amount, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.attach_money, size: 36, color: color),
          const SizedBox(height: 8),
          Text(
            "\$$amount",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class BorrowLendForm extends StatefulWidget {
  const BorrowLendForm({super.key});

  @override
  _BorrowLendFormState createState() => _BorrowLendFormState();
}

class _BorrowLendFormState extends State<BorrowLendForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedTab = "Borrow Money";
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void addEntry() {
    String collection = selectedTab == "Borrow Money" ? "Borrow" : "Lend";

    _firestore.collection(collection).add({
      'Name': nameController.text,
      'Amount': double.parse(amountController.text),
      'Date': selectedDate.toLocal().toString().split(' ')[0],
      'creator':FirebaseAuth.instance.currentUser!.uid,
    });

    Navigator.pop(context); // Close the bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Entry here",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = "Borrow Money"; // ✅ FIXED: Using setState
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Borrow Money",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selectedTab == "Borrow Money"
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedTab == "Borrow Money"
                            ? Colors.purple
                            : Colors.grey,
                      ),
                    ),
                    if (selectedTab == "Borrow Money")
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.purple,
                      )
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = "Lend Money"; // ✅ FIXED: Using setState
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Lend Money",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selectedTab == "Lend Money"
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedTab == "Lend Money"
                            ? Colors.purple
                            : Colors.grey,
                      ),
                    ),
                    if (selectedTab == "Lend Money")
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.purple,
                      )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Person's Name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate= pickedDate;
                    });
                  }
                },
                child: const Text("Select Date"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: addEntry,
            child: Text(
                "Add ${selectedTab == "Borrow Money" ? "Borrow" : "Lend"} Entry"),
          ),
        ],
      ),
    );
  }
}
