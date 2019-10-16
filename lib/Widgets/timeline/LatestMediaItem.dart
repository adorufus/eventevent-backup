import 'package:flutter/material.dart';

class LatestMediaItem extends StatelessWidget {
  final bool isVideo;
  final image;
  final title;
  final username;
  final userImage;

  const LatestMediaItem(
      {Key key,
      this.isVideo,
      this.image,
      this.title,
      this.username,
      this.userImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      height: 110,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Container(
            width: 167,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(image), fit: BoxFit.cover),
              color: Color(0xFFB5B5B5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: isVideo == false
                ? Container()
                : Center(
                    child: Image.asset('assets/icons/icon_apps/play.png', scale: 3,)
                  ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      radius: 7,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '@$username',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8B)),
                    ),
                  ]),
                  SizedBox(height: 4),
                  Container(
                    height: 40,
                    width: 150,
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                  ),
                  Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 13),
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          spreadRadius: 1.5)
                                    ]),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icon_apps/love.png',
                                        color: Colors.red,
                                        scale: 3.5,
                                      ),
                                      SizedBox(width: 5),
                                      Text('99+',
                                          style: TextStyle(
                                              color: Color(
                                                  0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                    ]),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 13),
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          spreadRadius: 1.5)
                                    ]),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icon_apps/comment.png',
                                        scale: 3.5,
                                      ),
                                      SizedBox(width: 5),
                                      Text('99+',
                                          style: TextStyle(
                                              color: Color(
                                                  0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
                                    ]),
                              ),
                            ],
                          ),
                        )
                ]),
          )
        ],
      ),
    );
  }
}
