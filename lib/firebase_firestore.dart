import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseFirestoreUsage extends StatelessWidget {
  FirebaseFirestoreUsage({Key? key}) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscribe = null;

  @override
  Widget build(BuildContext context) {
    //IDLer
    debugPrint(_firestore.collection('users').id);
    debugPrint(_firestore.collection('users').doc().id);

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    addDataToFirestore();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  child: const Text('Veri Ekle Add')),
              ElevatedButton(
                  onPressed: () {
                    setDataToFirestore();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  child: const Text('Veri Ekle Set')),
              ElevatedButton(
                  onPressed: () {
                    updateData();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text('Veri Güncelle')),
              ElevatedButton(
                  onPressed: () {
                    deleteData();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.orange),
                  child: const Text('Veri Sil')),
              ElevatedButton(
                  onPressed: () {
                    readDataOneTime();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  child: const Text('Veri Oku One Time')),
            ],
          ),
          Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    readDataRealTime();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.purple),
                  child: const Text('Veri Oku Real Time')),
              ElevatedButton(
                  onPressed: () {
                    stopStream();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.black),
                  child: const Text('Stream Durdur')),
              ElevatedButton(
                  onPressed: () {
                    batch();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  child: const Text('Batch Kavrami')),
              ElevatedButton(
                  onPressed: () {
                    transaction();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text('Transaction Kavrami')),
              ElevatedButton(
                  onPressed: () {
                    queryingData();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.brown),
                  child: const Text('Veri Sorgulama')),
              ElevatedButton(
                  onPressed: () {
                    cameraGalleryImageUpload();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  child: const Text('Kamera Galeri Image Upload')),
            ],
          )
        ],
      ),
    );
  }

  void addDataToFirestore() async {
    Map<String, dynamic> _addingUser = <String, dynamic>{};
    _addingUser['name'] = 'Safa';
    _addingUser['age'] = 26;
    _addingUser['isStudent'] = true;
    _addingUser['address'] = {'country': 'Turkey', 'city': 'Ankara'};
    _addingUser['colors'] =
        FieldValue.arrayUnion(['Mavi', 'Yeşil']); //Array şeklinde ekler
    _addingUser['createdAt'] =
        FieldValue.serverTimestamp(); //Datanın eklenme tarihi ekler

    await _firestore.collection('users').add(_addingUser);
  }

  void setDataToFirestore() async {
    var _newDocID = _firestore.collection('users').doc().id;

    //FieldValue.increment(1)= Her güncellemede içerideki değeri 1 arttırır
    await _firestore.doc('/users/$_newDocID').set({
      'name': 'Safa',
      'userID': _newDocID,
      'age': FieldValue.increment(-10000)
    });

    await _firestore.doc('users/tEdM712aKVTLrQR6hese').set(
        {'school': 'Erciyes Üniversitesi'},
        SetOptions(
            merge:
                true //Bu setOptions yapısını eklersek, mevcut yapıyı bozmadan yeni veri türünü ekler
            ));
  }

  void updateData() async {
    // await _firestore.doc('users/8lJ5KFcWNxIp51jHKvUL').update({
    //   'isStudent':false
    // });

    await _firestore
        .doc('users/8lJ5KFcWNxIp51jHKvUL')
        .update({'address.city': 'İstanbul'});
  }

  void deleteData() async {
    await _firestore.doc('users/8lJ5KFcWNxIp51jHKvUL').delete();
  }

  void readDataOneTime() async {
    //Bir kerelik okuma
    var _usersDocuments = await _firestore.collection('users').get();
    debugPrint(_usersDocuments.size.toString());
    debugPrint(_usersDocuments.docs.length.toString());

    for (var element in _usersDocuments.docs) {
      debugPrint("Döküman id ${element.id}");
      Map userMap = element.data();
      debugPrint(userMap['name']);
    }

    var _safaDocs = await _firestore.doc('users/rsbiaoe2if5OKoa2rgOH').get();
    debugPrint(_safaDocs.data()!['address']['city'].toString());
  }

  void readDataRealTime() async {
    ///Toplu doküman dinlemesi
    // var _userStream = _firestore.collection('users').snapshots();
    // _userSubscribe = _userStream.listen((event) {
    //   ///Dinleme sadece değiştirilen veriyi getirir
    //   // event.docChanges.forEach((element) {
    //   //   debugPrint(element.doc.data().toString());
    //   // });
    //
    //   ///Dinleme esnasında tüm veriyi getirir
    //   event.docs.forEach((element) {
    //     debugPrint(element.data().toString());
    //   });
    // });

    ///Tek doküman dinlemesi
    var _userDocStream =
        _firestore.doc('users/rsbiaoe2if5OKoa2rgOH').snapshots();
    _userSubscribe = _userDocStream.listen((event) {
      debugPrint(event.data().toString());
    });
  }

  //RealTime dinlemeyi durdurur.
  void stopStream() async {
    await _userSubscribe?.cancel();
  }

  //batch, veri tabanına veri kayıt ederken eğer eksik veri girişi
  //İnternet gitmesi veya uygulamanın çökmesi gibi durumlar olursa
  //Veri kayıt işlemini iptal eder.
  void batch() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterColRef = _firestore.collection('counter');

    ///Toplu veri ekleme
    // for (int i = 0; i < 100; i++) {
    //   var _newDoc = _counterColRef.doc();
    //   _batch.set(_newDoc, {'sayac': ++i, 'id': _newDoc.id});
    // }

    ///Toplu veri güncelleme
    // var _counterDocs = await _counterColRef.get();
    // _counterDocs.docs.forEach((element) {
    //   _batch.update(element.reference, {'createdAt' : FieldValue.serverTimestamp()});
    // });

    ///Toplu veri silme
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });

    await _batch.commit();
  }

  void transaction() async {
    await _firestore.runTransaction((transaction) async {
      //Safa'nın bakiyesini öğren
      //Safa'dan 100 lira düş
      //Ferhata 100 lira ekle

      DocumentReference<Map<String, dynamic>> safaRef =
          _firestore.doc('users/E4n5ZYVQ1ytpJuUYcDON');
      DocumentReference<Map<String, dynamic>> ferhatRef =
          _firestore.doc('users/cOjXOT4mF6buBC0xqQbn');

      var _safaSnapshop = (await transaction.get(safaRef));
      var _safaBalance = _safaSnapshop.data()!['money'];
      if (_safaBalance >= 100) {
        var _newBalance = _safaSnapshop.data()!['money'] - 100;
        transaction.update(safaRef, {'money': _newBalance});
        transaction.update(ferhatRef, {'money': FieldValue.increment(100)});
      }
    });
  }

  void queryingData() async {
    var _userRef = _firestore.collection('users').limit(
        5); //Limit koyarak veri çekme esnasında yanlızca ilk gelen veriyi göster
    var _result =
        await _userRef.where('age', isEqualTo: 30).get(); //Yaşı 30 olanı çek
    var _result2 = await _userRef
        .where('age', isNotEqualTo: 30)
        .get(); //Yaşı 30 olmayanları çek
    var _result3 = await _userRef
        .where('age', isLessThanOrEqualTo: 30)
        .get(); //Yaşı 30 ve altında olanları getir
    var _result4 = await _userRef
        .where('age', whereIn: [30, 24]).get(); //Yaşı 30 ve 24 olanları getir
    var _result5 = await _userRef
        .where('colors', arrayContains: 'Mavi')
        .get(); //Array içinde saklı olan renklerden, içinde kırmızı barındıranı getir.

    for (var user in _result5.docs) {
      // debugPrint(user.data().toString());
    }

    var _shortBy = await _userRef
        .orderBy('age', descending: true)
        .get(); //Azalan sıraya göre verileri getir.
    for (var user in _shortBy.docs) {
      //  debugPrint(user.data().toString());
    }

    var _stringSearch = await _userRef
        .orderBy('name')
        .startAt(['Safa']).endAt(['Safa' + '\uf8ff']).get(); //String arama
    for (var user in _stringSearch.docs) {
      debugPrint(user.data().toString());
    }
  }

  void cameraGalleryImageUpload() async {
    final ImagePicker _picker = ImagePicker();

    XFile? _file =  await _picker.pickImage(source: ImageSource.camera);//gallery yaparak galirden resim seçeriz
    var _profileRef = FirebaseStorage.instance.ref('users/profileImages');
    var _task = _profileRef.putFile(File(_file!.path));

    _task.whenComplete(() async {
      var _url = await _profileRef.getDownloadURL();
      _firestore.doc('users/BwHFHYATxFDfdPjnWNrT').set({
        'profilePic' : _url.toString()
      },SetOptions(merge: true));
      debugPrint(_url);
    });
  }
}
