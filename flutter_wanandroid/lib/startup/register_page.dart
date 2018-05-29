import '../common/config.dart';
import '../startup/login_page.dart';
import '../model/data_model.dart';

///注册页面
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  ///GlobalKey 全局Key，使用全局Key来唯一标志widget
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String username;
  String password;
  String repassword;

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
        'username': username,
        "password": password,
        "repassword": repassword
      };

      DataModel dataModel = await HttpUtil.post(register_api, map);

      if (!mounted) return;

      ///将前面那个Progress隐藏
      Navigator.pop(context, true);

      if (dataModel.errorCode == 0) {
        ///登录成功,跳转界面

        ///SnackBar的默认展示时间是1500毫秒
        SnackBarUtil.showInSnackBar(_scaffoldKey, '注册成功，将跳转到登录界面');

        new Timer(const Duration(milliseconds: 1800), () {
          ///注册成功，将调整到登录界面
          Navigator
              .of(context)
              .pushReplacement(new MaterialPageRoute(builder: (context) {
            ///注册成功后就会跳转'登录'界面
            return new LoginPage();
          }));
        });
      } else {
        SnackBarUtil.showInSnackBar(_scaffoldKey, dataModel.errorMsg);
      }
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
    value = value.trim();
    if (value.isEmpty) return '密码不能为空';
    password = value;
    return null;
  }

  String _validateSame(String value) {
    _formWasEdited = true;
    value = value.trim();
    if (value.isEmpty) return '确认密码不能为空.';
    if (value != password) return '确认密码与前面输入不一致.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey, //这里一定要加，因为只能在布局是Scaffold的Context中使用showSnackBar()方法
      appBar: new AppBar(
        elevation: 0.0,
        title: const Text(
          "注册",
        ),
      ),
      body: new Form(
        key: _formKey,
        //是否每次在内容更改后，自动检测内容
        autovalidate: _autoValidate,

        child: new ListView(
          reverse: true,
          children: <Widget>[
            const SizedBox(
              height: 18.0,
            ),

            ///跳转注册页面
            new Container(
              height: 24.0,

              ///alignment 对齐方式
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.only(right: 24.0),
              child: new InkWell(
                child: new Text(
                  '已有账号？去登录',
                  style: new TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context)

                      ///pushReplacement替换前一个界面
                      .pushReplacement(
                          new MaterialPageRoute(builder: (context) {
                    return new LoginPage();
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
                      '注册',
                      style: new TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    onPressed: () {
                      //提交执行操作
                      _handleSubmitted(context);
                    }),
              ),
            ),

            const SizedBox(
              height: 12.0,
            ),

            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: new TextFormField(
                obscureText: _obscureText, //true代表不可见
                onSaved: (String value) {
                  repassword = value.trim();
                },
                validator: _validateSame,
                decoration: new InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: '确认密码 *',
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
              height: 12.0,
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
                  hintText: '密码 *',
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
              height: 12.0,
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
              height: 12.0,
            ),

            new SizedBox(
              height: 200.0,
              child: new Image.asset(
                'assets/logo.png',
                fit: BoxFit.scaleDown,
              ),
            ),

            //登录页面顶部图片
          ],
        ),
      ),
    );
  }
}
