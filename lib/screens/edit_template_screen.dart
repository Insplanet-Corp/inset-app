import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

enum LayerType { text, image }

enum _Handle { tl, tr, bl, br }

// 바텀시트 결과 모델
class _TextEditResult {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight weight;
  _TextEditResult({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.weight,
  });
}

class Layer {
  final String id;
  final LayerType type;

  double x, y;
  double scale;
  double rotation;
  double w, h;

  // Text
  String? text;
  double? fontSize;
  Color? color;
  FontWeight? weight;
  TextAlign? align;

  // Image
  Uint8List? imageBytes;
  BoxFit fit;

  Layer.text({
    required this.id,
    required this.x,
    required this.y,
    this.scale = 1,
    this.rotation = 0,
    this.w = 200,
    this.h = 100,
    required this.text,
    this.fontSize = 32,
    this.color = Colors.white,
    this.weight = FontWeight.w800,
    this.align = TextAlign.center,
  })  : type = LayerType.text,
        imageBytes = null,
        fit = BoxFit.contain;

  Layer.image({
    required this.id,
    required this.x,
    required this.y,
    this.scale = 1,
    this.rotation = 0,
    this.w = 600,
    this.h = 600,
    required this.imageBytes,
    this.fit = BoxFit.cover,
  })  : type = LayerType.image,
        text = null,
        fontSize = null,
        color = null,
        weight = null,
        align = null;
}

class LayerThumb {
  final String id;
  final String name;
  final IconData icon;
  LayerThumb({required this.id, required this.name, required this.icon});
}

