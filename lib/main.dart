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
  late final _paddingTween =
      widget.items.map((x) => EdgeInsetsTween()).toList();

  T itemAtIndex(int index) => _itemsBeforeDrag[index];

  int get sourceLength => widget.items.length;

  bool get dragging => _items.length < sourceLength;

  int? indexSelected;

  static final double _maxPadding = 25.0;
  @override
  void initState() {
    super.initState();
    _updatePaddingTweens();
  }

  void _onAcceptWithDetails(DragTargetDetails<int> details, int index) {
    setState(() {
      indexSelected = null;
      _items.insert(
        index,
        itemAtIndex(details.data),
      );
      _itemsBeforeDrag.clear();
      _itemsBeforeDrag.addAll(_items);
    });
  }

  void _updatePaddingTweens() {
    for (int i = 0; i < _paddingTween.length; i++) {
      _updateItemPadding(i);
    }
  }

  void _updateItemPadding(int index) {
    if (indexSelected != null) {
      _paddingTween[index] = EdgeInsetsTween(
          begin: EdgeInsets.zero,
          end: EdgeInsets.only(bottom: _calcPadding(index)));
    } else {
      _paddingTween[index] = EdgeInsetsTween(
        begin: EdgeInsets.only(bottom: _calcPadding(index)),
        end: EdgeInsets.zero,
      );
    }
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

              return MouseRegion(
                onEnter: (event) => setState(() {
                  indexSelected = index;
                  _updatePaddingTweens();
                }),
                onExit: (event) => setState(() {
                  indexSelected = null;
                  _updatePaddingTweens();
                }),
                child: TweenAnimationBuilder(
                  tween: _paddingTween[index],
                  duration: Duration(milliseconds: 400),
                  builder: (context, value, _) => Padding(
                    padding: value,
                    child: DragTarget<int>(
                      builder: (
                        BuildContext context,
                        List<dynamic> accepted,
                        List<dynamic> rejected,
                      ) {
                        return Draggable<int>(
                          data: index,
                          feedback: widget.builder(item),
                          onDraggableCanceled: (velocity, offset) {
                            setState(() {
                              _items.clear();
                              _items.addAll(_itemsBeforeDrag);
                            });
                          },
                          onDragStarted: () => setState(() {
                            indexSelected = index;
                            _items.removeAt(index);
                          }),
                          onDragEnd: (details) {
                            setState(() {
                              if (!details.wasAccepted) {
                                _items.clear();
                                _items.addAll(_itemsBeforeDrag);
                                indexSelected = null;
                              }
                            });
                          },
                          child: widget.builder(item),
                        );
                      },
                      onAcceptWithDetails: (DragTargetDetails<int> details) =>
                          _onAcceptWithDetails(details, index),
                    ),
                  ),
                ),
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

  double _calcPadding(int index) {
    if (indexSelected == null) {
      return 0;
    }
    if (indexSelected! < index) {
      return _maxPadding / (index - indexSelected! + 1);
    }
    if (indexSelected! > index) {
      return _maxPadding / (indexSelected! - index);
    }
    if (indexSelected! == index) {
      return _maxPadding;
    }

    return 0;
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

class Gravity extends StatelessWidget {
  const Gravity({
    super.key,
    required final Widget child,
    required final double gravity,
  })  : _gravity = gravity,
        _child = child;

  final double _gravity;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: _gravity * 2),
      child: _child,
    );
  }
}
