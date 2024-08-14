import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;
  final cloudtypeURL =
      'https://web-smartlicense-1272llwyzbyro.sel5.cloudtype.app';
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(cloudtypeURL));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool canGoBack = await _controller.canGoBack();
        // 현재 URL 가져오기
        String? currentUrl = await _controller.currentUrl();

        if (canGoBack &&
            (currentUrl == cloudtypeURL + '/PracticeMode' ||
                currentUrl == cloudtypeURL + '/TestMode')) {
          // 특정 URL에서만 모달창을 띄운다.
          bool? shouldExit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('알림'),
              content: Text('현재까지 응시한 문제들이 기록되지 않습니다.😥 정말로 뒤로 가시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // '아니오' 선택 시 false 반환
                  },
                  child: Text('아니오'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // '예' 선택 시 true 반환
                  },
                  child: Text('예'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            _controller.goBack(); // 실제로 뒤로가기
            // 뒤로간 페이지를 새로 로드
            _controller
                .loadRequest(Uri.parse(cloudtypeURL + '/CategoryChoice'));
            return false; // WillPopScope에서 기본 동작을 방지
          }
          return false; // 기본 동작 방지
        } else {
          bool? shouldExit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('앱 종료'),
              content: Text('정말로 종료하시겠어요? 😥'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // '아니오' 선택 시 false 반환
                  },
                  child: Text('아니오'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // '예' 선택 시 true 반환
                  },
                  child: Text('예'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
          return shouldExit ?? false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
