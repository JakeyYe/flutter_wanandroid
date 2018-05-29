

class Log{

  static String fixInt(int num, [int fix = 2]) {
    String str = num.toString();
    fix -= str.length;

    return '${'0' * fix}$str';
  }

  ///TODO 存在问题
  static d(StackTrace stackTrace, Object obj) {
    String st = stackTrace.toString().split('\n')[0];
    var parts = st.split('(file://');
    var source = parts[1].split(':');
    String method = parts[0].trim();
    String file = source[0];
    String line = source[1];
    DateTime time = new DateTime.now();
    print('''
        --------------------------------------------------------------------------------
        Line :$line\t\tMethod : $method
        File : file://$file
        ${fixInt(time.hour)}:${fixInt(time.minute)}:${fixInt(time.second)}.${fixInt(time.millisecond,3)}
        Msg:${obj.toString()}
        --------------------------------------------------------------------------------
        '''
    );
  }
}

