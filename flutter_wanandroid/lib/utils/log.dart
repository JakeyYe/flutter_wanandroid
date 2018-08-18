

class Log{

  static String fixInt(int num, [int fix = 2]) {
    String str = num.toString();
    fix -= str.length;

    return '${'0' * fix}$str';
  }

  static d(StackTrace stackTrace, Object obj) {
//    StackTrack中的第一行数据
    String st = stackTrace.toString().split('\n')[0];
//    方法和文件
    String methodAFile=st.substring('#0'.length).trim();
    String method = methodAFile.substring(0,methodAFile.indexOf(' '));
    String file = methodAFile.substring(methodAFile.indexOf('(')+1,methodAFile.indexOf(')'));
    DateTime time = new DateTime.now();
    print('''
        --------------------------------------------------------------------------------
        Method : $method
        File : file://$file
        ${fixInt(time.hour)}:${fixInt(time.minute)}:${fixInt(time.second)}.${fixInt(time.millisecond,3)}
        Msg:${obj.toString()}
        --------------------------------------------------------------------------------
        '''
    );
  }
}