class EditTemplateScreen extends StatefulWidget {
  const EditTemplateScreen({super.key});

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen>
    with SingleTickerProviderStateMixin {
  // template Layer
  final List<Layer> _layers = [];
  String? _selectedLayerId;

  int _idCounter = 0;
  String _newId() => "layer_${_idCounter++}";

  final _picker = ImagePicker();

  bool _editing = false;
  late final AnimationController _wiggleCtrl;

  final GlobalKey _canvasKey = GlobalKey();
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _wiggleCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 120),
        lowerBound: -0.03,
        upperBound: 0.03);
  }

  @override
  void dispose() {
    _wiggleCtrl.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    setState(() => _editing = true);
    _wiggleCtrl.repeat(reverse: true);
  }

  void _exitEditMode() {
    setState(() => _editing = false);
    _wiggleCtrl.stop();
    _wiggleCtrl.value = 0;
  }

  void openHalfSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          maxChildSize: 0.9,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          expand: false,
          snap: true,
          snapSizes: [0.3, 0.9],
          builder: (context, scrollController) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "전체 레이어 변경",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  void _addTextLayer() {
    final id = _newId();

    final layer = Layer.text(
      id: id,
      x: 80, // 원하는 기본 위치
      y: 180,
      text: "새 텍스트",
      fontSize: 28,
      color: Colors.white,
      weight: FontWeight.w800,
      align: TextAlign.center,
    );

    setState(() {
      _layers.add(layer);
      _selectedLayerId = id; // 추가되면 선택 상태로
    });
  }

  Future<void> _saveCanvasToGallery() async {
    setState(() => _exporting = true); // 핸들/가이드 숨기기 용도
    await Future.delayed(const Duration(milliseconds: 16)); // 한 프레임 기다림

    try {
      final boundary = _canvasKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      // 해상도(원하는 만큼 올리기)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception("PNG 변환 실패");

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 갤러리에 저장
      // await Gal.putImageBytes(pngBytes);

      // 필요하면 토스트/스낵바
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("갤러리에 저장 완료!")),
        );
      }
    } catch (e) {
      if (mounted) {
        print("저장 실패: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 실패: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _addImageLayer() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95, // 용량 줄이고 싶으면 70~90
    );

    if (file == null) return; // 사용자가 취소

    final bytes = await file.readAsBytes();
    final id = _newId();

    final layer = Layer.image(
      id: id,
      x: 60, // 기본 위치
      y: 220,
      w: 600, // 기본 크기
      h: 600,
      imageBytes: bytes,
      fit: BoxFit.cover,
    );

    setState(() {
      _layers.add(layer);
      _selectedLayerId = id;
    });
  }

  Future<void> _editTextLayer(Layer layer) async {
    final controller = TextEditingController(text: layer.text ?? "");

    // 현재 레이어 값으로 초기화
    double tempSize = (layer.fontSize ?? 32).clamp(10, 80);
    Color tempColor = layer.color ?? Colors.white;
    FontWeight tempWeight = layer.weight ?? FontWeight.w800;

// 색상 프리셋
    final List<Color> presetColors = [
      Colors.white,
      Colors.black,
      Color(0xFFFF938F),
      Color(0xFFFFD54F),
      Color(0xFF4FC3F7),
      Color(0xFF81C784),
      Color(0xFFE57373),
      Color(0xFFB39DDB),
    ];

    final result = await showModalBottomSheet<_TextEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1D1E20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "텍스트 편집",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),

                  // 미리보기
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.text.isEmpty ? "미리보기" : controller.text,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tempColor,
                        fontSize: tempSize,
                        fontWeight: tempWeight,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 텍스트 입력
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => setModalState(() {}), // 미리보기 업데이트
                    decoration: InputDecoration(
                      hintText: "텍스트를 입력하세요",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2A2B2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 폰트 크기
                  Row(
                    children: [
                      const Text("크기", style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 10),
                      Text(
                        tempSize.toStringAsFixed(0),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempSize,
                    min: 10,
                    max: 80,
                    onChanged: (v) => setModalState(() => tempSize = v),
                  ),

                  // 굵기
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("굵기", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _WeightChip(
                        label: "Regular",
                        selected: tempWeight == FontWeight.w400,
                        onTap: () =>
                            setModalState(() => tempWeight = FontWeight.w400),
                      ),
                      const SizedBox(width: 8),
                      _WeightChip(
                        label: "Semi",
                        selected: tempWeight == FontWeight.w600,
                        onTap: () =>
                            setModalState(() => tempWeight = FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      _WeightChip(
                        label: "Bold",
                        selected: tempWeight == FontWeight.w800,
                        onTap: () =>
                            setModalState(() => tempWeight = FontWeight.w800),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 색상 프리셋
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("색상", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final c in presetColors)
                        _ColorDot(
                          color: c,
                          selected: tempColor.value == c.value,
                          onTap: () => setModalState(() => tempColor = c),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 적용
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _TextEditResult(
                            text: controller.text,
                            fontSize: tempSize,
                            color: tempColor,
                            weight: tempWeight,
                          ),
                        );
                      },
                      child: const Text("적용"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        layer.text = result.text;
        layer.fontSize = result.fontSize;
        layer.color = result.color;
        layer.weight = result.weight;
      });
    }
  }

  Widget _buildCanvas() {
    return RepaintBoundary(
      key: _canvasKey,
      child: GestureDetector(
        onTap: () {
          if (_editing) {
            _exitEditMode();
          }
          if (_selectedLayerId != null) {
            setState(() {
              _selectedLayerId = null;
            });
          }
        },
        child: Container(
          color: const Color(0xFF1D1E20),
          child: Center(
            child: AspectRatio(
              aspectRatio: 9 / 16, // 캔버스 비율(원하는 걸로 변경)
              child: Container(
                color: const Color(0xFF2A2B2E), // 캔버스 배경
                child: Stack(
                  children: [
                    // 레이어 렌더
                    ..._layers.map(_buildLayerWidget),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerWidget(Layer layer) {
    final selected = layer.id == _selectedLayerId;

    Widget child;

    if (layer.type == LayerType.text) {
      final fontSize = layer.fontSize ?? 32;
      final lineHeight = (fontSize * (1.1)); // style.height=1.1 기준
      final maxLines = (layer.h / lineHeight).floor().clamp(1, 10);

      child = SizedBox(
        width: layer.w,
        height: layer.h,
        child: Text(
          layer.text ?? "",
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: layer.align ?? TextAlign.center,
          style: TextStyle(
            fontSize: layer.fontSize ?? 32,
            color: layer.color ?? Colors.white,
            fontWeight: layer.weight ?? FontWeight.w800,
            height: 1.1,
          ),
        ),
      );
    } else {
      child = SizedBox(
          width: layer.w,
          height: layer.h,
          child: ClipRRect(
            child: (layer.imageBytes == null)
                ? const Center(child: Text("이미지 없음"))
                : Image.memory(layer.imageBytes!, fit: layer.fit),
          ));
    }

    return Positioned(
      left: layer.x,
      top: layer.y,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() => _selectedLayerId = layer.id);
        },
        onDoubleTap: () {
          if (layer.type == LayerType.text) {
            _editTextLayer(layer);
          }
        },
        onPanUpdate: (d) {
          setState(() {
            _selectedLayerId = layer.id;
            layer.x += d.delta.dx;
            layer.y += d.delta.dy;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (selected) ...[
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFFF4D4D), width: 2),
                    ),
                  ),
                ),
              ),
              _cornerHandle(layer, _Handle.tl),
              _cornerHandle(layer, _Handle.tr),
              _cornerHandle(layer, _Handle.bl),
              _cornerHandle(layer, _Handle.br),
            ]
          ],
        ),
      ),
    );
  }

  Widget _cornerHandle(Layer layer, _Handle h) {
    const size = 18.0;
    const offset = 9.0;

    double? left, top, right, bottom;

    switch (h) {
      case _Handle.tl:
        left = -offset;
        top = -offset;
        break;
      case _Handle.tr:
        right = -offset;
        top = -offset;
        break;
      case _Handle.bl:
        left = -offset;
        bottom = -offset;
        break;
      case _Handle.br:
        right = -offset;
        bottom = -offset;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onTap: () {
          print("doc tap");
        },
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          setState(() {
            _applyResize(layer, h, d.delta.dx, d.delta.dy);
          });
        },
        child: SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF4D4D), width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyResize(Layer layer, _Handle h, double dx, double dy) {
    const minW = 60.0;
    const minH = 40.0;

    double newW = layer.w;
    double newH = layer.h;
    double newX = layer.x;
    double newY = layer.y;

    // 가로
    if (h == _Handle.tl || h == _Handle.bl) {
      // 왼쪽 핸들: x 이동 + w 감소
      final targetW = (layer.w - dx).clamp(minW, 5000.0);
      final appliedDx = layer.w - targetW; // 실제 적용된 dx
      newX += appliedDx;
      newW = targetW;
    } else {
      // 오른쪽 핸들: w 증가
      newW = (layer.w + dx).clamp(minW, 5000.0);
    }

    // 세로
    if (h == _Handle.tl || h == _Handle.tr) {
      // 위쪽 핸들: y 이동 + h 감소
      final targetH = (layer.h - dy).clamp(minH, 5000.0);
      final appliedDy = layer.h - targetH;
      newY += appliedDy;
      newH = targetH;
    } else {
      // 아래쪽 핸들: h 증가
      newH = (layer.h + dy).clamp(minH, 5000.0);
    }

    layer.x = newX;
    layer.y = newY;
    layer.w = newW;
    layer.h = newH;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1E20),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF1D1E20),
        actions: [
          IconButton(
            onPressed: () {
              print("layer onPressed");
              openHalfSheet(context);
            },
            icon: Icon(Icons.layers_outlined),
            iconSize: 30,
          ),
          IconButton(
            onPressed: () {
              print("all out onPressed");
            },
            icon: Icon(Icons.all_out),
            iconSize: 30,
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              print("save btn action");
              _saveCanvasToGallery();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Color(0xFFFF938F)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_sharp),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    "저장",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(color: Color(0xFF1D1E20), child: _buildCanvas()),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Container(
            color: const Color(0xFF1D1E20),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 96,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is OverscrollNotification) {
                    print("오른쪽에서 오버스크롤 중: $n");
                  }
                  return false;
                },
                child: ReorderableListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  buildDefaultDragHandles: false,
                  itemCount: _layers.length + 1,
                  onReorder: (oldIndex, newIndex) {
                    // + 버튼(0번)은 reorder 제외
                    if (oldIndex == 0 || newIndex == 0) return;

                    // Reorderable 규칙: newIndex가 oldIndex보다 크면 -1
                    if (newIndex > oldIndex) newIndex -= 1;

                    setState(() {
                      final item = _layers.removeAt(oldIndex - 1);
                      _layers.insert(newIndex - 1, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        key: ValueKey("add"),
                        padding: EdgeInsets.only(right: 12),
                        child: _buildAddButton(),
                      );
                    }
                    final layer = _layers[index - 1];

                    return Padding(
                      key: ValueKey(layer.id),
                      padding: const EdgeInsets.only(right: 12),
                      child: _layerTile(layer),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _layerTile(Layer layer) {
    final icon = (layer.type == LayerType.text)
        ? Icons.text_fields_rounded
        : Icons.photo;

    final selected = _selectedLayerId == layer.id;

    return GestureDetector(
      onLongPress: _enterEditMode,
      onTap: () {
        setState(() {
          _selectedLayerId = layer.id;
        });
      },
      child: AnimatedBuilder(
        animation: _wiggleCtrl,
        builder: (context, child) {
          final angle = _editing ? _wiggleCtrl.value : 0.0;
          return Transform.rotate(
            angle: angle,
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ReorderableDragStartListener(
              enabled: _editing,
              index: _layers.indexWhere((l) => l.id == layer.id) + 1,
              child: Container(
                width: 64,
                height: 96,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Icon(
                  icon,
                  size: 50,
                  color: Color(0xFFB9B9B9),
                ),
              ),
            ),
            if (_editing)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _layers.removeWhere((l) => l.id == layer.id);
                      if (_selectedLayerId == layer.id) _selectedLayerId = null;
                    });
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildAddButton() {
    return GestureDetector(
      onTap: () {
        _addTextLayer();
      },
      onDoubleTap: () {
        _addImageLayer();
      },
      child: Container(
        width: 64,
        height: 96,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.white),
        child: Icon(
          Icons.add,
          size: 50,
          color: Color(0xFFB9B9B9),
        ),
      ),
    );
  }
}

// 컬러 선택 UI
class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

// 굵기 선택 UI
class _WeightChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WeightChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF938F) : const Color(0xFF2A2B2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white12,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
