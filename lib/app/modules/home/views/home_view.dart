import 'package:flutter/widgets.dart';

import '../widgets/contact_view.dart';

class HomeList {
  HomeList({
    this.imagePath = '',
    this.title
  });

  String imagePath;
  String title;

  static List<HomeList> homeList = [
    HomeList(
        imagePath: 'assets/img/240_F_142999858_7EZ3JksoU3f4zly0MuY3uqoxhKdUwN5u.jpeg',
        title: 'Prendre \nRendez-Vous'
    ),
    HomeList(
        imagePath: 'assets/img/supportIcon.png',
        title: "Nous Contacter"
    ),
    HomeList(
        imagePath: 'assets/img/240_F_459165652_XG7N90pOALqtOIE6V4zC8bOkkXNGKpzv.jpeg',
        title: "Localisation"
    ),
    HomeList(
        imagePath: 'assets/img/240_F_163774420_stB9uyuZEodwTdSBaJKiybxDyl2FfqIN.jpeg',
        title: "Carte de Fidélité"
    ),
    HomeList(
        imagePath: 'assets/img/gallery2.jpeg',
        title: "Gallery"
    ),
    HomeList(
        imagePath: 'assets/img/240_F_480329143_udbywRAkIk8LObNgwFnLhWqbOyjenXca.jpeg',
        title: "Avis Clients"
    ),
  ];
}
