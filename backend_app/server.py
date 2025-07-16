from flask import Flask, request, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

# 画像を保存するフォルダ (同じ階層にあるimagesフォルダを指定)
UPLOAD_FOLDER = 'images'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# '/upload'というURLにPOSTリクエストが来た時の処理
@app.route('/upload', methods=['POST'])
def upload_file():
    # リクエストに'file'というキーでファイルが含まれているかチェック
    if 'file' not in request.files:
        return 'ファイルがありません', 400
    
    file = request.files['file']
    
    if file.filename == '':
        return 'ファイル名がありません', 400
        
    if file:
        filename = file.filename
        # imagesフォルダにファイルを保存
        save_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(save_path)
        
        print(f"画像を保存しました: {filename}")
        
        # Flutter側に画像のパスを返す (例: /images/my_cat.png)
        return f'/{UPLOAD_FOLDER}/{filename}'

# '/images/<filename>'というURLにGETリクエストが来た時の処理
# (Image.networkで画像を表示するために必要)
@app.route('/images/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    # 外部からアクセスできるように host='0.0.0.0' を指定
    app.run(host='0.0.0.0', port=5000, debug=True)