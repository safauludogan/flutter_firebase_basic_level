import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  final String _email = "suludogan95@gmail.com";
  final String _password = "yenisifre2";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = FirebaseAuth.instance;

    //Bu yapı sürekli çalışır. Eğer kullanıcı çıkış yaparsa uygulamadan. Buraya çalıştırarak uygulamadan çıkış yapabiliriz.
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User oturum kapalı');
      } else {
        debugPrint(
            'User oturum açık ${user.email} ve email durumu ${user.emailVerified}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  createUserEmailAndPassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Text('Email Şifre Kayıt')),
            ElevatedButton(
                onPressed: () {
                  loginUserEmailAndPassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.pink),
                child: const Text('Giriş')),
            ElevatedButton(
                onPressed: () {
                  signOutUser();
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: const Text('Çıkış yap')),
            ElevatedButton(
                onPressed: () {
                  deleteUser();
                },
                style: ElevatedButton.styleFrom(primary: Colors.purple),
                child: const Text('Kullanıcıyı sil')),
            ElevatedButton(
                onPressed: () {
                  updatePassword();
                },
                style: ElevatedButton.styleFrom(primary: Colors.brown),
                child: const Text('Parola yenile')),
            ElevatedButton(
                onPressed: () {
                  updateEmail();
                },
                style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                child: const Text('Email değiştir')),
            ElevatedButton(
                onPressed: () {
                  signInWithGoogle();
                },
                style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: const Text('Google Giriş')),
          ],
        ),
      ),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var _userCretential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = _userCretential.user;

      if (!_myUser!.emailVerified) {
        _myUser.sendEmailVerification();
      }else{
        debugPrint("email onaylanmış");
      }

      debugPrint(_userCretential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailAndPassword() async {
    try {
      var _userCretential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      debugPrint(_userCretential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    await auth.signOut();
  }

  void deleteUser() async{
    if(auth.currentUser!=null) {
      await auth.currentUser!.delete();
    }else{
      debugPrint("Önce oturum açın");
    }
  }

  void updatePassword()async {
    try{
      await auth.currentUser!.updatePassword('yenisifre2');
      signOutUser();
    }on FirebaseAuthException catch(e){
      //Kullanıcı uygulamaya giriş yaptıktan sonra eğer çok fazla uygulama içerisinde vakit geçirmiş olursa
      //Kullanıcıdan tekrar giriş yapması beklenir. Bu firebase'in güvenlik sistemidir.
      //Aşağıdaki kod "requires-recent-login" firebase'in fırlatmış olduğu bir exception'dır.
      //Bu exception ile tekrar giriş yapması gerektiğini kullanıcıya hatırlatıyoruz.
      //Kullanıcı tekrar giriş yaptıktan sonra parola yenileme işlemi gerçekleştiriliyor.
      if(e.code == 'requires-recent-login'){
        var credential = EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword('yenisifre2');
        signOutUser();
        debugPrint("Şifre güncellendi");
      }
      debugPrint(e.toString());
    }
  }

  void updateEmail() async{
    try{
      await auth.currentUser!.updatePassword('suludogan95@gmail.com');
      signOutUser();
    }on FirebaseAuthException catch(e){
      //Kullanıcı uygulamaya giriş yaptıktan sonra eğer çok fazla uygulama içerisinde vakit geçirmiş olursa
      //Kullanıcıdan tekrar giriş yapması beklenir. Bu firebase'in güvenlik sistemidir.
      //Aşağıdaki kod "requires-recent-login" firebase'in fırlatmış olduğu bir exception'dır.
      //Bu exception ile tekrar giriş yapması gerektiğini kullanıcıya hatırlatıyoruz.
      //Kullanıcı tekrar giriş yaptıktan sonra email yenileme işlemi gerçekleştiriliyor.
      if(e.code == 'requires-recent-login'){
        var credential = EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword('suludogan95@gmail.com');
        signOutUser();
        debugPrint("Email güncellendi");
      }
      debugPrint(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
