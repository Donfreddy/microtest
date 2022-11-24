import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:microtest/common/constant.dart';
import 'package:microtest/data/json.dart';
import 'package:microtest/widgets/avatar_image.dart';

import '../theme/colors.dart';
import '../widgets/action_box.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/user_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: getAppBar(),
      body: getBody(),
    );
  }

  getAppBar() {
    return Container(
      height: 130,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 35),
      decoration: BoxDecoration(
          color: appBgColor,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
                color: shadowColor.withOpacity(0.1),
                blurRadius: .5,
                spreadRadius: .5,
                offset: const Offset(0, 1))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarImage(profile, isSVG: false, width: 35, height: 35),
          const SizedBox(width: 15),
          Expanded(
              child: Container(
            alignment: Alignment.centerLeft,
            // color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello ${firebaseAuth.currentUser?.email},",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                ),
              ],
            ),
          )),
          const SizedBox(
            width: 15,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
            // child: Icon(Icons.notifications_rounded)
            child: Badge(
                padding: const EdgeInsets.all(3),
                position: BadgePosition.topEnd(top: -5, end: 2),
                badgeContent: const Text(
                  '',
                  style: TextStyle(color: Colors.white),
                ),
                child: const Icon(Icons.notifications_rounded)),
          ),
        ],
      ),
    );
  }

  getBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          getAppBar(),
          const SizedBox(
            height: 25,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  BalanceCard(onTap: () => buildDepositMoneyModal(context)),
                  Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: secondary,
                              shape: BoxShape.circle,
                              border: Border.all()),
                          child: const Icon(Icons.add)))
                ],
              )),
          const SizedBox(
            height: 35,
          ),
          getActions(context),
          const SizedBox(
            height: 25,
          ),
          Container(
              padding: const EdgeInsets.only(left: 20, right: 15),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transactions",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                      child: Container(
                          alignment: Alignment.centerRight,
                          child: const Text(
                            "Today",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ))),
                  const Icon(Icons.expand_more_rounded),
                ],
              )),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: getTransactions(),
          ),
        ],
      ),
    );
  }

  getActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 15,
        ),
        Expanded(
            child: ActionBox(
          title: "Send",
          icon: Icons.send_rounded,
          bgColor: green,
          onTap: () {},
        )),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: ActionBox(
            title: "Request",
            icon: Icons.arrow_circle_down_rounded,
            bgColor: yellow,
            onTap: () => buildRequestMoneyModal(context),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
            child: ActionBox(
          title: "More",
          icon: Icons.widgets_rounded,
          bgColor: purple,
          onTap: () {},
        )),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }

  getRecentUsers() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 5),
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(
              recentUsers.length,
              (index) => index == 0
                  ? Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: getSearchBox(),
                        ),
                        Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: UserBox(user: recentUsers[index]))
                      ],
                    )
                  : Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: UserBox(user: recentUsers[index])))),
    );
  }

  getSearchBox() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.grey.shade300, shape: BoxShape.circle),
          child: const Icon(Icons.search_rounded),
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          "Search",
          style: TextStyle(fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  getTransactions() {
    String userId = firebaseAuth.currentUser!.uid;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: databaseReference
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'You have not made a transaction yet.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        List<Map<String, dynamic>> data =
            snapshot.data!.docs.map((e) => e.data()).toList();
        return ListView.builder(
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, i) {
            print(data[i]);
            return Container(
              margin: const EdgeInsets.only(right: 15),
              child: TransactionItem(data[i]),
            );
          },
        );
      },
    );
  }
}

Future buildDepositMoneyModal(BuildContext context) {
  return showModal(
    context: context,
    configuration: const FadeScaleTransitionConfiguration(
      transitionDuration: Duration(
        milliseconds: 300,
      ),
    ),
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Text(
        "Depots sur un compte",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
      ),
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant',
            ),
          ),
          const TextField(
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Numero de telephone',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red.shade300),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(appBgColorPrimary),
                  ),
                  onPressed: () {},
                  child: const Text('Deposer'),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Future buildRequestMoneyModal(BuildContext context) {
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "Orange", child: Text("Orange")),
    const DropdownMenuItem(value: "MTN", child: Text("MTN")),
  ];

  String selectedValue = "Orange";

  return showModal(
    context: context,
    configuration: const FadeScaleTransitionConfiguration(
      transitionDuration: Duration(
        milliseconds: 300,
      ),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: const Text(
          "Retirer des fonds",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        titlePadding: const EdgeInsets.all(20),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Recevoir dans:')),
                DropdownButton(
                  value: selectedValue,
                  items: menuItems,
                  onChanged: (String? value) {
                    if (value != null && selectedValue != value) {
                      selectedValue = value;
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            const TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant',
              ),
            ),
            const TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Numero de telephone',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red.shade300),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(appBgColorPrimary),
                    ),
                    onPressed: () {},
                    child: const Text('Demander'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
