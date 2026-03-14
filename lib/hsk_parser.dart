import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path_lib;

void main() {
  final file = File(path_lib.join("lib", "data", 'complete.json'));

  if (!file.existsSync()) {
    // ignore: avoid_print
    print("Error: complete.json not found at ${file.path}");
    return;
  }

  final jsonString = file.readAsStringSync();
  final List jsonData = json.decode(jsonString) as List;

  final List<String> hskLevels = ["new-1", "new-2", "new-3", "new-4", "new-5", "new-6"];
  
  final outputDir = Directory(path_lib.join("assets", "data", "levels"));
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  for (int i = 0; i < hskLevels.length; i++) {
    final levelName = hskLevels[i];
    final int levelNumber = i + 1;

    final List<Map<String, String>> result = [];

    for (var item in jsonData) {
      final List itemLevels = item["level"] as List;
      if (itemLevels.contains(levelName)) {
        String hanzi = item["simplified"];
        
        // Safely extract pinyin and meanings
        String pinyin = "";
        List<String> meanings = [];
        if (item["forms"] != null && item["forms"] is List) {
          for (var form in item["forms"]) {
            if (form["transcriptions"] != null && 
                form["transcriptions"]["pinyin"] != null) {
              if (pinyin.isEmpty) {
                pinyin = form["transcriptions"]["pinyin"];
              }
            }
            if (form["meanings"] != null && form["meanings"] is List) {
              for (var meaning in form["meanings"]) {
                if (!meanings.contains(meaning.toString())) {
                  meanings.add(meaning.toString());
                }
              }
            }
          }
        }

        result.add({
          "hanzi": hanzi,
          "pinyin": pinyin,
          "meanings": meanings.join(", "),
        });
      }
    }

    final levelDir = Directory(path_lib.join(outputDir.path, "level_$levelNumber"));
    if (!levelDir.existsSync()) {
      levelDir.createSync(recursive: true);
    }

    for (int j = 0; j < result.length; j += 10) {
      final chunk = result.sublist(j, j + 10 > result.length ? result.length : j + 10);
      final chunkNumber = (j ~/ 10);
      final outputFile = File(path_lib.join(levelDir.path, "chunk_$chunkNumber.json"));
      outputFile.writeAsStringSync(json.encode(chunk));
    }
    
    // Also save a metadata file to know the total number of chunks
    final metadataFile = File(path_lib.join(levelDir.path, "metadata.json"));
    metadataFile.writeAsStringSync(json.encode({
      "total_items": result.length,
      "chunk_size": 10,
      "total_chunks": (result.length / 10).ceil(),
    }));

    // ignore: avoid_print
    print("Saved ${result.length} items to ${levelDir.path} in ${(result.length / 10).ceil()} chunks");
  }
}
