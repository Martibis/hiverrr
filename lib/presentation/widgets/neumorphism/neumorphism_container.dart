import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/theming_bloc/theming_bloc.dart';
import 'package:hiverrr/constants/constants.dart';

class NeumorphismContainer extends StatefulWidget {
  final bool expandable;
  final bool tapable;
  final Widget mainContent;
  final Widget expandableContent;
  final Duration tapDuration;
  final Duration expandDuration;
  final Color color;
  final BorderRadius borderRadius;
  final Function onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;

  NeumorphismContainer({
    Key? key,
    this.padding = const EdgeInsets.fromLTRB(20, 25, 20, 25),
    this.margin = const EdgeInsets.fromLTRB(25, 0, 25, 0),
    required this.color,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.tapable = false,
    this.expandable = false,
    required this.mainContent,
    required this.expandableContent,
    this.tapDuration = const Duration(milliseconds: 100),
    this.expandDuration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  _NeumorphismContainerState createState() => _NeumorphismContainerState();
}

class _NeumorphismContainerState extends State<NeumorphismContainer> {
  ExpandableController expandableController = ExpandableController();
  bool currentlyTapped = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      onTapDown: widget.tapable
          ? (details) {
              setState(() {
                currentlyTapped = true;
              });
            }
          : null,
      onTapCancel: () {
        setState(() {
          currentlyTapped = false;
        });
      },
      onTapUp: widget.tapable
          ? (details) async {
              currentlyTapped = false;
              if (widget.expandable) {
                await Future.delayed(widget.tapDuration);
                expandableController.expanded = !expandableController.expanded;
              }
              setState(() {});
            }
          : null,
      child: AnimatedContainer(
        margin: widget.margin,
        decoration: BoxDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius,
            boxShadow: currentlyTapped
                ? null
                : BlocProvider.of<ThemingBloc>(context).light
                    ? myBoxShadows.lightShadow
                    : myBoxShadows.darkShadow),
        padding: widget.padding,
        duration: widget.tapDuration,
        child: widget.expandable
            ? Expandable(
                controller: expandableController,
                collapsed: widget.mainContent,
                expanded: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [widget.mainContent, widget.expandableContent]),
              )
            : widget.mainContent,
      ),
    );
  }
}
