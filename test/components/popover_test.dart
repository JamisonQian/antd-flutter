import 'package:antd_flutter_mobile/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AntdPopover', () {
    late AntdPopoverController controller;

    setUp(() {
      controller = AntdPopoverController();
    });

    /// 辅助方法：创建一个带有 AntdProvider 的测试 widget
    Widget wrapWithAntdProvider(Widget child) {
      return MaterialApp(
        navigatorObservers: [AntdLayer.observer],
        home: Scaffold(
          body: AntdProvider(
            builder: (BuildContext context, AntdTheme theme) {
              return Center(
                child: child,
              );
            },
          ),
        ),
      );
    }

    group('正常显示', () {
      testWidgets('should show popover when trigger tap', (tester) async {
        // 先构建并等待
        await tester.pumpWidget(
          wrapWithAntdProvider(
            AntdPopover(
              controller: controller,
              placement: AntdPlacement.bottom,
              child: const Text('Target'),
              actions: [
                AntdPopoverAction(
                  child: const Text('Action 1'),
                  onTap: (close) {},
                ),
                AntdPopoverAction(
                  child: const Text('Action 2'),
                  onTap: (close) {},
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();

        final target = find.text('Target');
        expect(target, findsOneWidget);

        // 点击 target
        controller.open();
        await tester.pump();

        // 等待弹窗动画
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // 打印当前 widget tree 用于调试
        debugDumpApp();

        // 查找弹窗内容
        final action1 = find.text('Action 1');
        final action2 = find.text('Action 2');

        expect(action1, findsOneWidget);
        expect(action2, findsOneWidget);
      });
    });

    group('边界保护', () {
      testWidgets('should flip top to bottom when target near top edge', (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(top: 20),
              viewPadding: EdgeInsets.only(top: 20),
            ),
            child: MaterialApp(
              navigatorObservers: [AntdLayer.observer],
              home: Scaffold(
                body: AntdProvider(
                  builder: (BuildContext context, AntdTheme theme) {
                    return Stack(
                      children: [
                        Positioned(
                          top: 30,
                          left: 100,
                          child: AntdPopover(
                            placement: AntdPlacement.top,
                            enableBoundaryProtection: true,
                            boundaryPadding: 20,
                            enableAutoFlip: true,
                            child: const Text('Target'),
                            actions: [
                              AntdPopoverAction(child: const Text('Action')),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Target'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('Action'), findsOneWidget);
      });
    });


    group('自动翻转配置', () {
      testWidgets('should work with enableAutoFlip true', (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: MaterialApp(
              navigatorObservers: [AntdLayer.observer],
              home: Scaffold(
                body: AntdProvider(
                  builder: (BuildContext context, AntdTheme theme) {
                    return Stack(
                      children: [
                        Positioned(
                          top: 30,
                          left: 100,
                          child: AntdPopover(
                            placement: AntdPlacement.top,
                            enableBoundaryProtection: true,
                            boundaryPadding: 20,
                            enableAutoFlip: true,
                            child: const Text('Target'),
                            actions: [
                              AntdPopoverAction(child: const Text('Action')),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Target'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('Action'), findsOneWidget);
      });

      testWidgets('should work with enableAutoFlip false', (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: MaterialApp(
              navigatorObservers: [AntdLayer.observer],
              home: Scaffold(
                body: AntdProvider(
                  builder: (BuildContext context, AntdTheme theme) {
                    return Stack(
                      children: [
                        Positioned(
                          top: 30,
                          left: 100,
                          child: AntdPopover(
                            placement: AntdPlacement.top,
                            enableBoundaryProtection: true,
                            boundaryPadding: 20,
                            enableAutoFlip: false,
                            child: const Text('Target'),
                            actions: [
                              AntdPopoverAction(child: const Text('Action')),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Target'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('Action'), findsOneWidget);
      });
    });

    group('控制器功能', () {
      testWidgets('should open popover via controller', (tester) async {
        await tester.pumpWidget(
          wrapWithAntdProvider(
            AntdPopover(
              controller: controller,
              placement: AntdPlacement.bottom,
              child: const Text('Target'),
              actions: [
                AntdPopoverAction(child: const Text('Action 1')),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();

        controller.open();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('Action 1'), findsOneWidget);
      });

      testWidgets('should close popover via controller', (tester) async {
        await tester.pumpWidget(
          wrapWithAntdProvider(
            AntdPopover(
              controller: controller,
              placement: AntdPlacement.bottom,
              child: const Text('Target'),
              actions: [
                AntdPopoverAction(child: const Text('Action 1')),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();

        controller.open();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('Action 1'), findsOneWidget);

        controller.close();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('Action 1'), findsNothing);
      });
    });
  });
}