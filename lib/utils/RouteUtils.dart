import 'package:flutter/material.dart';

// Routes Pages
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/ChangeThemePage.dart';
import 'package:OpenJMU/pages/PublishPostPage.dart';
//import 'package:OpenJMU/pages/NotificationPage.dart';
import 'package:OpenJMU/pages/NotificationTest.dart';
import 'package:OpenJMU/pages/Test.dart';

class RouteUtils {
    static Map<String, WidgetBuilder> routes = {
        "/splash": (BuildContext context) => SplashPage(),
        "/login": (BuildContext context) => LoginPage(),
        "/home": (BuildContext context) => MainPage(),
        "/search": (BuildContext context) => SearchPage(),
        "/changeTheme": (BuildContext context) => ChangeThemePage(),
        "/publishPost": (BuildContext context) => PublishPostPage(),
//    "/notification": (BuildContext context, {arguments}) => NotificationPage(arguments: arguments),
        "/notificationTest": (BuildContext context) => NotificationTestPage(),
        "/test": (BuildContext context) => TestPage(),
    };
}
