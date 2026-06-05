import 'dart:io';

void main(List<String> args) async {
  final String dartPath = Platform.executable;

  List<String> command = <String>[
    '--snapshot=../lib/bin/starter.snapshot',
    'tool/starter.dart'
  ];

  print('Start generating starter.snapshot...');
  Process result = await Process.start(dartPath, command);

  stdout.addStream(result.stdout);
  stderr.addStream(result.stderr);

  if (await result.exitCode == 0) {
    print('Generated starter.snapshot successfully!');
  } else {
    print('Failed t0 generate starter.snapshot!');
  }

  command = <String>[
    'compile',
    'aot-snapshot',
    'flutter_frontend_server/starter.dart',
    '-o',
    'flutter_frontend_server/frontend_server_aot.dart.snapshot',
  ];

  print('Start generating frontend_server_aot.dart.snapshot...');

  result = await Process.start(dartPath, command);

  stdout.addStream(result.stdout);
  stderr.addStream(result.stderr);

  if (await result.exitCode == 0) {
    print('Generated frontend_server_aot.dart.snapshot successfully!');
  } else {
    print('Failed to generate frontend_server_aot.dart.snapshot!');
  }
}
