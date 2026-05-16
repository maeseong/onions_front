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
    // 다가오는 일정 파이프라인
    final upcomingAsync = ref.watch(upcomingScheduleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          '일정',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('일정을 불러오지 못했어요')),
        data: (schedules) => _buildBody(context, ref, primaryColor, focusedDay, selectedDay, schedules, yearMonth, upcomingAsync),
      ),
    );
  }

  Map<DateTime, List<dynamic>> _buildEventMap(List<dynamic> schedules) {
    final Map<DateTime, List<dynamic>> eventMap = {};
    for (final schedule in schedules) {
      final date = DateTime.parse(schedule['scheduled_date']);
      final key = DateTime(date.year, date.month, date.day);
      eventMap[key] = [...(eventMap[key] ?? []), schedule];
    }
    return eventMap;
  }

  List<dynamic> _getEventsForDay(DateTime day, Map<DateTime, List<dynamic>> eventMap) {
    return eventMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

Widget _buildBody(
    BuildContext context, 
    WidgetRef ref, 
    Color primaryColor, 
    DateTime focusedDay, 
    DateTime? selectedDay, 
    List<dynamic> schedules, 
    String yearMonth,
    AsyncValue<List<dynamic>> upcomingAsync,
  ) {
    final eventMap = _buildEventMap(schedules);
    final selectedEvents = selectedDay != null ? _getEventsForDay(selectedDay, eventMap) : [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캘린더 카드
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                // 캘린더 헤더
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.black87),
                            onPressed: () {
                              ref.read(focusedDayProvider.notifier).set(DateTime(focusedDay.year, focusedDay.month - 1, 1));
                            },
                          ),
                          Text(DateFormat('yyyy년 M월').format(focusedDay), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.black87),
                            onPressed: () {
                              ref.read(focusedDayProvider.notifier).set(DateTime(focusedDay.year, focusedDay.month + 1, 1));
                            },
                          ),
                        ],
                      ),
                      // + 버튼
                      InkWell(
                        onTap: () => _showAddScheduleDialog(context, ref, selectedDay ?? DateTime.now(), yearMonth),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),

                // 캘린더
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
                      _showDayEventsPopup(context, ref, selected, events, yearMonth);
                    }
                  },
                  eventLoader: (day) => _getEventsForDay(day, eventMap),
                  headerVisible: false,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    markerDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(weekendStyle: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),

          // 다가오는 일정 섹션
          upcomingAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (upcomingSchedules) {
              if (upcomingSchedules.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('다가오는 일정 🚨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...upcomingSchedules.map((event) => _buildScheduleItem(
                      context: context,
                      ref: ref,
                      title: event['title'] ?? '',
                      date: event['scheduled_date'] ?? '',
                      dDay: 'D-${event['d_day'] ?? '?'}',
                      type: event['schedule_type'] ?? '',
                      scheduleId: event['schedule_id'],
                      yearMonth: yearMonth,
                    )).toList(),
                    const Divider(height: 32, color: Colors.transparent),
                  ],
                ),
              );
            },
          ),

          // 선택된 날짜 일정 리스트 (주요 일정)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('주요 일정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('전체보기 >', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                selectedEvents.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40), 
                        child: Center(child: Text('해당 날짜에 일정이 없습니다.', style: TextStyle(color: Colors.grey)))
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final event = selectedEvents[index];
                          return _buildScheduleItem(
                            context: context,
                            ref: ref,
                            title: event['title'] ?? '',
                            date: event['scheduled_date'] ?? '',
                            dDay: 'D-${event['d_day'] ?? '?'}',
                            type: event['schedule_type'] ?? '',
                            scheduleId: event['schedule_id'],
                            yearMonth: yearMonth,
                          );
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref, DateTime selectedDay, String yearMonth) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    String selectedType = '기타';
    
    int? selectedCompanyId; 
    
    final List<Map<String, dynamic>> dummyCompanies = [
      {'id': 1, 'name': '카카오'},
      {'id': 2, 'name': '네이버'},
      {'id': 3, 'name': '토스'},
    ];

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
                left: 24, right: 24, top: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('새 일정 추가', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(DateFormat('yyyy.MM.dd').format(selectedDay), style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('지원 기업', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: Text('어떤 기업의 일정인가요?', style: TextStyle(color: Colors.grey[400])),
                        value: selectedCompanyId,
                        items: dummyCompanies.map((company) {
                          return DropdownMenuItem<int>(
                            value: company['id'],
                            child: Text(company['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCompanyId = value;
                          });
                        },
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: memoController,
                    decoration: InputDecoration(
                      hintText: '메모 (선택)',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: ['서류', '코딩테스트', '면접', '기타'].map((type) {
                      final isSelected = selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selected: isSelected,
                        selectedColor: primaryColor.withOpacity(0.1),
                        backgroundColor: Colors.white,
                        showCheckmark: true,
                        checkmarkColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSelected ? primaryColor : Colors.grey[300]!),
                        ),
                        onSelected: (selected) {
                          setModalState(() { selectedType = type; });
                        },
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
                          return;
                        }
                        if (selectedCompanyId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지원 기업을 선택해주세요.')));
                          return;
                        }

                        try {
                          final repository = ref.read(scheduleRepositoryProvider);
                          await repository.addSchedule(
                            title: titleController.text.trim(),
                            scheduleType: selectedType,
                            companyId: selectedCompanyId!,
                            scheduledDate: DateFormat('yyyy-MM-dd').format(selectedDay),
                            memo: memoController.text.trim().isEmpty ? null : memoController.text.trim(),
                          );
                          
                          // 일정을 추가한 뒤에는 달력 데이터뿐만 아니라 다가오는 일정도 갱신
                          ref.invalidate(scheduleProvider(yearMonth));
                          ref.invalidate(upcomingScheduleProvider);
                          
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('일정 추가에 실패했어요')),
                            );
                          }
                        }
                      },
                      child: const Text('일정 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showDayEventsPopup(BuildContext context, WidgetRef ref, DateTime day, List<dynamic> events, String yearMonth) {
    showDialog(
      context: context,
      builder: (context) {
        final primaryColor = Theme.of(context).primaryColor;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${day.month}월 ${day.day}일 일정', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
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
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(event['schedule_type'] ?? '', style: TextStyle(color: primaryColor, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () async {
                            try {
                              final repository = ref.read(scheduleRepositoryProvider);
                              await repository.deleteSchedule(event['schedule_id']);
                              ref.invalidate(scheduleProvider(yearMonth));
                              ref.invalidate(upcomingScheduleProvider); // 삭제 시에도 갱신
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제에 실패했어요')));
                              }
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

  Widget _buildScheduleItem({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String date,
    required String dDay,
    required String type,
    required dynamic scheduleId,
    required String yearMonth,
  }) {
    const typeColor = Color(0xFFEF5350);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 84,
            decoration: const BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
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
                            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                              onPressed: () async {
                                try {
                                  final repository = ref.read(scheduleRepositoryProvider);
                                  await repository.deleteSchedule(scheduleId);
                                  ref.invalidate(scheduleProvider(yearMonth));
                                  ref.invalidate(upcomingScheduleProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제에 실패했어요')));
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                type,
                                style: const TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      dDay,
                      style: const TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 15),
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
}