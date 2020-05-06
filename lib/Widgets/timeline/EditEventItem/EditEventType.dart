import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditEventType extends StatefulWidget {
	@override
	State<StatefulWidget> createState() {
		return EditEventTypeState();
	}
}

class EditEventTypeState extends State<EditEventType> {
	var thisTextController = TextEditingController();
	var thisScaffold = new GlobalKey<ScaffoldState>();

	String isPrivate;
	bool isPrivateChecked = null;

	@override
	Widget build(BuildContext context) {
		double defaultScreenWidth = 400.0;
		double defaultScreenHeight = 810.0;

		ScreenUtil.instance = ScreenUtil(
			width: defaultScreenWidth,
			height: defaultScreenHeight,
			allowFontScaling: true,
		)..init(context);
		return Scaffold(
			key: thisScaffold,
			appBar: AppBar(
				brightness: Brightness.light,
				backgroundColor: Colors.white,
				elevation: 0,
				leading: GestureDetector(
					onTap: () {
						Navigator.pop(context);
					},
					child: Icon(
						Icons.arrow_back_ios,
						color: eventajaGreenTeal,
					),
				),
				centerTitle: true,
				title: Text(
					'EDIT EVENT',
					style: TextStyle(color: eventajaGreenTeal),
				),
				actions: <Widget>[
					Padding(
						padding: EdgeInsets.only(right: 10),
						child: Center(
							child: GestureDetector(
								onTap: () {
									navigateToNextStep();
								},
								child: Text(
									'Next',
									style: TextStyle(
										color: eventajaGreenTeal,
										fontSize: ScreenUtil.instance.setSp(18)),
								),
							),
						),
					)
				],
			),
			body: Container(
				color: Colors.white,
				padding: EdgeInsets.only(left: 15, top: 15),
				height: ScreenUtil.instance.setWidth(400),
				width: MediaQuery.of(context).size.width,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					mainAxisAlignment: MainAxisAlignment.start,
					children: <Widget>[
						Row(
							mainAxisAlignment: MainAxisAlignment.start,
							children: <Widget>[
								Text(
									'Event Type',
									style: TextStyle(
										color: Colors.black54,
										fontSize: 40,
										fontWeight: FontWeight.bold),
								),
								SizedBox(
									width: MediaQuery.of(context).size.width / 6.7,
								),
							],
						),
						SizedBox(
							height: ScreenUtil.instance.setWidth(20),
						),
						Padding(
							padding: const EdgeInsets.only(right: 15),
							child: Divider(
								color: Colors.grey,
								height: ScreenUtil.instance.setWidth(10),
							),
						),
						SizedBox(
							height: ScreenUtil.instance.setWidth(50),
						),
						Padding(
							padding: const EdgeInsets.only(
								right: 15,
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.center,
								mainAxisAlignment: MainAxisAlignment.start,
								children: <Widget>[
									GestureDetector(
										onTap: () {
											setState(() {
												isPrivate = '0';
												isPrivateChecked = false;
											});
											navigateToNextStep();
										},
										child: Container(
											height: ScreenUtil.instance.setWidth(70),
											width: ScreenUtil.instance.setWidth(320),
											child: Row(
												crossAxisAlignment: CrossAxisAlignment.center,
												mainAxisAlignment: MainAxisAlignment.start,
												children: <Widget>[
													Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: <Widget>[
															SizedBox(
																height: ScreenUtil.instance.setWidth(40),
																width: ScreenUtil.instance.setWidth(40),
																child: Image.asset(
																	'assets/icons/Event_public.png',
																	fit: BoxFit.fill,
																),
															),
															SizedBox(height: 10,)
														],
													),
													SizedBox(
														width: ScreenUtil.instance.setWidth(15),
													),
													Column(
														mainAxisAlignment: MainAxisAlignment.center,
														crossAxisAlignment: CrossAxisAlignment.start,
														children: <Widget>[
															Text(
																'Public Event',
																style: TextStyle(
																	color: Colors.black54,
																	fontSize:
																	ScreenUtil.instance.setSp(18),
																	fontWeight: FontWeight.bold),
															),
															SizedBox(
																height: ScreenUtil.instance.setWidth(5),
															),
															Container(
																height:
																ScreenUtil.instance.setWidth(45),
																child: Text(
																	'Everyone can discover and get \naccess to your event',
																	maxLines: 2,
																)),
														],
													),
													SizedBox(
														width: ScreenUtil.instance.setWidth(20),
													),
													isPrivateChecked == null ||
														isPrivateChecked == true
														? Container()
														: SizedBox(
														height:
														ScreenUtil.instance.setWidth(20),
														width: ScreenUtil.instance.setWidth(20),
														child: Image.asset(
															'assets/icons/checklist_green.png'))
												],
											)),
									),
									SizedBox(
										height: ScreenUtil.instance.setWidth(20),
									),
									GestureDetector(
										onTap: () {
											setState(() {
												isPrivate = '1';
												isPrivateChecked = true;
											});
											navigateToNextStep();
										},
										child: Container(
											height: ScreenUtil.instance.setWidth(70),
											width: ScreenUtil.instance.setWidth(320),
											child: Row(
												crossAxisAlignment: CrossAxisAlignment.center,
												mainAxisAlignment: MainAxisAlignment.start,
												children: <Widget>[
													Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: <Widget>[
															SizedBox(
																height: ScreenUtil.instance.setWidth(40),
																width: ScreenUtil.instance.setWidth(35),
																child: Image.asset(
																	'assets/icons/Event_private.png',
																	fit: BoxFit.fill,
																),
															),
															SizedBox(height: 10,)
														],
													),
													SizedBox(
														width: ScreenUtil.instance.setWidth(15),
													),
													Column(
														mainAxisAlignment: MainAxisAlignment.center,
														crossAxisAlignment: CrossAxisAlignment.start,
														children: <Widget>[
															Text(
																'Private Event',
																style: TextStyle(
																	color: Colors.black54,
																	fontSize:
																	ScreenUtil.instance.setSp(18),
																	fontWeight: FontWeight.bold),
															),
															SizedBox(
																height: ScreenUtil.instance.setWidth(5),
															),
															Container(
																height:
																ScreenUtil.instance.setWidth(45),
																child: Text(
																	'For events that can be find and \naccess only by your invitation',
																	maxLines: 2,
																)),
														],
													),
													SizedBox(
														width: ScreenUtil.instance.setWidth(20),
													),
													isPrivateChecked == null ||
														isPrivateChecked == false
														? Container()
														: SizedBox(
														height:
														ScreenUtil.instance.setWidth(20),
														width: ScreenUtil.instance.setWidth(20),
														child: Image.asset(
															'assets/icons/checklist_green.png'))
												],
											)),
									)
								],
							))
					],
				),
			));
	}
	navigateToNextStep() async {
		SharedPreferences prefs = await SharedPreferences.getInstance();
		if (isPrivate == null || isPrivate == '') {
			Flushbar(
				flushbarPosition: FlushbarPosition.TOP,
				message: 'Choose your event type!',
				backgroundColor: Colors.red,
				duration: Duration(seconds: 3),
				animationDuration: Duration(milliseconds: 500),
			)..show(context);
		} else {
			print(isPrivate);
			if (isPrivateChecked == true) {
				prefs.setString('POST_EVENT_TYPE', isPrivate);
			} else {
				prefs.setString('POST_EVENT_TYPE', isPrivate);
			}
			Navigator.pop(context, isPrivate);
		}
	}
}