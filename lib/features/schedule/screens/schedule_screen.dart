import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 가짜 데이터
  Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2026, 5, 9): [
      {'title': '정보처리기사 필기 시험', 'type': '시험', 'dDay': 'D-1'}
    ],
    DateTime(2026, 5, 12): [
      {'title': '코딩 테스트 대비 스터디', 'type': '스터디', 'dDay': 'D-4'}
    ],
    DateTime(2026, 5, 19): [
      {'title': '네이버 서류 마감', 'type': '일반', 'dDay': 'D-11'}
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // 일정 삭제
  void _deleteEvent(DateTime day, int index) {
    setState(() {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      _events[normalizedDay]?.removeAt(index);
      if (_events[normalizedDay]!.isEmpty) {
        _events.remove(normalizedDay);
      }
    });
  }

  // 날짜 클릭 시 나타나는 일정 확인 팝업
  void _showDayEventsPopup(DateTime day) {
    final dayEvents = _getEventsForDay(day);
    if (dayEvents.isEmpty) return; // 일정 없는 날은 팝업 안 띄움

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
              itemCount: dayEvents.length,
              itemBuilder: (context, index) {
                final event = dayEvents[index];
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
                              Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(event['type'], style: TextStyle(color: primaryColor, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            _deleteEvent(day, index);
                            Navigator.pop(context); // 삭제 후 팝업 닫기
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

  void _showAddScheduleDialog() {
    final TextEditingController titleController = TextEditingController();
    String selectedType = '일반';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final primaryColor = Theme.of(context).primaryColor;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                      Text(DateFormat('yyyy.MM.dd').format(_selectedDay!), style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: '일정 제목을 입력하세요',
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
                    children: ['일반', '시험', '스터디', '면접'].map((type) {
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
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        setState(() {
                          final day = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                          if (_events[day] != null) {
                            _events[day]!.add({'title': titleController.text, 'type': selectedType, 'dDay': 'NEW'});
                          } else {
                            _events[day] = [{'title': titleController.text, 'type': selectedType, 'dDay': 'NEW'}];
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('일정 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text('일정', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                                setState(() {
                                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                                });
                              },
                            ),
                            Text(
                              DateFormat('yyyy년 M월').format(_focusedDay),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Colors.black87),
                              onPressed: () {
                                setState(() {
                                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                                });
                              },
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _showAddScheduleDialog,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: primaryColor.withOpacity(0.6), shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TableCalendar(
                    locale: 'ko_KR',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      // 날짜 선택 시 일정이 있으면 팝업 표시
                      _showDayEventsPopup(selectedDay);
                    },
                    eventLoader: _getEventsForDay,
                    headerVisible: false,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: Colors.red),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('주요 일정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text('전체보기 >', style: TextStyle(color: Colors.grey, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _getEventsForDay(_selectedDay!).isEmpty 
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text("해당 날짜에 일정이 없습니다."))
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay!)[index];
                      return _buildScheduleItem(
                        title: event['title'],
                        date: DateFormat('yyyy-MM-dd').format(_selectedDay!),
                        dDay: event['dDay'],
                        type: event['type'],
                        typeColor: const Color(0xFFEF5350), 
                        onDelete: () => _deleteEvent(_selectedDay!, index),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required String title, 
    required String date, 
    required String dDay, 
    required String type, 
    required Color typeColor,
    required VoidCallback onDelete,
  }) {
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
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
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
                            // 💡 하단 리스트에서도 삭제 가능하도록 아이콘 추가
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                              onPressed: onDelete,
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(type, style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    child: Text(dDay, style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 15)),
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