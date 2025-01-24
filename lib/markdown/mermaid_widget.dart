// This file is part of ChatBot.
//
// ChatBot is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ChatBot is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ChatBot. If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MermaidWidget extends StatefulWidget {
  final String diagram;

  const MermaidWidget({
    super.key,
    required this.diagram,
  });

  @override
  State<MermaidWidget> createState() => _MermaidWidgetState();
}

class _MermaidWidgetState extends State<MermaidWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'showPreview') {
            _showPreview();
          }
        },
      )
      ..loadHtmlString(_generateHtml())
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );
  }

  void _showPreview() {
    // 记录当前是否是横屏
    bool isLandscape = false;
    // 保存当前的方向
    final currentOrientation = [DeviceOrientation.portraitUp];

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          final previewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadHtmlString(_generateHtml(isPreview: true))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (String url) {
                  // 预览加载完成的处理（如果需要）
                },
              ),
            );

          return WillPopScope(
            onWillPop: () async {
              // 如果是横屏状态，退出时恢复竖屏
              if (isLandscape) {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
              return true;
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: isLandscape ? null : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text('图表预览'),
              ),
              body: Stack(
                children: [
                  SafeArea(
                    left: !isLandscape,
                    right: !isLandscape,
                    top: !isLandscape,
                    bottom: !isLandscape,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Theme.of(context).colorScheme.background,
                      padding: !isLandscape ? const EdgeInsets.all(10) : EdgeInsets.zero,
                      child: WebViewWidget(controller: previewController),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          mini: isLandscape,
                          heroTag: null,
                          onPressed: () async {
                            isLandscape = !isLandscape;
                            if (isLandscape) {
                              await SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight,
                              ]);
                              await SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.immersiveSticky,
                              );
                            } else {
                              await SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                              ]);
                              await SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                              );
                            }
                            setState(() {});
                          },
                          child: const Icon(Icons.screen_rotation),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) async {
      // 确保页面关闭后恢复原始方向设置
      await SystemChrome.setPreferredOrientations(currentOrientation);
    });
  }

  String _generateHtml({bool isPreview = false}) {
    final escapedDiagram = htmlEscape.convert(widget.diagram);
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
          <script>
            mermaid.initialize({
              startOnLoad: true,
              theme: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default',
              securityLevel: 'loose',
              fontFamily: 'sans-serif',
              flowchart: {
                htmlLabels: true,
                curve: 'linear',
                defaultRenderer: 'dagre-d3',
                useMaxWidth: true
              },
              sequence: {
                diagramMarginX: 50,
                diagramMarginY: 10,
                actorMargin: 50,
                width: 150,
                height: 65,
                boxMargin: 10,
                boxTextMargin: 5,
                noteMargin: 10,
                messageMargin: 35,
                useMaxWidth: true
              },
              er: {
                useMaxWidth: true
              },
              gantt: {
                useMaxWidth: true
              },
              journey: {
                useMaxWidth: true
              }
            });

            // 确保在DOM加载完成后渲染
            document.addEventListener('DOMContentLoaded', function() {
              try {
                mermaid.contentLoaded();
              } catch (e) {
                console.error('Mermaid render error:', e);
                // 如果渲染失败，尝试重新渲染
                setTimeout(() => {
                  try {
                    mermaid.contentLoaded();
                  } catch (e) {
                    console.error('Mermaid retry render error:', e);
                  }
                }, 500);
              }
            });
          </script>
          <style>
            body { 
              margin: 0; 
              padding: 0;
              display: flex; 
              justify-content: center;
              align-items: center;
              background-color: transparent;
              min-height: 100vh;
              width: 100vw;
              overflow: hidden;
            }
            #diagram { 
              width: 100%;
              height: 100%;
              background-color: transparent;
              padding: 10px;
              box-sizing: border-box;
              cursor: ${!isPreview ? 'pointer' : 'default'};
              display: flex;
              justify-content: center;
              align-items: center;
            }
            .mermaid {
              width: 100%;
              height: 100%;
              display: flex;
              justify-content: center;
              align-items: center;
              overflow: auto;
            }
            svg {
              max-width: 100%;
              max-height: 100%;
              height: auto !important;
              width: auto !important;
            }
            @media (orientation: landscape) {
              svg {
                max-height: 100vh;
                max-width: 100vw;
                margin: 0;
              }
              body {
                padding: 0;
              }
              #diagram {
                padding: 0;
              }
              .mermaid {
                margin: 0;
              }
            }
          </style>
        </head>
        <body>
          <div id="diagram" ${!isPreview ? 'onclick="FlutterChannel.postMessage(\'showPreview\')"' : ''}>
            <div class="mermaid">
              $escapedDiagram
            </div>
          </div>
          <script>
            // 监听主题变化
            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
              mermaid.initialize({
                startOnLoad: true,
                theme: e.matches ? 'dark' : 'default',
                flowchart: {
                  htmlLabels: true,
                  curve: 'linear',
                  defaultRenderer: 'dagre-d3'
                }
              });
              // 重新渲染
              mermaid.contentLoaded();
            });
          </script>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
