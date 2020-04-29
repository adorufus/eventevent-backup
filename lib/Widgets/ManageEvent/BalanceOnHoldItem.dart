import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BalanceOnHoldItem extends StatefulWidget {
  final ticketQuantity;
  final username;
  final price;
  final totalPrice;
  final DateTime dateTime;
  final ticketName;
  final ticketImage;
  final userPict;

  const BalanceOnHoldItem({Key key, this.ticketQuantity, this.username, this.price, this.totalPrice, this.dateTime, this.ticketName, this.ticketImage, this.userPict}) : super(key: key);

  @override
  _BalanceOnHoldItemState createState() => _BalanceOnHoldItemState();
}

class _BalanceOnHoldItemState extends State<BalanceOnHoldItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 13),
      margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: <Widget>[
                Text('Buyer: '),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(widget.userPict),
                ),
                SizedBox(
                width: 5,
              ),
                Text(widget.username)
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100,
                width: 75,
                child: Image.network(
                  widget.ticketImage,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${widget.ticketQuantity}x ${widget.ticketName}'),
                  SizedBox(
                    height: 8,
                  ),
                  Text('Rp. ${widget.price}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 8,
                  ),
                  Text('${widget.dateTime.day} - ${widget.dateTime.month} - ${widget.dateTime.year}', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Expanded(
                child: SizedBox(),
              ),
              Text(
                'Rp. ${widget.totalPrice}',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 13,
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            thickness: 2,
          ),
          Row(
            children: <Widget>[
              Text('Ticket Type: '),
              Container(
                height: ScreenUtil.instance.setWidth(15),
                width: ScreenUtil.instance.setWidth(45),
                decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color(0xFF34B323).withOpacity(0.4),
                          blurRadius: 2,
                          spreadRadius: 1.5)
                    ],
                    color: Color(0xFF34B323),
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                    child: Text(
                  'Paid',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.instance.setSp(12),
                      fontWeight: FontWeight.bold),
                )),
              ),
              SizedBox(width: 8,),
              Text('Paid')
            ],
          )
        ],
      ),
    );
  }
}
