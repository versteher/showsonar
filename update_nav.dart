import 'dart:io';

void main() {
  final dir = Directory('lib/ui');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('router.dart')) continue;

    String content = file.readAsStringSync();
    String originalContent = content;

    content = content.replaceAll(
      RegExp(
        r"Navigator\.of\(context\)\.push\([^)]*AppPageRoute[^)]*page:\s*(?:const\s+)?SearchScreen\(\)[^)]*\)[^)]*\);",
      ),
      'context.push("/search");',
    );
    content = content.replaceAll(
      RegExp(
        r"Navigator\.of\(context\)\.push\([^)]*AppPageRoute[^)]*page:\s*(?:const\s+)?TasteProfileScreen\(\)[^)]*\)[^)]*\);",
      ),
      'context.push("/taste-profile");',
    );
    content = content.replaceAll(
      RegExp(
        r"Navigator\.of\(context\)\.push\([^)]*AppPageRoute[^)]*page:\s*(?:const\s+)?WatchHistoryScreen\(\)[^)]*\)[^)]*\);",
      ),
      'context.push("/watch-history");',
    );
    content = content.replaceAll(
      RegExp(
        r"Navigator\.of\(context\)\.push\([^)]*AppPageRoute[^)]*page:\s*(?:const\s+)?WatchlistScreen\(\)[^)]*\)[^)]*\);",
      ),
      'context.push("/watchlist");',
    );

    content = content.replaceAll(
      RegExp(
        r"Navigator\.push\([^,]+,\s*AppPageRoute[^)]*page:\s*(?:const\s+)?TasteProfileScreen\(\)[^)]*\)\);",
      ),
      'context.push("/taste-profile");',
    );
    content = content.replaceAll(
      RegExp(
        r"Navigator\.push\([^,]+,\s*AppPageRoute[^)]*page:\s*(?:const\s+)?WatchHistoryScreen\(\)[^)]*\)\);",
      ),
      'context.push("/watch-history");',
    );
    content = content.replaceAll(
      RegExp(
        r"Navigator\.push\([^,]+,\s*AppPageRoute[^)]*page:\s*(?:const\s+)?WatchlistScreen\(\)[^)]*\)\);",
      ),
      'context.push("/watchlist");',
    );

    // DetailScreen specific pushes
    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^\n,]+),\s*mediaType:\s*MediaType\.movie\.name[\s\S]*?\)[\s\S]*?\)[\s\S]*?\);",
      ),
      (m) => 'context.replace("/movie/${m[1]}");',
    );

    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^\n,]+),\s*mediaType:\s*MediaType\.tv\.name[\s\S]*?\)[\s\S]*?\)[\s\S]*?\);",
      ),
      (m) => 'context.replace("/tv/${m[1]}");',
    );

    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.of\(context\)\.push\([\s\S]*?AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^\n,]+),\s*mediaType:\s*MediaType\.movie\.name[\s\S]*?\)[\s\S]*?\)[\s\S]*?\);",
      ),
      (m) => 'context.push("/movie/${m[1]}");',
    );

    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.of\(context\)\.push\([\s\S]*?AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^\n,]+),\s*mediaType:\s*MediaType\.tv\.name[\s\S]*?\)[\s\S]*?\)[\s\S]*?\);",
      ),
      (m) => 'context.push("/tv/${m[1]}");',
    );

    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.push\(context,\s*AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^\n,]+),\s*mediaType:\s*MediaType\.movie\.name[\s\S]*?\)[\s\S]*?\)\);",
      ),
      (m) => 'context.push("/movie/${m[1]}");',
    );

    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.push\(context,\s*AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^\n,]+),\s*mediaType:\s*MediaType\.tv\.name[\s\S]*?\)[\s\S]*?\)\);",
      ),
      (m) => 'context.push("/tv/${m[1]}");',
    );

    content = content.replaceAllMapped(
      RegExp(
        r"Navigator\.of\(context\)\.push\([\s\S]*?AppPageRoute\([\s\S]*?page:\s*DetailScreen\([\s\S]*?mediaId:\s*([^,]+),\s*mediaType:\s*([^\n,)]+)[\s\S]*?\)[\s\S]*?\);",
      ),
      (m) =>
          "context.push('/${m[2].toString().replaceAll('\'', '')}/${m[1]}');",
    );

    // Pops
    content = content.replaceAll(
      RegExp(r"Navigator\.of\(context\)\.pop\(\);?"),
      'context.pop();',
    );
    content = content.replaceAll(
      RegExp(r"Navigator\.pop\(ctx\);?"),
      'context.pop();',
    );

    // Edge case replacing with capture
    content = content.replaceAllMapped(
      RegExp(r"Navigator\.pop\([^,]+,\s*([^)]+)\);?"),
      (m) => "context.pop(${m[1]});",
    );
    content = content.replaceAll(
      RegExp(r"Navigator\.pop\(context(?:,\s*null)?\);?"),
      "context.pop();",
    );

    // Can pop
    content = content.replaceAll(
      RegExp(r"Navigator\.canPop\(context\)"),
      "context.canPop()",
    );

    if (content != originalContent) {
      if (!content.contains("import 'package:go_router/go_router.dart';")) {
        content = "import 'package:go_router/go_router.dart';\n$content";
      }
      file.writeAsStringSync(content);
      // ignore: avoid_print
      print("Updated ${file.path}");
    }
  }
}
