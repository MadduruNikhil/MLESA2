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
import cv2.cv2 as cv
import json

from keras.models import Sequential
import tensorflow as tf
from keras.preprocessing import image
from keras.preprocessing.image import ImageDataGenerator



from deepface import DeepFace



app = Flask(__name__)

filesep = os.path.sep

model = tf.keras.models.load_model('model_checkpoint.hdf5',compile=True)

def verify_Face(UserID):
    FrontPath = 'Users' + filesep + 'FaceData' + \
        filesep + UserID + filesep + 'frontSide.jpeg'
    LeftPath = 'Users' + filesep + 'FaceData' + \
        filesep + UserID + filesep + 'leftSide.jpeg'
    RightPath = 'Users' + filesep + 'FaceData' + \
        filesep + UserID + filesep + 'rightSide.jpeg'
    TargetPath = 'Users' + filesep + 'FaceData' + \
        filesep + UserID + filesep + 'verifySide.jpeg'
    if(!extract_face(FrontPath)) {
        retrun {'status':False,'Message':'Fake Upload - Front Imprint'}
    }
    if(!extract_face(LeftPath)) {
        retrun {'status':False,'Message':'Fake Upload - Left Imprint'}
    }
    if(!extract_face(RightPath)) {
        retrun {'status':False,'Message':'Fake Upload - Right Imprint'}
    }
    if(!extract_face(TargetPath)) {
        retrun {'status':False,'Message':'Fake Upload - Verify Imprint'}
    }
    results = DeepFace.verify([[TargetPath, FrontPath], [TargetPath, LeftPath], [
                              TargetPath, RightPath], ], enforce_detection=False, model_name='Facenet')
    return {'pair_1': results['pair_1']['distance'], 'pair_2': results['pair_2']['distance'], 'pair_3': resul
            ts['pair_3']['distance'],'status':True}


def extract_face(loc):
    test_image = image.load_img(loc, target_size = (128,128))
    test_image = image.img_to_array(test_image)
    test_image = np.expand_dims(test_image, axis =0)
    result = model.predict(test_image)
    if result[0][0] == 1:
        predictions = True
    else:
        predictions = False
    print('Prediction: ',predictions)
    return predictions


def Verify_Voice(uploadedPath, VerifiedPath, UserID):
    userDirectory = os.getcwd() + filesep + 'Users' + filesep + \
        'VoiceData' + filesep + UserID
    sample1 = svt.extract_mfcc_from_wav_file(
        userDirectory + uploadedPath, samplerate=22000, winlen=0.025, winstep=0.01)
    sample1 = svt.rms_silence_filter(
        sample1, samplerate=16000, threshold=0.001135)
    sample2 = svt.extract_mfcc_from_wav_file(
        userDirectory + VerifiedPath, samplerate=22000, winlen=0.025, winstep=0.01)
    sample2 = svt.rms_silence_filter(
        sample2, samplerate=16000, threshold=0.001135)
    distance = svt.compute_distance(sample1, sample2)
    return distance


def saveFile(targetPath, DecodedData, UserID, directory):
    userDirectory = os.getcwd() + filesep + 'Users' + filesep + \
        directory + filesep + UserID
    try:
        # creating a folder named data
        if not os.path.exists(userDirectory):
            os.makedirs(userDirectory)

            # if not created then raise error
    except OSError:
        print('Error: Creating directory of data')

    with open(userDirectory + filesep + targetPath, 'wb') as wfile:
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
    ToVerifyPath = filesep + 'ToVerify.wav'
    saveFile(ToVerifyPath, ToVerifyVoiceDecoded, UserID, 'VoiceData')
    UploadedVerifyPath = filesep + 'Uploaded.wav'
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
    saveFile('leftSide.jpeg', leftDecoded, UserID, 'FaceData')
    rightDecoded = base64.b64decode(rightEncoded)
    saveFile('rightSide.jpeg', rightDecoded, UserID, 'FaceData')
    frontDecoded = base64.b64decode(frontEncoded)
    saveFile('frontSide.jpeg', frontDecoded, UserID, 'FaceData')
    ToVerifyDecoded = base64.b64decode(ToVerifyEncoded)
    saveFile('VerifySide.jpeg', ToVerifyDecoded, UserID, 'FaceData')
    result = verify_Face(UserID)
    return result


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5500)
