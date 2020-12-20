import os
import datetime
import base64
from flask import Flask, escape, request, jsonify
import speaker_verification_toolkit.tools as svt
import numpy as np
from numpy import asarray
from numpy import expand_dims
from PIL import Image
from mtcnn.mtcnn import MTCNN

from deepface import DeepFace


app = Flask(__name__)


def verify_Face(UserID):
    FrontPath = "Users/FaceData/" + UserID + "/frontSide.jpeg"
    LeftPath = "Users/FaceData/" + UserID + "/leftSide.jpeg"
    RightPath = "Users/FaceData/" + UserID + "/rightSide.jpeg"
    TargetPath = "Users/FaceData/" + UserID + "/verifySide.jpeg"
    extract_face(FrontPath)
    extract_face(LeftPath)
    extract_face(RightPath)
    extract_face(TargetPath)
    results = DeepFace.verify([[TargetPath, FrontPath], [TargetPath, LeftPath], [
                              TargetPath, RightPath], ], enforce_detection=False, )
    return results


def extract_face(filename, required_size=(400, 400)):
    image = Image.open(filename)
    width, height = image.size
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


def Verify_Voice(uploadedPath, VerifiedPath, UserID):
    userDirectory = './Users/VoiceData/' + UserID
    sample1 = svt.extract_mfcc_from_wav_file(
        userDirectory + uploadedPath, samplerate=22000, winlen=0.025, winstep=0.01)
    sample2 = svt.extract_mfcc_from_wav_file(
        userDirectory + VerifiedPath, samplerate=22000, winlen=0.025, winstep=0.01)
    distance = svt.compute_distance(sample1, sample2)
    return distance


def saveFile(targetPath, DecodedData, UserID, directory):
    userDirectory = os.getcwd() + f'/Users/{directory}/' + UserID
    try:
        # creating a folder named data
        if not os.path.exists(userDirectory):
            os.makedirs(userDirectory)

            # if not created then raise error
    except OSError:
        print('Error: Creating directory of data')

    with open(userDirectory + targetPath, 'wb') as wfile:
        wfile.write(DecodedData)


@app.route('/')
def HomePage():
    return 'HomePage Homies'


@app.route('/VerifyVoice', methods=["GET", "POST"])
def verifyVoice():
    Data = request.get_json()
    UserID = Data["UserID"]
    ToVerifyVoiceEncoded = Data['VoiceData']
    UploadedVoiceEncoded = Data['UploadedVoiceData']
    ToVerifyVoiceDecoded = base64.b64decode(ToVerifyVoiceEncoded)
    UploadedVoiceDecoded = base64.b64decode(UploadedVoiceEncoded)
    ToVerifyPath = f'/ToVerify.wav'
    saveFile(ToVerifyPath, ToVerifyVoiceDecoded, UserID, 'VoiceData')
    UploadedVerifyPath = f'/Uploaded.wav'
    saveFile(UploadedVerifyPath, UploadedVoiceDecoded, UserID, 'VoiceData')
    results = Verify_Voice(UploadedVerifyPath, ToVerifyPath, UserID)
    return jsonify(voiceresults=results)


@app.route('/VerifyFace', methods=['GET', 'POST'])
def verifyFace():
    Data = request.get_json()
    UserID = Data['UserID']
    leftEncoded = Data['leftImageData']
    rightEncoded = Data['rightImageData']
    frontEncoded = Data['frontImageData']
    ToVerifyEncoded = Data['verifyImageData']
    leftDecoded = base64.b64decode(leftEncoded)
    saveFile('/leftSide.jpeg', leftDecoded, UserID, 'FaceData')
    rightDecoded = base64.b64decode(rightEncoded)
    saveFile('/rightSide.jpeg', rightDecoded, UserID, 'FaceData')
    frontDecoded = base64.b64decode(frontEncoded)
    saveFile('/frontSide.jpeg', frontDecoded, UserID, 'FaceData')
    ToVerifyDecoded = base64.b64decode(ToVerifyEncoded)
    saveFile('/VerifySide.jpeg', ToVerifyDecoded, UserID, 'FaceData')
    result = verify_Face(UserID)
    return result


if __name__ == '__main__':
    app.run(debug=True)