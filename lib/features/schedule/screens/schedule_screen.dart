import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../repositories/schedule_repository.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final focusedDay = ref.watch(focusedDayProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final yearMonth = '${focusedDay.year}-${focusedDay.month}';

    final scheduleAsync = ref.watch(scheduleProvider(yearMonth));
    final upcomingAsync = ref.watch(upcomingScheduleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20.0,
        centerTitle: false,
        title: const Text(
          '일정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(
        context: context,
        ref: ref,
        primaryColor: primaryColor,
        focusedDay: focusedDay,
        selectedDay: selectedDay,
        schedules: scheduleAsync.value ?? [],
        yearMonth: yearMonth,
        upcomingAsync: upcomingAsync,
        isLoading: scheduleAsync.isLoading,
      ),
    );
  }

  Map<DateTime, List<dynamic>> _buildEventMap(List<dynamic> schedules) {
    final Map<DateTime, List<dynamic>> eventMap = {};
    for (final schedule in schedules) {
      final rawDate = schedule['scheduledDate'] ?? schedule['scheduled_date'];
      if (rawDate != null) {
        final date = DateTime.parse(rawDate);
        final key = DateTime(date.year, date.month, date.day);
        eventMap[key] = [...(eventMap[key] ?? []), schedule];
      }
    }
    return eventMap;
  }

  List<dynamic> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<dynamic>> eventMap,
  ) {
    return eventMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // D-Day에 따른 색상을 반환하는 공통 함수
  Color _getEventColor(dynamic rawDDay, Color primaryColor) {
    final int d = rawDDay is int ? rawDDay : int.tryParse(rawDDay?.toString() ?? '') ?? -1;
    if (d >= 0 && d <= 9) {
      return const Color(0xFFEF5350); // 0~9일: 빨간색
    } else if (d >= 10 && d <= 20) {
      return Colors.orange;           // 10~20일: 주황(노란)색
    } else if (d >= 21) {
      return primaryColor;            // 21일 이상: 메인 테마색(초록색)
    } else {
      return Colors.grey;             // 종료됨
    }
  }

  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required Color primaryColor,
    required DateTime focusedDay,
    required DateTime? selectedDay,
    required List<dynamic> schedules,
    required String yearMonth,
    required AsyncValue<List<dynamic>> upcomingAsync,
    required bool isLoading,
  }) {
    final eventMap = _buildEventMap(schedules);
    
    // 선택된 날짜의 이벤트는 팝업용으로 사용
    final selectedEvents = selectedDay != null
        ? _getEventsForDay(selectedDay, eventMap)
        : [];

    // 하단 리스트에 보여줄 '이번 달 전체 일정' (날짜순 정렬)
    final monthSchedules = [...schedules]
      ..sort((a, b) {
        final dateA = a['scheduledDate'] ?? a['scheduled_date'] ?? '';
        final dateB = b['scheduledDate'] ?? b['scheduled_date'] ?? '';
        return dateA.toString().compareTo(dateB.toString());
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캘린더 카드
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (isLoading)
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      color: primaryColor,
                      backgroundColor: Colors.grey[100],
                    ),
                  )
                else
                  const SizedBox(height: 2),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.black87,
                        ),
                        onPressed: () => ref
                            .read(focusedDayProvider.notifier)
                            .set(
                              DateTime(
                                focusedDay.year,
                                focusedDay.month - 1,
                                1,
                              ),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          DateFormat('yyyy년 M월').format(focusedDay),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.black87,
                        ),
                        onPressed: () => ref
                            .read(focusedDayProvider.notifier)
                            .set(
                              DateTime(
                                focusedDay.year,
                                focusedDay.month + 1,
                                1,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),

                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (selected, focused) {
                    ref.read(selectedDayProvider.notifier).set(selected);
                    ref.read(focusedDayProvider.notifier).set(focused);
                    final events = _getEventsForDay(selected, eventMap);
                    if (events.isNotEmpty) {
                      _showDayEventsPopup(
                        context,
                        ref,
                        selected,
                        events,
                        yearMonth,
                      );
                    }
                  },
                  eventLoader: (day) => _getEventsForDay(day, eventMap),
                  headerVisible: false,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // 최대 4개까지만 점 표시
                          children: events.take(4).map((event) {
                            final eventData = event as Map; 
                            final rawDDay = eventData['dday'] ?? eventData['dDay'] ?? eventData['d_day'];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getEventColor(rawDDay, primaryColor),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.red),
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => _showAddScheduleDialog(
                      context,
                      ref,
                      selectedDay ?? DateTime.now(),
                      yearMonth,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      minimumSize: const Size(120, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '일정 추가',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          upcomingAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (upcomingSchedules) {
              final filteredUpcoming = upcomingSchedules.where((event) {
                final rawDDay = event['dday'] ?? event['dDay'] ?? event['d_day'];
                final int d = rawDDay is int ? rawDDay : int.tryParse(rawDDay?.toString() ?? '') ?? -1;
                return d >= 0 && d <= 9; // 0~9일(빨간색) 일정만 표시
              }).toList();

              if (filteredUpcoming.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '다가오는 일정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filteredUpcoming.map(
                      (event) => _buildScheduleItem(
                        context: context,
                        ref: ref,
                        title: event['title'] ?? '',
                        date: event['scheduledDate'] ?? event['scheduled_date'] ?? '',
                        rawDDay: event['dday'] ?? event['dDay'] ?? event['d_day'],
                        type: event['scheduleType'] ?? event['schedule_type'] ?? '',
                        scheduleId: event['scheduleId'] ?? event['schedule_id'],
                        yearMonth: yearMonth,
                      ),
                    ),
                    const Divider(height: 32, color: Colors.transparent),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '이번 달 주요 일정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showAllSchedulesSheet(
                        context, ref, schedules, yearMonth, primaryColor,
                      ),
                      child: const Text(
                        '전체보기 >',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                monthSchedules.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            '이번 달 일정이 없습니다.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: monthSchedules.length,
                        itemBuilder: (context, index) {
                          final event = monthSchedules[index];
                          return _buildScheduleItem(
                            context: context,
                            ref: ref,
                            title: event['title'] ?? '',
                            date: event['scheduledDate'] ?? event['scheduled_date'] ?? '',
                            rawDDay: event['dday'] ?? event['dDay'] ?? event['d_day'],
                            type: event['scheduleType'] ?? event['schedule_type'] ?? '',
                            scheduleId: event['scheduleId'] ?? event['schedule_id'],
                            yearMonth: yearMonth,
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
    String yearMonth,
  ) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    final TextEditingController companyController = TextEditingController();
    const scheduleTypes = <String, String>{
      '서류': 'document',
      '면접': 'interview',
      '시험': 'exam',
      '기타': 'etc',
    };
    String selectedTypeLabel = '서류';

    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '새 일정 추가',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy.MM.dd').format(selectedDay),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '지원 기업',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: companyController,
                    decoration: InputDecoration(
                      hintText: '지원 기업을 입력하세요',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: '일정 제목을 입력하세요',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: memoController,
                    decoration: InputDecoration(
                      hintText: '메모',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '카테고리',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: scheduleTypes.keys.map((type) {
                      final isSelected = selectedTypeLabel == type;
                      return ChoiceChip(
                        label: Text(type),
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        selected: isSelected,
                        selectedColor: primaryColor.withOpacity(0.1),
                        backgroundColor: Colors.white,
                        showCheckmark: true,
                        checkmarkColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey[300]!,
                          ),
                        ),
                        onSelected: (selected) =>
                            setModalState(() => selectedTypeLabel = type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('제목을 입력해주세요.')),
                          );
                          return;
                        }
                        try {
                          final repository = ref.read(
                            scheduleRepositoryProvider,
                          );
                          await repository.addSchedule(
                            title: titleController.text.trim(),
                            scheduleType: scheduleTypes[selectedTypeLabel]!,
                            scheduledDate: DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDay),
                            memo: memoController.text.trim(),
                          );

                          ref.invalidate(scheduleProvider(yearMonth));
                          ref.invalidate(upcomingScheduleProvider);

                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          final message = e.toString().replaceFirst(
                            'Exception: ',
                            '',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        }
                      },
                      child: const Text(
                        '일정 저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDayEventsPopup(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    List<dynamic> events,
    String yearMonth,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final primaryColor = Theme.of(context).primaryColor;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${day.month}월 ${day.day}일 일정',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                event['scheduleType'] ??
                                    event['schedule_type'] ??
                                    '',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () async {
                            try {
                              final repository = ref.read(
                                scheduleRepositoryProvider,
                              );
                              await repository.deleteSchedule(
                                event['scheduleId'] ?? event['schedule_id'],
                              );
                              ref.invalidate(scheduleProvider(yearMonth));
                              ref.invalidate(upcomingScheduleProvider);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('삭제에 실패했어요')),
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _typeToKorean(String type) {
    return switch (type.toLowerCase()) {
      'document' => '서류',
      'interview' => '면접',
      'exam' => '시험',
      'etc' => '기타',
      _ => type,
    };
  }

  String _formatDDay(dynamic rawDDay) {
    if (rawDDay == null) return 'D-?';
    final int d = rawDDay is int ? rawDDay : int.tryParse(rawDDay.toString()) ?? 0;
    if (d == 0) return 'D-Day';
    if (d > 0) return 'D-$d';
    return '종료';
  }

  Widget _buildScheduleItem({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String date,
    required dynamic rawDDay,
    required String type,
    required dynamic scheduleId,
    required String yearMonth,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final dDayText = _formatDDay(rawDDay);
    final typeLabel = _typeToKorean(type);
    
    // 공통 함수 _getEventColor를 재사용하여 색상 적용
    final itemColor = _getEventColor(rawDDay, primaryColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 84,
            decoration: BoxDecoration(
              color: itemColor, // 동적 색상 적용
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () async {
                                try {
                                  final repository = ref.read(
                                    scheduleRepositoryProvider,
                                  );
                                  await repository.deleteSchedule(scheduleId);
                                  ref.invalidate(scheduleProvider(yearMonth));
                                  ref.invalidate(upcomingScheduleProvider);
                                } catch (e) {
                                  if (context.mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('삭제에 실패했어요'),
                                      ),
                                    );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: itemColor.withOpacity(0.1), // 동적 색상 적용
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  color: itemColor, // 동적 색상 적용
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: itemColor.withOpacity(0.5)), // 동적 색상 적용
                    ),
                    child: Text(
                      dDayText,
                      style: TextStyle(
                        color: itemColor, // 동적 색상 적용
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
  }

  void _showAllSchedulesSheet(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> schedules,
    String yearMonth,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            final sorted = [...schedules]
              ..sort((a, b) {
                final dateA = a['scheduledDate'] ?? a['scheduled_date'] ?? '';
                final dateB = b['scheduledDate'] ?? b['scheduled_date'] ?? '';
                return dateA.toString().compareTo(dateB.toString());
              });

            return Column(
              children: [
                // 핸들
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '이번 달 전체 일정 (${sorted.length}개)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: sorted.isEmpty
                      ? const Center(
                          child: Text('이번 달 일정이 없어요',
                              style: TextStyle(color: Colors.black54)),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: sorted.length,
                          itemBuilder: (context, index) {
                            final event = sorted[index];
                            return _buildScheduleItem(
                              context: context,
                              ref: ref,
                              title: event['title'] ?? '',
                              date: event['scheduledDate'] ?? event['scheduled_date'] ?? '',
                              rawDDay: event['dday'] ?? event['dDay'] ?? event['d_day'],
                              type: event['scheduleType'] ?? event['schedule_type'] ?? '',
                              scheduleId: event['scheduleId'] ?? event['schedule_id'],
                              yearMonth: yearMonth,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}