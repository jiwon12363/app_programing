import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/food_background.dart';
import '../model/receipt_image.dart';
import 'standby_screen.dart';

/// 영수증 사진을 찍거나 고른 뒤 AI 분석 화면으로 넘기는 화면.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const _sample = '''
이마트 영수증
서울우유 1L        2,800
대파 1단           1,990
삼겹살 600g        14,900
두부 300g          1,500
시금치             2,500
계란 30구          7,900
쇼핑백             100
합계               31,690
''';

  final _picker = ImagePicker();
  final _controller = TextEditingController(text: _sample);
  ReceiptImage? _image;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _image = ReceiptImage(
          bytes: bytes,
          mimeType: file.mimeType ?? _mimeTypeOf(file.name),
        );
      });
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('사진을 가져오지 못했어요: $error')));
    }
  }

  static String _mimeTypeOf(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _open(StandbyScreen screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _analyzeImage() {
    final image = _image;
    if (image == null) return;
    _open(StandbyScreen(receiptImage: image));
  }

  void _analyzeText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _open(StandbyScreen(receiptText: text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final image = _image;

    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 스캔'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: FoodBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 사진 미리보기 영역
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 280,
                  child: image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🧾', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 8),
                            Text(
                              '영수증 사진을 찍거나 골라 주세요',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        )
                      : Image.memory(image.bytes, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('카메라로 촬영'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('갤러리에서 선택'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: image == null ? null : _analyzeImage,
                child: const Text('AI로 분석하기'),
              ),
              const SizedBox(height: 20),
              // 사진 없이 시연할 때 쓰는 글자 입력
              Card(
                margin: EdgeInsets.zero,
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    '사진 없이 글자로 입력하기',
                    style: theme.textTheme.titleSmall,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '영수증 텍스트',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.primary,
                      ),
                      onPressed: _analyzeText,
                      child: const Text('글자로 분석하기'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
