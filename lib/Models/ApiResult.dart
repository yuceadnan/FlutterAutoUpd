class ResultModel {
  int status;
  String message;
  dynamic data;

  ResultModel({this.status, this.message, this.data});

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
        status: json['status'], message: json['message'], data: json['data']);
  }
}
