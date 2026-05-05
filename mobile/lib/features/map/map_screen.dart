import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex;
import 'package:yandex_maps_mapkit/mapkit_factory.dart';
import 'package:yandex_maps_mapkit/yandex_map.dart';
import 'package:yandex_maps_mapkit/image.dart' as yandex_img;
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/map/data/map_repository.dart';
import 'package:mobile/features/map/domain/map_driver.dart';
import 'package:mobile/features/map/widgets/driver_list_sheet.dart';
import 'package:mobile/features/map/widgets/driver_detail_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with WidgetsBindingObserver {
  yandex.MapWindow? _mapWindow;
  String? _selectedFilter;
  bool _markersAdded = false;
  bool _iconsReady = false;
  final Map<String, yandex.PlacemarkMapObject> _placemarksMap = {};
  final Map<String, MapDriverPoint> _driverPointsMap = {};
  final List<yandex.MapObjectTapListener> _listeners = [];
  final Map<String, yandex_img.ImageProvider> _statusIcons = {};
  String? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mapkit.onStart();
    _setupIcons();
  }

  Future<void> _setupIcons() async {
    Future<yandex_img.ImageProvider> makeIcon(
        Color fill, String id) async {
      const int size = 80;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      canvas.drawCircle(
        const ui.Offset(size / 2, size / 2),
        size / 2.0,
        ui.Paint()..color = fill,
      );
      canvas.drawCircle(
        const ui.Offset(size / 2, size / 2),
        size / 7.0,
        ui.Paint()..color = const Color(0xFFFFFFFF),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size, size);
      final byteData =
          await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      return yandex_img.ImageProvider.fromImageProvider(
        MemoryImage(bytes),
        id: id,
      );
    }

    _statusIcons['free'] =
        await makeIcon(AppTheme.statusGreen, 'icon_free');
    _statusIcons['in_order'] =
        await makeIcon(AppTheme.statusOrange, 'icon_in_order');
    _statusIcons['busy'] =
        await makeIcon(const Color(0xFFFF6B3D), 'icon_busy');
    _statusIcons['default'] =
        await makeIcon(AppTheme.textSecondary, 'icon_default');

    _iconsReady = true;

    if (mounted) {
      final current = ref.read(mapDataProvider);
      current.whenData((data) => _addDriverMarkers(data.points.items));
    }
  }

  void _addDriverMarkers(List<MapDriverPoint> points) {
    if (_mapWindow == null || _markersAdded || !_iconsReady) return;

    final mapObjects = _mapWindow!.map.mapObjects;

    for (final point in points) {
      _driverPointsMap[point.driverId] = point;
      if (!point.hasGps) continue;

      final icon =
          _statusIcons[point.status] ?? _statusIcons['default']!;

      final placemark = mapObjects.addPlacemark();
      placemark
        ..geometry = yandex.Point(
          latitude: point.coordinates!.lat,
          longitude: point.coordinates!.lon,
        )
        ..setIcon(icon)
        ..setIconStyle(const yandex.IconStyle(scale: 1.0));

      _placemarksMap[point.driverId] = placemark;

      final id = point.driverId;
      final listener = _DriverTapListener(
        driverId: id,
        mapWindow: _mapWindow!,
        onTap: () => _onDriverTapById(id),
      );
      _listeners.add(listener);
      placemark.addTapListener(listener);
    }

    _markersAdded = true;
  }

  void _updateMarkerVisibility() {
    for (final entry in _placemarksMap.entries) {
      final driverId = entry.key;
      final placemark = entry.value;

      if (_selectedDriverId != null) {
        placemark.visible = driverId == _selectedDriverId;
        continue;
      }

      if (_selectedFilter == null) {
        placemark.visible = true;
        continue;
      }

      final point = _driverPointsMap[driverId];
      if (point == null) {
        placemark.visible = false;
        continue;
      }

      if (_selectedFilter == 'no_gps') {
        placemark.visible = !point.hasGps;
      } else {
        placemark.visible = point.status == _selectedFilter;
      }
    }
  }

  void _onDriverTapById(String driverId) {
    setState(() => _selectedDriverId = driverId);
    _updateMarkerVisibility();
    final point = _driverPointsMap[driverId];
    if (point?.coordinates != null && _mapWindow != null) {
      _zoomToDriverWithOffset(
          point!.coordinates!.lat, point.coordinates!.lon);
    }
  }

  void _zoomToDriverWithOffset(double lat, double lon) {
    if (_mapWindow == null) return;
    const zoom = 14.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final offsetPx = screenHeight * 0.15;
    final metersPerPx =
        156543.03392 * cos(lat * pi / 180) / pow(2.0, zoom);
    final latOffset = (offsetPx * metersPerPx) / 111111.0;
    _mapWindow!.map.moveWithAnimation(
      yandex.CameraPosition(
        yandex.Point(latitude: lat - latOffset, longitude: lon),
        zoom: zoom,
        azimuth: 0.0,
        tilt: 0.0,
      ),
      const yandex.Animation(yandex.AnimationType.Smooth, duration: 0.5),
    );
  }

  void _closeDetail() {
    setState(() => _selectedDriverId = null);
    _updateMarkerVisibility();
  }

  void _updateDriverPosition(MapCoordinates coords) {
    if (_selectedDriverId == null) return;
    final placemark = _placemarksMap[_selectedDriverId];
    if (placemark == null) return;
    placemark.geometry = yandex.Point(
      latitude: coords.lat,
      longitude: coords.lon,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapkit.onStop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        mapkit.onStart();
      case AppLifecycleState.paused:
        mapkit.onStop();
      default:
        break;
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      _selectedFilter = _selectedFilter == filter ? null : filter;
    });
    _updateMarkerVisibility();
  }

  void _zoomIn() {
    final pos = _mapWindow?.map.cameraPosition;
    if (pos == null) return;
    _mapWindow!.map.moveWithAnimation(
      yandex.CameraPosition(
        pos.target,
        zoom: pos.zoom + 1.0,
        azimuth: pos.azimuth,
        tilt: pos.tilt,
      ),
      const yandex.Animation(yandex.AnimationType.Smooth, duration: 0.3),
    );
  }

  void _zoomOut() {
    final pos = _mapWindow?.map.cameraPosition;
    if (pos == null) return;
    _mapWindow!.map.moveWithAnimation(
      yandex.CameraPosition(
        pos.target,
        zoom: pos.zoom - 1.0,
        azimuth: pos.azimuth,
        tilt: pos.tilt,
      ),
      const yandex.Animation(yandex.AnimationType.Smooth, duration: 0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(mapDataProvider);

    ref.listen<AsyncValue<MapCombinedData>>(mapDataProvider, (_, next) {
      next.whenData((data) => _addDriverMarkers(data.points.items));
    });

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (mapWindow) {
              _mapWindow = mapWindow;
              _mapWindow!.map.move(
                yandex.CameraPosition(
                  const yandex.Point(
                    latitude: 55.751225,
                    longitude: 37.629540,
                  ),
                  zoom: 10.0,
                  azimuth: 0.0,
                  tilt: 0.0,
                ),
              );
              final current = ref.read(mapDataProvider);
              current.whenData((data) => _addDriverMarkers(data.points.items));
            },
          ),
          SafeArea(
            child: dataAsync.maybeWhen(
              data: (data) => _FilterChipsRow(
                totals: data.points.totals,
                selectedFilter: _selectedFilter,
                onFilterTap: _toggleFilter,
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
          // ─── Молния ───────────────────────────────────────────
          Positioned(
            right: 16,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: _MapButton(
                  icon: HugeIcons.strokeRoundedFlash,
                  onTap: () {},
                ),
              ),
            ),
          ),
          // ─── Зум ─────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.38,
            child: Column(
              children: [
                _MapButton(
                  icon: HugeIcons.strokeRoundedAdd01,
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: HugeIcons.strokeRoundedMinusSign,
                  onTap: _zoomOut,
                ),
              ],
            ),
          ),
          if (_selectedDriverId != null)
            DriverDetailSheet(
              driverId: _selectedDriverId!,
              onPositionUpdate: _updateDriverPosition,
              onClose: _closeDetail,
            )
          else
            DriverListSheet(
              selectedFilter: _selectedFilter,
              onDriverTap: (driver) => _onDriverTapById(driver.id),
            ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final MapTotals totals;
  final String? selectedFilter;
  final void Function(String) onFilterTap;

  const _FilterChipsRow({
    required this.totals,
    required this.selectedFilter,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              count: totals.free,
              label: 'Свободно',
              color: AppTheme.statusGreen,
              isSelected: selectedFilter == 'free',
              onTap: () => onFilterTap('free'),
            ),
            const SizedBox(width: 8),
            _Chip(
              count: totals.inOrder,
              label: 'На заказе',
              color: AppTheme.statusOrange,
              isSelected: selectedFilter == 'in_order',
              onTap: () => onFilterTap('in_order'),
            ),
            const SizedBox(width: 8),
            _Chip(
              count: totals.busy,
              label: 'Занято',
              color: const Color(0xFFFF6B3D),
              isSelected: selectedFilter == 'busy',
              onTap: () => onFilterTap('busy'),
            ),
            const SizedBox(width: 8),
            _Chip(
              count: totals.noGps,
              label: 'Нет GPS',
              color: AppTheme.textSecondary,
              isSelected: selectedFilter == 'no_gps',
              onTap: () => onFilterTap('no_gps'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.count,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Кнопка управления картой ──────────────────────────────────────────

class _MapButton extends StatefulWidget {
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;

  const _MapButton({required this.icon, this.onTap});

  @override
  State<_MapButton> createState() => _MapButtonState();
}

class _MapButtonState extends State<_MapButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_pressed ? 0.55 : 0.90),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.05 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: HugeIcon(
            icon: widget.icon,
            size: 22,
            color: Colors.black87.withOpacity(_pressed ? 0.5 : 1.0),
          ),
        ),
      ),
    );
  }
}

// ─── Слушатель тапа по метке ──────────────────────────────────────────────────

class _DriverTapListener implements yandex.MapObjectTapListener {
  final String driverId;
  final yandex.MapWindow mapWindow;
  final VoidCallback? onTap;

  _DriverTapListener(
      {required this.driverId, required this.mapWindow, this.onTap});

  @override
  bool onMapObjectTap(yandex.MapObject mapObject, yandex.Point point) {
    onTap?.call();
    return true;
  }
}

