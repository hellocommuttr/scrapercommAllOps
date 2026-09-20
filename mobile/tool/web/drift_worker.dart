// Source of web/drift_worker.js. Compiled from this project's resolved packages so the
// worker's sqlite3 bindings always match web/sqlite3.wasm:
//
//   dart compile js -O4 tool/web/drift_worker.dart -o web/drift_worker.js
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
