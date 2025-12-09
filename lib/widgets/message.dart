import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:notifly_frontend/colors.dart';
import 'package:notifly_frontend/models/message_model.dart';

class Message extends StatelessWidget {
  const Message({
    super.key,
    required this.msg,
    required this.isMe,
    required this.isDark,
  });

  final MessageModel msg;
  final bool isMe;
  final bool isDark;

  Map<String, dynamic>? _parseCalSpec(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.startsWith('CAL::')) return null;
    final jsonStr = trimmed.substring(5).trim();
    if (jsonStr.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Widget _buildCalendar(Map<String, dynamic> spec) {
    final now = DateTime.now();

    DateTime? start;
    DateTime? end;

    if (spec['start'] != null) {
      start = DateTime.tryParse(spec['start'].toString());
    }
    if (spec['end'] != null) {
      end = DateTime.tryParse(spec['end'].toString());
    }

    final firstDay = start ?? now.subtract(const Duration(days: 30));
    final lastDay = end ?? now.add(const Duration(days: 365));
    final focusedDay = start ?? now;

    final viewStr = (spec['view'] ?? 'month').toString().toLowerCase();
    CalendarFormat format = CalendarFormat.month;
    if (viewStr.startsWith('week')) {
      format = CalendarFormat.week;
    } else if (viewStr.startsWith('two')) {
      format = CalendarFormat.twoWeeks;
    }

    final primaryText = isDark ? Colors.white : Colors.black87;
    final accent = isDark ? pastelPeach : lightPurple;

    return TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: focusedDay,
      calendarFormat: format,
      onFormatChanged: (_) {},
      onPageChanged: (_) {},
      onDaySelected: (_, _) {},
      selectedDayPredicate: (_) => false,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left_rounded,
          size: 20,
          color: primaryText.withOpacity(0.9),
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: primaryText.withOpacity(0.9),
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: primaryText.withOpacity(0.7),
          fontSize: 11,
        ),
        weekendStyle: TextStyle(color: accent.withOpacity(0.9), fontSize: 11),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: accent.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: primaryText, fontSize: 12),
        weekendTextStyle: TextStyle(
          color: accent.withOpacity(0.95),
          fontSize: 12,
        ),
        outsideTextStyle: TextStyle(
          color: primaryText.withOpacity(0.3),
          fontSize: 11,
        ),
        rowDecoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.02)
              : Colors.black.withOpacity(0.01),
        ),
        cellMargin: const EdgeInsets.all(2),
      ),
      rowHeight: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = msg.text ?? '';
    final calSpec = _parseCalSpec(text);
    final isCal = calSpec != null;
    final hasPlainText = text.trim().isNotEmpty && !isCal;
    final imgUrl = msg.imgUrl;

    final bg = isMe
        ? lightPurple
        : isDark
        ? darkPurple.withOpacity(0.6)
        : pastelPeach;
    final fg = isDark
        ? Colors.white
        : isMe
        ? Colors.white
        : Colors.black87;
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (imgUrl != null && imgUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 260,
                      minHeight: 120,
                      minWidth: 160,
                    ),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          height: 160,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        height: 120,
                        color: Colors.black.withOpacity(0.08),
                        alignment: Alignment.center,
                        child: Text(
                          'Erro ao carregar imagem',
                          style: TextStyle(color: fg.withOpacity(0.8)),
                        ),
                      ),
                    ),
                  ),
                ),
              if ((hasPlainText || isCal) &&
                  imgUrl != null &&
                  imgUrl.isNotEmpty)
                const SizedBox(height: 8),
              if (isCal) _buildCalendar(calSpec),
              if (hasPlainText)
                Padding(
                  padding: EdgeInsets.only(top: isCal ? 8 : 0),
                  child: Text(text, style: TextStyle(color: fg, fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
