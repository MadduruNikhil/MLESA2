from keras.models import load_model
import numpy as np
from numpy import asarray
from numpy import expand_dims
from PIL import Image
from mtcnn.mtcnn import MTCNN
import cv2
from flask import Flask,request,jsonify
import os
import base64

app = Flask(__name__)


model = load_model('./Models/facenet_keras.h5')
model.load_weights('./weights/facenet_keras_weights.h5')

filesep = os.path.sep


def extract_face(filename, required_size=(160, 160)):
    image = Image.open(filename)
    width, height = image.size
    if width != 160 and height != 160:
        image = image.convert('RGB')
        pixels = asarray(image)
        detector = MTCNN()
        results = detector.detect_faces(pixels)
        x1, y1, width, height = results[0]['box']
        x1, y1 = abs(x1), abs(y1)
        x2, y2 = x1 + width, y1 + height
        # extract the face
        face = pixels[y1:y2, x1:x2]
        # resize pixels to the model size
        image = Image.fromarray(face)
        image = image.resize(required_size)
        image.save(filename)
        return filename
    else:
        return filename


def img_to_encoding(image_path):
    filename = extract_face(image_path)
    img1 = cv2.cv2.imread(filename, 1)
    img = img1[..., ::-1]
    img = np.around(np.transpose(img, (0, 1, 2)) / 255.0, decimals=12)
    x_train = np.array([img])
    embedding = model.predict_on_batch(x_train)
    return embedding


def cal_dist(encoding1, encoding2):
    return np.linalg.norm(encoding1 - encoding2)

def saveFile(targetPath, DecodedData, UserID, directory):
    userDirectory = os.getcwd() + filesep+ "Users" + filesep + "directory" + filesep + UserID
    try:
        # creating a folder named data
        if not os.path.exists(userDirectory):
            os.makedirs(userDirectory)

            # if not created then raise error
    except OSError:
        print('Error: Creating directory of data')

    with open(userDirectory +filesep + targetPath, 'wb') as wfile:
        wfile.write(DecodedData)


def verify_Face(UserID):
    FrontPath = "Users" + filesep + "FaceData" + \
        filesep + UserID + filesep + "frontSide.jpeg"
    LeftPath = "Users" + filesep + "FaceData" + \
        filesep + UserID + filesep + "leftSide.jpeg"
    RightPath = "Users" + filesep + "FaceData" + \
        filesep + UserID + filesep + "rightSide.jpeg"
    TargetPath = "Users" + filesep + "FaceData" + \
        filesep + UserID + filesep + "verifySide.jpeg"
    extract_face(FrontPath)
    extract_face(LeftPath)
    extract_face(RightPath)
    extract_face(TargetPath)
    results = {'front': cal_dist(img_to_encoding(FrontPath), img_to_encoding(TargetPath)), 'left': cal_dist(img_to_encoding(
        LeftPath), img_to_encoding(TargetPath)), 'right': cal_dist(img_to_encoding(RightPath), img_to_encoding(TargetPath))}
    return results


@app.route('/af', methods=['GET','POST'])
def verifyFace():
    Data = request.get_json()
    UserID = Data['UserID']
    leftEncoded = Data['leftImageData']
    rightEncoded = Data['rightImageData']
    frontEncoded = Data['frontImageData']
    ToVerifyEncoded = Data['verifyImageData']
    leftDecoded = base64.b64decode(leftEncoded)
    saveFile('leftSide.jpeg', leftDecoded, UserID, 'FaceData')
    rightDecoded = base64.b64decode(rightEncoded)
    saveFile('rightSide.jpeg', rightDecoded, UserID, 'FaceData')
    frontDecoded = base64.b64decode(frontEncoded)
    saveFile('frontSide.jpeg', frontDecoded, UserID, 'FaceData')
    ToVerifyDecoded = base64.b64decode(ToVerifyEncoded)
    saveFile('verifySide.jpeg', ToVerifyDecoded, UserID, 'FaceData')
    result = verify_Face(UserID)
    return jsonify(result)

@app.route('/')
def ag():
    return f'{cal_dist(img_to_encoding("ag1.jpg"),img_to_encoding("ag1.jpg"))}'

if __name__ == '__main__':
    app.run(threaded=False, port=5000)