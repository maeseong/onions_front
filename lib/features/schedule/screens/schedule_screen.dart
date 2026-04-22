import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// 일정 데이터 모델
class ScheduleEvent {
  final String title;
  final String tag;
  final DateTime date;
  ScheduleEvent({required this.title, required this.tag, required this.date});
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<ScheduleEvent> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // 테스트 일정 데이터
    final today = DateTime.now();
    _events = [
      ScheduleEvent(title: '정보처리기사 필기 시험', tag: '시험', date: today.add(const Duration(days: 1))),
      ScheduleEvent(title: '코딩 테스트 대비 스터디', tag: '스터디', date: today.add(const Duration(days: 4))),
      ScheduleEvent(title: '프로젝트 최종 발표', tag: '프로젝트', date: today.add(const Duration(days: 11))),
      ScheduleEvent(title: '네이버 서류 제출', tag: '채용', date: today.add(const Duration(days: 21))),
    ];
  }

  // D-Day 색상 규칙
  Color _getDDayColor(DateTime targetDate) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final diff = target.difference(today).inDays;

    if (diff <= 9) return const Color(0xFFEF5350); // 0~9일: 빨강
    if (diff <= 19) return const Color(0xFFFFB300); // 10~19일: 노랑
    return const Color(0xFF61B099); // 20일 이상: 초록
  }

  // 해당 날짜의 일정 필터링
  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  // 달력 숫자 텍스트를 그리는 기본 틀
  Widget _buildCalendarDay(DateTime day, Color color) {
    return Container(
      alignment: Alignment.center,
      child: Text('${day.day}', style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text('일정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 달력 카드 영역
            Container(
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.black87),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1)),
                          ),
                          const SizedBox(width: 12),
                          Text('${_focusedDay.year}년 ${_focusedDay.month}월', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.black87),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1)),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.8), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TableCalendar<ScheduleEvent>(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) { 
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: _getEventsForDay,
                    headerVisible: false, 
                    daysOfWeekHeight: 40,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: true, // 이전/다음 달 날짜 보이기
                    ),
                    
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) {
                        final text = ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
                        final color = day.weekday == DateTime.sunday ? const Color(0xFFEF5350) : (day.weekday == DateTime.saturday ? const Color(0xFF42A5F5) : Colors.black87);
                        return Center(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)));
                      },
                      
                      defaultBuilder: (context, day, focusedDay) {
                        Color textColor = Colors.black87; // 평일 기본색
                        if (day.weekday == DateTime.sunday) {
                          textColor = const Color(0xFFEF5350); // 일요일 빨강
                        } else if (day.weekday == DateTime.saturday) {
                          textColor = const Color(0xFF42A5F5); // 토요일 파랑
                        }
                        return _buildCalendarDay(day, textColor);
                      },
                      
                      outsideBuilder: (context, day, focusedDay) { 
                        Color textColor = Colors.grey[400]!; // 기본 회색
                        if (day.weekday == DateTime.sunday) {
                          textColor = const Color(0xFFEF5350).withOpacity(0.4);
                        } else if (day.weekday == DateTime.saturday) {
                          textColor = const Color(0xFF42A5F5).withOpacity(0.4);
                        }
                        return _buildCalendarDay(day, textColor);
                      },
                      
                      // 선택된 날짜, 오늘 날짜
                      selectedBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                          child: Center(child: Text('${day.day}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
                        );
                      },
                      
                      // 일정 마커
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return const SizedBox();
                        return Align(
                          alignment: Alignment.bottomCenter, 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.map((event) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8, left: 1.5, right: 1.5),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getDDayColor(event.date),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('주요 일정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('전체보기 >', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),

            // 주요 일정 카드 리스트 자동 생성
            ..._events.map((event) => _buildEventCard(event)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(ScheduleEvent event) {
    final Color dDayColor = _getDDayColor(event.date); 
    
    // D-Day 계산
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final target = DateTime(event.date.year, event.date.month, event.date.day);
    final diff = target.difference(today).inDays;
    final dDayText = diff == 0 ? 'D-Day' : (diff > 0 ? 'D-$diff' : 'D+${diff.abs()}');
    
    final dateString = DateFormat('yyyy-MM-dd').format(event.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: dDayColor, width: 6))),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: dDayColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(event.tag, style: TextStyle(color: dDayColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(dateString, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: dDayColor.withOpacity(0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(dDayText, style: TextStyle(color: dDayColor, fontWeight: FontWeight.bold, fontSize: 15)),
              )
            ],
          ),
        ),
      ),
    );
  }
}