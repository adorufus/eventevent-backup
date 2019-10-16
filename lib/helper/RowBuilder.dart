import 'package:flutter/material.dart';

class ColumnBuilder extends StatelessWidget {
	final IndexedWidgetBuilder itemBuilder;
	final MainAxisAlignment mainAxisAlignment;
	final MainAxisSize mainAxisSize;
	final CrossAxisAlignment crossAxisAlignment;
	final TextDirection textDirection;
	final int itemCount;

	const RowBuilder({
		Key key,
		@required this.itemBuilder,
		@required this.itemCount,
		this.mainAxisAlignment: MainAxisAlignment.start,
		this.mainAxisSize: MainAxisSize.max,
		this.crossAxisAlignment: CrossAxisAlignment.center,
		this.textDirection,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return new Row(
			children: new List.generate(this.itemCount,
					(index) => this.itemBuilder(context, index)).toList(),
		);
	}
}