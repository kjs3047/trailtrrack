import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../map/cesium_map_controller.dart';

/// 3D route-replay control panel (spec §11): play/pause, restart, progress
/// slider, speed (5/10/20×, default 20×), camera-follow toggle, and a live
/// current speed / altitude / cumulative distance.
///
/// The heavy lifting (time-dynamic marker) lives in the Cesium `route-player`
/// JS; this widget only sends bridge messages and renders progress the JS
/// reports back via REPLAY_PROGRESS.
class ReplayControls extends StatefulWidget {
  const ReplayControls({super.key, required this.controller});

  final CesiumMapController controller;

  @override
  State<ReplayControls> createState() => _ReplayControlsState();
}

class _ReplayControlsState extends State<ReplayControls> {
  bool _playing = false;
  bool _follow = true;
  int _speed = 20;
  double _fraction = 0;
  double _speedReadout = 0; // m/s
  double? _altReadout;
  double _distReadout = 0; // m
  bool _dragging = false;

  static const _speeds = [5, 10, 20];

  @override
  void initState() {
    super.initState();
    widget.controller.onReplayProgress = (p) {
      if (!mounted || _dragging) return;
      setState(() {
        _fraction = p.fraction;
        _speedReadout = p.speed;
        _altReadout = p.alt;
        _distReadout = p.distance;
      });
    };
    widget.controller.onReplayFinished = () {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _fraction = 1;
      });
    };
  }

  @override
  void dispose() {
    widget.controller.onReplayProgress = null;
    widget.controller.onReplayFinished = null;
    widget.controller.stopReplay();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      widget.controller.startReplay(speed: _speed, follow: _follow);
    } else {
      widget.controller.pauseReplay();
    }
  }

  void _restart() {
    widget.controller.stopReplay();
    setState(() {
      _fraction = 0;
      _playing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.replay),
                  tooltip: '처음부터',
                  onPressed: _restart,
                ),
                IconButton(
                  iconSize: 40,
                  color: AppColors.primary,
                  icon: Icon(
                    _playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                  tooltip: _playing ? '일시정지' : '재생',
                  onPressed: _togglePlay,
                ),
                Expanded(
                  child: Slider(
                    value: _fraction.clamp(0, 1),
                    onChangeStart: (_) => _dragging = true,
                    onChanged: (v) => setState(() => _fraction = v),
                    onChangeEnd: (v) {
                      _dragging = false;
                      widget.controller.seekReplay(v);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speed selector.
                Row(
                  children: [
                    for (final s in _speeds)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ChoiceChip(
                          label: Text('${s}x'),
                          selected: _speed == s,
                          onSelected: (_) {
                            setState(() => _speed = s);
                            widget.controller.setReplaySpeed(s);
                          },
                        ),
                      ),
                  ],
                ),
                // Camera-follow toggle.
                Row(
                  children: [
                    const Text('따라가기'),
                    Switch(
                      value: _follow,
                      onChanged: (v) {
                        setState(() => _follow = v);
                        widget.controller.setReplayFollow(v);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Readout(
                  label: '현재속도',
                  value: '${Formatters.speedKmh(_speedReadout)} km/h',
                ),
                _Readout(
                  label: '고도',
                  value: '${Formatters.altitude(_altReadout)} m',
                ),
                _Readout(
                  label: '누적거리',
                  value: '${Formatters.distanceKm(_distReadout)} km',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Space Grotesk',
          ),
        ),
      ],
    );
  }
}
