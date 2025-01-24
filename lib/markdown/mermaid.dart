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

import "package:markdown/markdown.dart";
import "package:flutter/material.dart" hide Element;
import "package:flutter_markdown/flutter_markdown.dart";
import "mermaid_widget.dart";

class MermaidElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  MermaidElementBuilder({required this.context});

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String text = element.textContent.trim();
    if (text.isEmpty) return const SizedBox();

    return MermaidWidget(diagram: text);
  }
}

class MermaidBlockSyntax extends BlockSyntax {
  static final startPattern = RegExp(r"^```mermaid\s*$");
  static final endPattern = RegExp(r"^```\s*$");

  @override
  RegExp get pattern => RegExp(r"^```mermaid");

  @override
  bool canParse(BlockParser parser) {
    return startPattern.hasMatch(parser.current.content);
  }

  @override
  Node parse(BlockParser parser) {
    final lines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      final line = parser.current.content;
      if (endPattern.hasMatch(line)) {
        parser.advance();
        break;
      }
      lines.add(line);
      parser.advance();
    }

    final text = Element.text("mermaid", lines.join("\n").trim());
    return Element("p", [text]);
  }
}
