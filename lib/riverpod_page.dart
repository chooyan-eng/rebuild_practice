import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rebuild_practice/lap.dart';

final hoursProvider = StateProvider((ref) => 0);
final minutesProvider = StateProvider((ref) => 0);
final secondsProvider = StateProvider((ref) => 0);
final recordListProvider = StateProvider((ref) => <Lap>[]);

class RiverpodPage extends StatelessWidget {
  const RiverpodPage({super.key});

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
                children: const [
                  SizedBox(height: 32),
                  Center(child: SimpleClock()),
                  SizedBox(height: 60),
                  Text(
                    'HOURS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  HoursBar(),
                  SizedBox(height: 24),
                  Text(
                    'MINUTES',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  MinutesBar(),
                  SizedBox(height: 24),
                  Text(
                    'SECONDS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SecondsBar(),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 20),
                  Text(
                    'LAP',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const RecordList(),
        ],
      ),
    );
  }
}

class SimpleClock extends HookConsumerWidget {
  const SimpleClock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursState = useState(0);
    final minutesState = useState(0);
    final secondsState = useState(0);
    final millisecondsState = useState(0);

    useEffect(() {
      final start = DateTime.now();
      Timer.periodic(const Duration(milliseconds: 100), (_) {
        final millisecPassed = DateTime.now().difference(start).inMilliseconds;
        final duration = Duration(milliseconds: millisecPassed);

        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final seconds = duration.inSeconds % 60;
        final milliseconds = duration.inMilliseconds % 1000;

        if (hoursState.value != hours) {
          hoursState.value = hours;
          ref.read(hoursProvider.notifier).state = hours;
        }

        if (minutesState.value != minutes) {
          minutesState.value = minutes;
          ref.read(minutesProvider.notifier).state = minutes;
        }

        if (secondsState.value != seconds) {
          secondsState.value = seconds;
          ref.read(secondsProvider.notifier).state = seconds;
        }

        millisecondsState.value = milliseconds;
      });
      return null;
    }, []);

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
                Text(hoursState.value.toString().padLeft(2, '0')),
                const Text(':'),
                Text(minutesState.value.toString().padLeft(2, '0')),
                const Text(':'),
                Text(secondsState.value.toString().padLeft(2, '0')),
                const Text(':'),
                Text(millisecondsState.value.toString().padLeft(3, '0')),
              ],
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () {
              final duration = Duration(
                milliseconds: millisecondsState.value,
                seconds: secondsState.value,
                minutes: minutesState.value,
                hours: hoursState.value,
              );

              final controller = ref.read(recordListProvider.notifier);
              controller.state = [
                ...controller.state,
                Lap(
                  duration,
                  DateTime.now(),
                  controller.state.length,
                )
              ];
            },
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

class HoursBar extends ConsumerWidget {
  const HoursBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hours = ref.watch(hoursProvider);
    return SimpleBar(value: hours, maxValue: 12, color: Colors.purple);
  }
}

class MinutesBar extends ConsumerWidget {
  const MinutesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = ref.watch(minutesProvider);
    return SimpleBar(value: minutes, maxValue: 60, color: Colors.teal);
  }
}

class SecondsBar extends ConsumerWidget {
  const SecondsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(secondsProvider);
    return SimpleBar(value: seconds, maxValue: 60, color: Colors.green);
  }
}

class RecordList extends ConsumerWidget {
  const RecordList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordListProvider);
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
