
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text,
      {super.key,
      this.expandText = "展开",
      this.collapseText = "收起",
      this.expanded = false,
      this.maxLines = 2,
      this.switchExpanded});

  /// 文本内容
  final String text;

  /// 展开文字
  final String expandText;

  /// 收起文字
  final String collapseText;

  /// 是否展开
  final bool expanded;

  /// 最大行数
  final int maxLines;

  /// 切换打开
  final VoidCallback? switchExpanded;

  @override
  State<StatefulWidget> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _toggleExpanded;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if(widget.switchExpanded != null) {
      widget.switchExpanded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool expanded = widget.expanded;
    /// 展开 隐藏的文本
    final linkText = expanded ? ' ${widget.collapseText}' : ' ${widget.expandText}';

    final endSpan = TextSpan(
      text: linkText,
      recognizer: _tapGestureRecognizer,
      style: YaruTheme.of(context).theme?.textTheme.bodyMedium?.copyWith(
        color: YaruColors.of(context).link
      )
    );

    /// 三个点
    const moreSpan = TextSpan(
      text: '...',
    );

    final text = TextSpan(
      text: widget.text,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        TextPainter textPainter = TextPainter(
          text: endSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        /// 获取三个点的宽度
        textPainter.text = moreSpan;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final moreSize = textPainter.size;

        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        final position = textPainter.getPositionForOffset(Offset(
          textSize.width -
              moreSize.width -
              linkSize.width,
          textSize.height,
        ));
        final endOffset = textPainter.getOffsetBefore(position.offset);

        TextSpan textSpan;

        /// 判断原始文字在指定最大行数的时候是否超出
        bool hasMore = textPainter.didExceedMaxLines;
        if (hasMore) {
          textSpan = TextSpan(
            text: expanded
                ? widget.text
                : '${widget.text.substring(0, endOffset)}...',
            children: [endSpan],
          );
        } else {
          textSpan = text;
        }
        return SelectableText.rich(
          textSpan
        );
      },
    );
    return result;
  }

}