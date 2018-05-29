import '../common/config.dart';
import '../notifications/notifications.dart';
import '../startup/register_page.dart';

///登录页面
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ///GlobalKey 全局Key，使用全局Key来唯一标志widget
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String username;
  String password;

  bool _autoValidate = false;
  bool _formWasEdited = false;

  bool _obscureText = true;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  ///处理表单的提交
  _handleSubmitted(BuildContext context) async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      ///FormState.validate()如果没有错误将会返回true
      _autoValidate = true;
      SnackBarUtil.showInSnackBar(_scaffoldKey, '填写信息有误.');
    } else {
      ///调用该方法，才会调用输入控件中的'onSave'方法
      form.save();

      showProgressDialog(context: context);

      Map map = {
        "username": username,
        "password": password,
      };

      ///TODO 这里不知为什么用户名和密码一直不对，明明是对的才对？？？
      print('post map: $map');
      await HttpUtil.post(login_api, map).then((dataModel) {
        if (!mounted) return;

        ///将前面那个Progress隐藏
        Navigator.pop(context, true);

        print(dataModel ?? 'dataModel is null');

        if (dataModel.errorCode == 0) {
          ///登录成功,跳转界面
          Navigator.of(context).pop();

          ///Notification 通知，Notification.dispatch()方法发起通知
          LoginChangeNotification notification = new LoginChangeNotification();

          ///在State<>类中的任意位置都可以获取到context对象
          notification.dispatch(context); //发起通知

        } else {
          SnackBarUtil.showInSnackBar(_scaffoldKey, dataModel.errorMsg);
        }
      });
    }
  }

  ///验证电话的有效性
  String _validateUserName(String value) {
    _formWasEdited = true;
    if (value.trim().isEmpty) return '用户名不能为空';
    return null;
  }

  ///验证密码
  String _validatePassword(String value) {
    _formWasEdited = true;
    if (value.trim().isEmpty) return '密码不能为空';
    return null;
  }

  ///new ListView(
  ///  reverse: true,
  ///  children: <Widget>[
  ///    // put your text fields here
  ///  ].reversed.toList(),
  ///),
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey, //这里一定要加，因为只能在布局是Scaffold的Context中使用showSnacker()方法
      appBar: new AppBar(
        elevation: 0.0,
        title: const Text(
          "登录",
        ),
      ),
      body: new Form(
        key: _formKey,
        //是否每次在内容更改后，自动检测内容
        autovalidate: _autoValidate,
        //拦截返回按钮事件
//        onWillPop: _warnUserAboutInvalidData,

        child: new ListView(
          reverse: true,
          children: <Widget>[
            const SizedBox(
              height: 24.0,
            ),

            ///跳转注册页面
            new Container(
              height: 24.0,

              ///alignment 对齐方式
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.only(right: 24.0),
              child: new InkWell(
                child: new Text(
                  '没有账号？去注册',
                  style: new TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context)

                      ///pushReplacement替换前一个界面
                      .pushReplacement(
                          new MaterialPageRoute(builder: (context) {
                    return new RegisterPage();
                  }));
                },
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),

            new ConstrainedBox(
              constraints: const BoxConstraints.expand(height: 48.0),
              child: new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: new RaisedButton(
                    color: Colors.blue,
                    child: new Text(
                      '登录',
                      style: new TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    onPressed: () {
                      //提交执行操作
                      _handleSubmitted(context);
                    }),
              ),
            ),

            const SizedBox(
              height: 24.0,
            ),

            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: new TextFormField(
                obscureText: _obscureText, //true代表不可见
                onSaved: (String value) {
                  password = value.trim();
                },
                validator: _validatePassword,
                decoration: new InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: '密码',
                  filled: true,
                  fillColor: Colors.transparent,

                  ///suffixIcon 尾部的icon图标
                  suffixIcon: new GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: new Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24.0,
            ),

            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: new TextFormField(
                decoration: const InputDecoration(
                  //输入控件底部的横线,border边框
                  border: const UnderlineInputBorder(),
//                          hintText:
                  labelText: '用户名 *',
                  //下面两个属性要结合使用
                  filled: true,
                  fillColor: Colors.transparent, //输入框的背景颜色
                ),
                onSaved: (String value) {
                  //保存TextFormField输入的字段
                  username = value.trim(); //保存输入数据
                },
                //validator 验证器
                validator: _validateUserName, //验证输入数据
              ),
            ),

            const SizedBox(
              height: 24.0,
            ),

            //登录页面顶部图片
            new SizedBox(
              height: 200.0,
              child: new Image.asset(
                'assets/logo.png',
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
//          ),
      ),
    );
  }
}
