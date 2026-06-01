import 'package:flutter/material.dart';

const List<Map<String, dynamic>> kTechStackGroups = [
  {
    'group': '언어',
    'items': ['Java', 'Python', 'JavaScript', 'TypeScript', 'Kotlin', 'Swift', 'C', 'C++', 'Go'],
  },
  {
    'group': '백엔드',
    'items': ['Spring Boot', 'Spring', 'Node.js', 'Django', 'FastAPI', 'Express'],
  },
  {
    'group': '프론트엔드',
    'items': ['React', 'Vue', 'Angular', 'Next.js', 'Flutter'],
  },
  {
    'group': '데이터베이스',
    'items': ['MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'Oracle'],
  },
  {
    'group': '클라우드/인프라',
    'items': ['AWS', 'GCP', 'Azure', 'Docker', 'Kubernetes', 'Linux'],
  },
  {
    'group': 'AI/데이터',
    'items': ['PyTorch', 'TensorFlow', 'Pandas', 'Spark', 'Hadoop'],
  },
];

class TechStackSelector extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const TechStackSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<TechStackSelector> createState() => _TechStackSelectorState();
}

class _TechStackSelectorState extends State<TechStackSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  void _toggle(String item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('기술 스택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        const Text('사용할 수 있는 기술을 모두 선택해주세요',
            style: TextStyle(fontSize: 12, color: Colors.black45)),
        const SizedBox(height: 12),
        ...kTechStackGroups.map((group) {
          final groupName = group['group'] as String;
          final items = group['items'] as List<String>;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(groupName,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600])),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) {
                    final isSelected = _selected.contains(item);
                    return GestureDetector(
                      onTap: () => _toggle(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '선택됨: ${_selected.join(', ')}',
            style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }
}
