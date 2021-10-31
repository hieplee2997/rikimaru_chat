class Utils {
  static const headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };
  static const apiUrl = "http://127.0.0.1:4000/api";
  
  static checkedTypeEmpty(data) {
    if (data == "" || data == null || data == false || data == 'false') {
      return false;
    } else {
      return true;
    }
  }

}