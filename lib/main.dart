import 'package:flutter/material.dart';

const kIconSize = 48.0;
const kPadding = 4.0;
const kMargin = 8.0;
const kRadius = 8.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: ToolBarButton.icons,
            builder: (e) => ToolBarButton(iconData: e),
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _itemsBeforeDrag = widget.items.toList();
  late final List<T> _items = widget.items.toList();

  T itemAtIndex(int index) => _itemsBeforeDrag[index];

  int get sourceLength => widget.items.length;

  bool get dragging => _items.length < sourceLength;

  void _onAcceptWithDetails(DragTargetDetails<int> details, int index) {
    setState(() {
      _items.insert(
        index,
        itemAtIndex(details.data),
      );
      _itemsBeforeDrag.clear();
      _itemsBeforeDrag.addAll(_items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(kPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.items.length * kIconSize * 1.5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._items.asMap().entries.map((entry) {
              int index = entry.key;
              T item = entry.value;
              return DragTarget<int>(
                builder: (
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                ) {
                  return Draggable<int>(
                      data: index,
                      feedback: widget.builder(item),
                      child: widget.builder(item),
                      onDraggableCanceled: (velocity, offset) {
                        setState(() {
                          _items.clear();
                          _items.addAll(_itemsBeforeDrag);
                        });
                      },
                      onDragStarted: () => setState(() {
                            _items.removeAt(index);
                          }),
                      onDragEnd: (details) {
                        setState(() {
                          if (!details.wasAccepted) {
                            _items.clear();
                            _items.addAll(_itemsBeforeDrag);
                          }
                        });
                      });
                },
                onAcceptWithDetails: (DragTargetDetails<int> details) =>
                    _onAcceptWithDetails(details, index),
              );
            }),
            if (dragging)
              DragTarget<int>(
                builder: (
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                ) =>
                    Stub(),
                onAcceptWithDetails: (DragTargetDetails<int> details) =>
                    _onAcceptWithDetails(details, sourceLength - 1),
              ),
          ],
        ),
      ),
    );
  }
}

class Stub extends StatelessWidget {
  const Stub({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kIconSize,
      height: kIconSize,
    );
  }
}

class ToolBarButton extends StatelessWidget {
  const ToolBarButton({
    super.key,
    required final IconData iconData,
  }) : _iconData = iconData;

  final IconData _iconData;

  static const icons = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

  Color get backgroundColor => Colors.primaries[icons.indexOf(_iconData)];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: kIconSize),
      height: kIconSize,
      margin: const EdgeInsets.all(kMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius),
        color: backgroundColor,
      ),
      child: Center(child: Icon(_iconData, color: Colors.white)),
    );
  }
}
