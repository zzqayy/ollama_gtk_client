import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

enum _MyYaruSplitButtonVariant { elevated, filled, outlined }

class MyYaruSplitButton extends StatelessWidget {
  const MyYaruSplitButton({
    super.key,
    this.items,
    this.onPressed,
    this.child,
    this.onOptionsPressed,
    this.icon,
    this.radius,
    this.menuWidth,
  }) : _variant = _MyYaruSplitButtonVariant.elevated;

  const MyYaruSplitButton.filled({
    super.key,
    this.items,
    this.onPressed,
    this.child,
    this.onOptionsPressed,
    this.icon,
    this.radius,
    this.menuWidth,
  }) : _variant = _MyYaruSplitButtonVariant.filled;

  const MyYaruSplitButton.outlined({
    super.key,
    this.items,
    this.onPressed,
    this.child,
    this.onOptionsPressed,
    this.icon,
    this.radius,
    this.menuWidth,
  }) : _variant = _MyYaruSplitButtonVariant.outlined;

  final _MyYaruSplitButtonVariant _variant;
  final void Function()? onPressed;
  final void Function()? onOptionsPressed;
  final Widget? child;
  final Widget? icon;
  final List<PopupMenuEntry<Object?>>? items;
  final double? radius;
  final double? menuWidth;

  @override
  Widget build(BuildContext context) {
    // TODO: fix common_themes to use a fixed size for buttons instead of fiddling around with padding
    // then we can rely on this size here
    const size = Size.square(36);
    const dropdownPadding = EdgeInsets.only(top: 16, bottom: 16);

    final defaultRadius = Radius.circular(radius ?? kYaruButtonRadius);

    final dropdownShape = switch (_variant) {
      _MyYaruSplitButtonVariant.outlined => NonUniformRoundedRectangleBorder(
        hideLeftSide: true,
        borderRadius: BorderRadius.all(
          defaultRadius,
        ),
      ),
      _ => RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: defaultRadius,
          bottomRight: defaultRadius,
        ),
      ),
    };

    final noPressedAndNoItemsStatus = (onOptionsPressed == null && (items?.isEmpty??true));

    onDropdownPressed(){
      if(onOptionsPressed != null) {
        onOptionsPressed!();
      }
      if(items?.isNotEmpty == true) {
        showMenu(
          context: context,
          position: _menuPosition(context),
          items: items!,
          menuPadding: EdgeInsets.symmetric(vertical: defaultRadius.x),
          constraints: menuWidth == null
              ? null
              : BoxConstraints(
            minWidth: menuWidth!,
            maxWidth: menuWidth!,
          ),
        );
      }
    }

    final mainActionShape = RoundedRectangleBorder(
      borderRadius: onDropdownPressed == null
          ? BorderRadius.all(defaultRadius)
          : BorderRadius.only(
        topLeft: defaultRadius,
        bottomLeft: defaultRadius,
      ),
    );

    final dropdownIcon = icon ?? const Icon(YaruIcons.pan_down);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (_variant) {
          _MyYaruSplitButtonVariant.elevated => ElevatedButton(
            style: ElevatedButton.styleFrom(shape: mainActionShape),
            onPressed: onPressed,
            child: child,
          ),
          _MyYaruSplitButtonVariant.filled => FilledButton(
            style: FilledButton.styleFrom(shape: mainActionShape),
            onPressed: onPressed,
            child: child,
          ),
          _MyYaruSplitButtonVariant.outlined => OutlinedButton(
            style: OutlinedButton.styleFrom(shape: mainActionShape),
            onPressed: onPressed,
            child: child,
          ),
        },
        if (!noPressedAndNoItemsStatus)
          switch (_variant) {
            _MyYaruSplitButtonVariant.elevated => ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: size,
                minimumSize: size,
                maximumSize: size,
                padding: dropdownPadding,
                shape: dropdownShape,
              ),
              onPressed: onDropdownPressed,
              child: dropdownIcon,
            ),
            _MyYaruSplitButtonVariant.filled => FilledButton(
              style: FilledButton.styleFrom(
                fixedSize: size,
                minimumSize: size,
                maximumSize: size,
                padding: dropdownPadding,
                shape: dropdownShape,
              ),
              onPressed: onDropdownPressed,
              child: dropdownIcon,
            ),
            _MyYaruSplitButtonVariant.outlined => OutlinedButton(
              style: OutlinedButton.styleFrom(
                fixedSize: size,
                minimumSize: size,
                maximumSize: size,
                padding: dropdownPadding,
                shape: dropdownShape,
              ),
              onPressed: onDropdownPressed,
              child: dropdownIcon,
            ),
          },
      ],
    );
  }

  RelativeRect _menuPosition(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    const offset = Offset.zero;

    return RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(
          box.size.bottomRight(offset),
          ancestor: overlay,
        ),
        box.localToGlobal(
          box.size.bottomRight(offset),
          ancestor: overlay,
        ),
      ),
      offset & overlay.size,
    );
  }
}
