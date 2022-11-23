import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:microtest/common/constant.dart';

import '../theme/colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId = firebaseAuth.currentUser!.uid;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                ),
              ],
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), BlendMode.dstATop),
                image: const AssetImage('assets/images/bgcard.png'),
              )),
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Your Balance",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: databaseReference
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return const Text('data');
                    }
                    return  Text(
                      "${snapshot.data!['balance']} FCFA",
                      style: const TextStyle(
                        color: secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
            ],
          ),
        ),
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
    );
  }
}
