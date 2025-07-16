import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<String?> uploadImage(XFile imageFile) async {
  final String ipAddress = '192.0.0.2'; 
  final String port = '5000';

  var uri = Uri.parse('http://$ipAddress:$port/upload');
  
  try {
    final imageData = await imageFile.readAsBytes();

    var request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file', 
        imageData,
        filename: imageFile.name,
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('アップロード成功');
      final responseBody = await response.stream.bytesToString();
      final imageUrl = 'http://$ipAddress:$port$responseBody';
      
      return imageUrl;
    } else {
      print('アップロード失敗: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('アップロード中にエラーが発生: $e');
    return null;
  }
}