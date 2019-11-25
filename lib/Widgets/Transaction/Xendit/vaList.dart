import 'package:eventevent/Widgets/RecycleableWidget/ChooseBankAccount.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';


class VirtualAccountListWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _VirtualAccountListWidget();
  }
}

class _VirtualAccountListWidget extends State<VirtualAccountListWidget>{
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return ChooseBankAccount(
      title: 'CHOOSE BANK ACCOUNT',
    );
  }
}