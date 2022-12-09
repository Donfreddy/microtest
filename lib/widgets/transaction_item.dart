import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import 'avatar_image.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem(this.data, {Key? key, this.onTap}) : super(key: key);
  final Map<String, dynamic> data;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                data['provider_logo'] != ''
                    ? AvatarImage(
                        data['provider_logo'],
                        isSVG: false,
                        isAsset: true,
                        width: 35,
                        height: 35,
                        radius: 50,
                      )
                    : const CircleAvatar(
                        backgroundColor: appBgColorPrimary,
                        child: Text(
                          'D',
                          style: TextStyle(
                              color: secondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(data['phone'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700))),
                          const SizedBox(width: 5),
                          Text(
                            '${data['amount']} FCFA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            DateFormat.yMd().add_Hms().format(DateTime.parse(
                                data['date'].toDate().toString())),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            "${data['status']}".toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                color: getStatusColor(data['status'])),
                          ),
                          Container(
                            child: data['type'] == 'cashint'
                                ? const Icon(
                                    Icons.download_rounded,
                                    color: green,
                                  )
                                : const Icon(
                                    Icons.upload_rounded,
                                    color: red,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'success':
      return Colors.green;
    case 'pending':
      return Colors.cyan;
    case 'fail':
      return Colors.red;
    default:
      return Colors.orange;
  }
}
