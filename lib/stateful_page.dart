import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rebuild_practice/lap.dart';

class StatefulPage extends StatefulWidget {
  const StatefulPage({super.key});

  @override
  State<StatefulPage> createState() => _StatefulPageState();
}

class _StatefulPageState extends State<StatefulPage> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  final List<Lap> _recordList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rebuild Sample')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: SimpleClock(
                      onHoursChanged: (value) {
                        setState(() => _hours = value);
                      },
                      onMinutesChanged: (value) {
                        setState(() => _minutes = value);
                      },
                      onSecondsChanged: (value) {
                        setState(() => _seconds = value);
                      },
                      onSaved: (value) {
                        setState(
                          () => _recordList.add(
                            Lap(
                              value,
                              DateTime.now(),
                              _recordList.length,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'HOURS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SimpleBar(value: _hours, maxValue: 12, color: Colors.purple),
                  const SizedBox(height: 24),
                  const Text(
                    'MINUTES',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SimpleBar(value: _minutes, maxValue: 60, color: Colors.teal),
                  const SizedBox(height: 24),
                  const Text(
                    'SECONDS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SimpleBar(value: _seconds, maxValue: 60, color: Colors.green),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'LAP',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          RecordList(_recordList),
        ],
      ),
    );
  }
}

class SimpleClock extends StatefulWidget {
  const SimpleClock({
    super.key,
    required this.onSecondsChanged,
    required this.onMinutesChanged,
    required this.onHoursChanged,
    required this.onSaved,
  });

  final ValueChanged<int> onSecondsChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<Duration> onSaved;

  @override
  State<SimpleClock> createState() => _SimpleClockState();
}

class _SimpleClockState extends State<SimpleClock> {
  int _milliseconds = 0;
  int _seconds = 0;
  int _minutes = 0;
  int _hours = 0;

  @override
  void initState() {
    super.initState();

    final start = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        final millisecPassed = DateTime.now().difference(start).inMilliseconds;
        final duration = Duration(milliseconds: millisecPassed);

        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final seconds = duration.inSeconds % 60;
        final milliseconds = duration.inMilliseconds % 1000;

        if (_hours != hours) {
          setState(() => _hours = hours);
          widget.onHoursChanged(hours);
        }

        if (_minutes != minutes) {
          setState(() => _minutes = minutes);
          widget.onMinutesChanged(minutes);
        }

        if (_seconds != seconds) {
          setState(() => _seconds = seconds);
          widget.onSecondsChanged(seconds);
        }

        setState(() => _milliseconds = milliseconds);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style.copyWith(
        fontSize: 32,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_hours.toString().padLeft(2, '0')),
                const Text(':'),
                Text(_minutes.toString().padLeft(2, '0')),
                const Text(':'),
                Text(_seconds.toString().padLeft(2, '0')),
                const Text(':'),
                Text(_milliseconds.toString().padLeft(3, '0')),
              ],
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () => widget.onSaved(
              Duration(
                milliseconds: _milliseconds,
                seconds: _seconds,
                minutes: _minutes,
                hours: _hours,
              ),
            ),
            icon: const Icon(
              Icons.save,
              size: 40,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleBar extends StatelessWidget {
  const SimpleBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      final ratio = value / maxValue;
      return Container(
        height: 40,
        width: max(4, constraint.maxWidth * ratio),
        color: color,
      );
    });
  }
}

class RecordList extends StatelessWidget {
  const RecordList(this.records, {super.key});

  final List<Lap> records;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        records.reversed.map(
          (lap) {
            final hours = lap.duration.inHours;
            final minutes = lap.duration.inMinutes % 60;
            final seconds = lap.duration.inSeconds % 60;
            final milliseconds = lap.duration.inMilliseconds % 1000;

            return DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 24,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              child: ColoredBox(
                color: lap.index.isEven ? Colors.white : Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hours.toString().padLeft(2, '0')),
                          const Text(':'),
                          Text(minutes.toString().padLeft(2, '0')),
                          const Text(':'),
                          Text(seconds.toString().padLeft(2, '0')),
                          const Text(':'),
                          Text(milliseconds.toString().padLeft(3, '0')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'recorded at: ${lap.createdAt}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
