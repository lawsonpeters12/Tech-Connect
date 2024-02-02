class UserInf {
  final String imagePath;
  final String name;
  final String email;
  final String major;
  final String about;
  // final bool isDarkMode;

const UserInf({
  required this.imagePath,
  required this.name,
  this.major = 'Undeclared',
  required this.email,
  required this.about,
  // required this.isDarkMode,
  });
  
  UserInf copy({
    String? imagePath,
    String? name,
    String? email,
    String? major,
    // for future password change implementation
    String? password,
    String? about
  }) => 
    UserInf(
      imagePath: imagePath ?? this.imagePath,
      email: email ?? this.email,
      name: name ?? this.name,
      major: major ?? this.major,
      about : about ?? this.about,
    );
  
  static UserInf fromJson(Map<String, dynamic> json) => UserInf(
    imagePath: json['imagePath'],
    name: json['name'],
    email: json['email'],
    major: json['major'],
    about: json['about']
  );

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'name' : name,
    'email' : email,
    'major' : major,
    'about' : about
  };

}