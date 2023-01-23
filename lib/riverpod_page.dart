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

class RiverpodPage extends ConsumerWidget {
  const RiverpodPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hours = ref.watch(hoursProvider);
    final minutes = ref.watch(minutesProvider);
    final seconds = ref.watch(secondsProvider);
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
                  const Center(child: SimpleClock()),
                  const SizedBox(height: 60),
                  const Text(
                    'HOURS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SimpleBar(value: hours, maxValue: 12, color: Colors.purple),
                  const SizedBox(height: 24),
                  const Text(
                    'MINUTES',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SimpleBar(value: minutes, maxValue: 60, color: Colors.teal),
                  const SizedBox(height: 24),
                  const Text(
                    'SECONDS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SimpleBar(value: seconds, maxValue: 60, color: Colors.green),
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
          ref.read(minutesProvider.notifier).state = hours;
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
