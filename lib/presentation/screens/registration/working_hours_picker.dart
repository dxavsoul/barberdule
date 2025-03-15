import 'package:flutter/material.dart';

class WorkingHoursPicker extends StatefulWidget {
  final Map<String, dynamic> workingHours;
  final Function(Map<String, dynamic>) onChanged;

  const WorkingHoursPicker({
    Key? key,
    required this.workingHours,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<WorkingHoursPicker> createState() => _WorkingHoursPickerState();
}

class _WorkingHoursPickerState extends State<WorkingHoursPicker> {
  late Map<String, dynamic> _hours;

  @override
  void initState() {
    super.initState();
    _hours = Map<String, dynamic>.from(widget.workingHours);
  }

  Future<void> _selectTime(
    BuildContext context,
    String day,
    String type,
  ) async {
    final TimeOfDay initialTime = _parseTimeString(_hours[day][type]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _hours[day][type] = _formatTimeOfDay(picked);
        widget.onChanged(_hours);
      });
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _toggleDayOpen(String day, bool value) {
    setState(() {
      _hours[day]['isOpen'] = value;
      widget.onChanged(_hours);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDayRow('monday', 'Monday'),
        _buildDayRow('tuesday', 'Tuesday'),
        _buildDayRow('wednesday', 'Wednesday'),
        _buildDayRow('thursday', 'Thursday'),
        _buildDayRow('friday', 'Friday'),
        _buildDayRow('saturday', 'Saturday'),
        _buildDayRow('sunday', 'Sunday'),
      ],
    );
  }

  Widget _buildDayRow(String day, String dayName) {
    final isOpen = _hours[day]['isOpen'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(dayName, style: const TextStyle(fontSize: 16)),
          ),
          Switch(
            value: isOpen,
            onChanged: (value) => _toggleDayOpen(day, value),
          ),
          if (isOpen) ...[
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, day, 'open'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_hours[day]['open']),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('to'),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, day, 'close'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_hours[day]['close']),
                ),
              ),
            ),
          ] else ...[
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('Closed', textAlign: TextAlign.center),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
