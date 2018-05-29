

///WanAndroid API常量

///post 登录
const login_api='http://www.wanandroid.com/user/login';

///post 注册
const register_api='http://www.wanandroid.com/user/register';

///get 首页 banner api
const banner_api='http://www.wanandroid.com/banner/json';

///get 首页文章列表(网站中首页的最新博文),param 是页码，页码从0开始，页码拼接
const home_articles_api='http://www.wanandroid.com/article/list/{param}/json';

///get 搜索热词（大家都在搜）
const search_hotkey_api='http://www.wanandroid.com/hotkey/json';

///post 根据关键字搜索，搜索关键字以空格隔开,多个关键字，将空格换成加号
const search_api='http://www.wanandroid.com/article/query/{param}/json';

///get 体系数据
const tree_api='http://www.wanandroid.com/tree/json';

///get 体系下的文章API
const tree_article_api='http://www.wanandroid.com/article/list/{param}/json?cid={param}';

const navi_api='http://www.wanandroid.com/navi/json';

