class UserInf {
  final String imagePath;
  final String name;
  final String email;
  final String about;
  // final bool isDarkMode;

const UserInf({
  required this.imagePath,
  required this.name,
  required this.email,
  required this.about,
  // required this.isDarkMode,
  });
  
  UserInf copy({
    String? imagePath,
    String? name,
    String? email,
    String? password,
    String? about
  }) => 
    UserInf(
      imagePath: imagePath ?? this.imagePath,
      email: email ?? this.email,
      name: name ?? this.name,
      about : about ?? this.about,
    );
  
  static UserInf fromJson(Map<String, dynamic> json) => UserInf(
    imagePath: json['imagePath'],
    name: json['name'],
    email: json['email'],
    about: json['about']
  );

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'name' : name,
    'email' : email,
    'about' : about
  };

}