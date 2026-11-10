import 'package:flutter/material.dart';

import 'standby_screen.dart';

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

  final _controller = TextEditingController(text: _sample);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StandbyScreen(receiptText: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영수증 스캔')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '영수증 텍스트 (OCR 연동 전 임시 입력)',
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _analyze,
              child: const Text('AI로 분석하기'),
            ),
          ],
        ),
      ),
    );
  }
}
