import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notifly_frontend/colors.dart';
import 'package:notifly_frontend/models/message_model.dart';
import 'package:notifly_frontend/models/task_model.dart';
import 'package:notifly_frontend/api/api_manager.dart';
import 'package:notifly_frontend/widgets/formatted_message_text.dart';
import 'package:table_calendar/table_calendar.dart';

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

  static final RegExp _calRegex = RegExp(r'CAL::(\{.*\})', dotAll: true);
  static final RegExp _imgUrlInTextRegex = RegExp(
    r'https?:\/\/\S+\.(?:png|jpe?g|gif|webp|bmp|svg)\S*',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final raw = msg.text ?? '';
    final imgUrl = msg.imgUrl;
    final parsed = _extractCalSpec(raw, imgUrl);
    final plainText = parsed.$1;
    final calSpec = parsed.$2;

    final hasText = plainText.trim().isNotEmpty;
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
              if (hasText && imgUrl != null && imgUrl.isNotEmpty)
                const SizedBox(height: 8),
              if (hasText)
                FormattedMessageText(
                  text: plainText,
                  style: TextStyle(color: fg, fontSize: 14),
                  isDark: isDark,
                ),
              if (calSpec != null) ...[
                if (hasText || imgUrl != null) const SizedBox(height: 10),
                _MessageCalendarWithTasks(spec: calSpec, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (String, _CalSpec?) _extractCalSpec(String raw, String? imgUrl) {
    String working = raw;
    _CalSpec? spec;

    final match = _calRegex.firstMatch(working);
    if (match != null) {
      final specJson = match.group(1);
      if (specJson != null) {
        spec = _parseCalSpec(specJson);
      }
      working = working.replaceRange(match.start, match.end, '');
    }

    working = working.replaceAll(_imgUrlInTextRegex, '');

    return (working.trim(), spec);
  }

  _CalSpec? _parseCalSpec(String jsonStr) {
    try {
      final Map<String, dynamic> m =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final view = (m['view'] as String?) ?? 'month';
      final startStr = m['start']?.toString();
      final endStr = m['end']?.toString();

      final now = DateTime.now();
      DateTime start = DateTime(now.year, now.month, 1);
      DateTime end = DateTime(now.year, now.month + 1, 0);

      if (startStr != null) {
        final tryStart = DateTime.tryParse(startStr);
        if (tryStart != null) start = tryStart;
      }
      if (endStr != null) {
        final tryEnd = DateTime.tryParse(endStr);
        if (tryEnd != null) end = tryEnd;
      }

      return _CalSpec(view: view, start: start, end: end);
    } catch (_) {
      return null;
    }
  }
}

class _CalSpec {
  final String view;
  final DateTime start;
  final DateTime end;

  const _CalSpec({required this.view, required this.start, required this.end});
}

class _MessageCalendarWithTasks extends StatefulWidget {
  const _MessageCalendarWithTasks({
    super.key,
    required this.spec,
    required this.isDark,
  });

  final _CalSpec spec;
  final bool isDark;

  @override
  State<_MessageCalendarWithTasks> createState() =>
      _MessageCalendarWithTasksState();
}

class _MessageCalendarWithTasksState extends State<_MessageCalendarWithTasks> {
  late final DateTime _focusedDay;
  CalendarFormat _format = CalendarFormat.month;
  Future<List<TaskModel>>? _tasksFuture;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.spec.start;
    _format = switch (widget.spec.view) {
      'week' => CalendarFormat.week,
      'twoWeeks' => CalendarFormat.twoWeeks,
      _ => CalendarFormat.month,
    };
    _tasksFuture = _loadTasks();
  }

  Future<List<TaskModel>> _loadTasks() async {
    final api = ApiManager();
    final tasks = await api.getMyTasks();
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardBg = isDark
        ? Colors.black.withOpacity(0.2)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<List<TaskModel>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? pastelPeach : lightPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Carregando suas tasks...',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white70
                              : Colors.black.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Erro ao carregar tasks',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.red[200] : Colors.red[600],
                    ),
                  ),
                );
              }
              final tasks = snapshot.data ?? const <TaskModel>[];
              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Nenhuma task nesse período.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white60
                          : Colors.black.withOpacity(0.55),
                    ),
                  ),
                );
              }

              final top = tasks.length > 3 ? tasks.take(3).toList() : tasks;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks em destaque (${tasks.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...top.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.status == 'done'
                                    ? (isDark ? green : Colors.green[600])
                                    : (isDark ? pastelPeach : strongRed),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black.withOpacity(0.75),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          TableCalendar(
            firstDay: widget.spec.start.subtract(const Duration(days: 60)),
            lastDay: widget.spec.end.add(const Duration(days: 60)),
            focusedDay: _focusedDay,
            calendarFormat: _format,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mês',
              CalendarFormat.twoWeeks: '2 sem.',
              CalendarFormat.week: 'Semana',
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? lightPurple : pastelPurple,
              ),
              formatButtonTextStyle: const TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
              titleTextStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: isDark ? pastelPeach : lightPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: isDark ? lightPurple : strongRed,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                fontSize: 11,
                color: isDark ? pastelPink : strongRed,
              ),
            ),
            selectedDayPredicate: (day) =>
                day.year == widget.spec.start.year &&
                day.month == widget.spec.start.month &&
                day.day == widget.spec.start.day,
            onFormatChanged: (f) {
              setState(() {
                _format = f;
              });
            },
            onPageChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
