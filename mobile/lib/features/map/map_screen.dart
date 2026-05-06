import 'dart:async';
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
  Set<String> _currentFilteredDriverIds = {};
  final List<yandex.MapObjectTapListener> _listeners = [];
  final Map<String, yandex_img.ImageProvider> _statusIcons = {};
  String? _selectedDriverId;
  bool _surgeActive = false;
  bool _surgeLoading = false;
  SurgeResponse? _surgeData;
  yandex.MapObjectCollection? _surgeCollection;
  final List<yandex.MapObjectTapListener> _surgeListeners = [];
  double? _surgePopupValue;
  Timer? _surgePopupTimer;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mapkit.onStart();
    _setupIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRefreshTimer());
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      if (!TickerMode.of(context)) return;
      ref.invalidate(mapDataProvider);
      ref.invalidate(filteredDriverListProvider);
    });
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
    if (_mapWindow == null || !_iconsReady) return;

    final mapObjects = _mapWindow!.map.mapObjects;
    _currentFilteredDriverIds = points.map((p) => p.driverId).toSet();

    for (final point in points) {
      final oldPoint = _driverPointsMap[point.driverId];
      _driverPointsMap[point.driverId] = point;
      if (!point.hasGps) continue;

      final icon =
          _statusIcons[point.status] ?? _statusIcons['default']!;

      if (_placemarksMap.containsKey(point.driverId)) {
        final placemark = _placemarksMap[point.driverId]!;
        placemark.geometry = yandex.Point(
          latitude: point.coordinates!.lat,
          longitude: point.coordinates!.lon,
        );
        placemark.setIcon(icon);
        if (point.driverId == _selectedDriverId) {
          final oc = oldPoint?.coordinates;
          if (oc == null ||
              oc.lat != point.coordinates!.lat ||
              oc.lon != point.coordinates!.lon) {
            _zoomToDriverWithOffset(
                point.coordinates!.lat, point.coordinates!.lon);
          }
        }
      } else {
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
    }

    _markersAdded = true;
    _updateMarkerVisibility();
  }

  void _updateMarkerVisibility() {
    for (final entry in _placemarksMap.entries) {
      final driverId = entry.key;
      final placemark = entry.value;

      if (!_currentFilteredDriverIds.contains(driverId)) {
        placemark.visible = false;
        continue;
      }

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

  Future<void> _toggleSurge() async {
    if (_surgeActive) {
      setState(() {
        _surgeActive = false;
        _surgeData = null;
      });
      _surgeCollection?.clear();
      _surgeListeners.clear();
      return;
    }
    final center = _mapWindow?.map.cameraPosition.target;
    if (center == null) return;
    setState(() => _surgeLoading = true);
    try {
      final repo = ref.read(mapRepositoryProvider);
      final surge = await repo.fetchSurge(center.latitude, center.longitude);
      if (!mounted) return;
      setState(() {
        _surgeLoading = false;
        _surgeActive = true;
        _surgeData = surge;
      });
      _drawSurgeHexagons(surge);
    } catch (_) {
      if (mounted) setState(() => _surgeLoading = false);
    }
  }

  void _showSurgePopup(double value) {
    _surgePopupTimer?.cancel();
    setState(() => _surgePopupValue = value);
    _surgePopupTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _surgePopupValue = null);
    });
  }

  void _drawSurgeHexagons(SurgeResponse data) {
    _surgeCollection?.clear();
    if (_surgeCollection == null) return;
    const hexRadius = 0.0021;
    const surgeColor = Color(0xFF9B30D0);
    if (data.features.isEmpty) return;
    final actualMin =
        data.features.map((f) => f.surgeRaw).reduce((a, b) => a < b ? a : b);
    final actualMax =
        data.features.map((f) => f.surgeRaw).reduce((a, b) => a > b ? a : b);
    final actualRange = actualMax - actualMin;

    for (final f in data.features) {
      final t = actualRange > 0
          ? ((f.surgeRaw - actualMin) / actualRange).clamp(0.0, 1.0)
          : 0.5;
      final opacity = 0.04 + 0.81 * pow(t, 2);
      final vertices = _hexagonVertices(f.lat, f.lon, hexRadius);
      final polygon = _surgeCollection!.addPolygon(
        yandex.Polygon(yandex.LinearRing(vertices), const []),
      );
      polygon.fillColor = surgeColor.withOpacity(opacity);
      polygon.strokeColor = Colors.white.withOpacity(0.25);
      polygon.strokeWidth = 1.0;
      final surgeRaw = f.surgeRaw;
      final listener = _SurgeTapListener(
        surgeRaw: surgeRaw,
        onTap: () => _showSurgePopup(surgeRaw),
      );
      _surgeListeners.add(listener);
      polygon.addTapListener(listener);
    }
  }

  List<yandex.Point> _hexagonVertices(double lat, double lon, double r) {
    final lonScale = cos(lat * pi / 180);
    return List.generate(6, (i) {
      final angle = i * 60.0 * pi / 180.0;
      return yandex.Point(
        latitude: lat + r * sin(angle),
        longitude: lon + (r / lonScale) * cos(angle),
      );
    });
  }

  void _updateDriverPosition(MapCoordinates coords) {
    if (_selectedDriverId == null) return;
    final placemark = _placemarksMap[_selectedDriverId];
    if (placemark == null) return;
    final old = placemark.geometry;
    placemark.geometry = yandex.Point(
      latitude: coords.lat,
      longitude: coords.lon,
    );
    if (old.latitude != coords.lat || old.longitude != coords.lon) {
      _zoomToDriverWithOffset(coords.lat, coords.lon);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _surgePopupTimer?.cancel();
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
              _surgeCollection =
                  mapWindow.map.mapObjects.addCollection();
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_surgeActive && _surgeData != null) ...
                      [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'x${_surgeData!.legend}',
                            style: const TextStyle(
                              fontFamily: 'Yandex Sans Text',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7B2FBE),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    _MapButton(
                      icon: HugeIcons.strokeRoundedFlash,
                      onTap: () => _toggleSurge(),
                      active: _surgeActive,
                      loading: _surgeLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ─── Surge popup ──────────────────────────────────────
          Align(
            alignment: const Alignment(0, -0.35),
            child: AnimatedOpacity(
              opacity: _surgePopupValue != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                child: _SurgePopup(value: _surgePopupValue ?? 0.0),
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
  final bool active;
  final bool loading;

  const _MapButton({
    required this.icon,
    this.onTap,
    this.active = false,
    this.loading = false,
  });

  @override
  State<_MapButton> createState() => _MapButtonState();
}

class _MapButtonState extends State<_MapButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulseAnim = Tween<double>(begin: 0.30, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_MapButton old) {
    super.didUpdateWidget(old);
    if (widget.loading && !old.loading) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.loading && old.loading) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: widget.loading ? _pulseAnim.value : 1.0,
          child: GestureDetector(
            onTap: widget.loading ? null : widget.onTap,
            onTapDown: widget.loading ? null : (_) => setState(() => _pressed = true),
            onTapUp: widget.loading ? null : (_) => setState(() => _pressed = false),
            onTapCancel: widget.loading ? null : () => setState(() => _pressed = false),
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
                  color: widget.active
                      ? const Color(0xFF7B2FBE)
                      : Colors.black87.withOpacity(_pressed ? 0.5 : 1.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Surge popup ──────────────────────────────────────────────────────────────

class _SurgePopup extends StatelessWidget {
  final double value;
  const _SurgePopup({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF9B30D0).withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B30D0).withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B30D0).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFlash,
                    size: 20,
                    color: Color(0xFF7B2FBE),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Коэффициент surge',
                    style: TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 12,
                      color: Color(0xFF9E9B98),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'x${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Yandex Sans Text',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7B2FBE),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
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

class _SurgeTapListener implements yandex.MapObjectTapListener {
  final double surgeRaw;
  final VoidCallback onTap;

  _SurgeTapListener({required this.surgeRaw, required this.onTap});

  @override
  bool onMapObjectTap(yandex.MapObject mapObject, yandex.Point point) {
    onTap();
    return true;
  }
}

