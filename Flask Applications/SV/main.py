from flask import Flask, escape, request, jsonify
import speaker_verification_toolkit.tools as svt

import os
import datetime
import base64

app = Flask(__name__)

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



@app.route('/VerifyVoice/', methods=["GET", "POST"])
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

if __name__ == '__main__':
    app.run(threaded=True, port=5000)