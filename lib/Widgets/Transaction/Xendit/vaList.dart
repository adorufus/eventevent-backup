import 'package:eventevent/Widgets/RecycleableWidget/ChooseBankAccount.dart';
import 'package:flutter/material.dart';


class VirtualAccountListWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _VirtualAccountListWidget();
  }
}

class _VirtualAccountListWidget extends State<VirtualAccountListWidget>{
  @override
  Widget build(BuildContext context) {
    return ChooseBankAccount(
      title: 'CHOOSE BANK ACCOUNT',
    );
  }
}