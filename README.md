# karaokestudio
ka**ʀ**aokeStudio

This is an entertainment for April Fool in 2020.

これは2020年のエイプリルフール企画です.

<img src="https://github.com/Gedevan-Aleksizde/karaokestudio/blob/master/www/icon.svg" width="200">

# Introduction in English

日本語解説は下の方を見てください.

## Requirements
* Linux OS (Ubuntu >=18.04 recommended)
* RStudio (>= 1.2.5001)
* Google Cloud Platform (GCP) account
* Headphone and microphone


## installation & setup

1. Create a Google Cloud Console project

https://console.cloud.google.com/

Then activate the following APIs  

* YouTube Ads Reach API
* YouTube Anlytics API
* YouTube Data API
* YouTube Reporting API
* Google Cloud Storage JSON API
* Google Natural Language API
* Google Cloud Translation API
* Google Cloud Speech API

2. Generate a client_id, client secret, and service cledentials as a json file

The client ID is formed like "XXXX.apps.gooleusercontent.com"

In detail:  

https://cloud.google.com/storage/docs/authentication#generating-a-private-key

3. install Python, `portaudio`, and `pyaudio`

Prinamly, install `portaudio`

```
sudo apt install portaudio19-dev
```

then install Python3.x (if not installed yet) and `pyaudio` module

e.g.:

```
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update 
sudo apt install python3.8 python3-pip
pip3.8 install pyaudio
```

4. install `mecab`, `mecab-ipadic-neologd`

This page is also useful: https://rpubs.com/auroratsai/440717

Download source at https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE

Then, run the following

```
cd mecab-X.X
./configure 
make
make check
su
make install
```

Next, install mecab-ipadic-neologd, the dictionary.

https://github.com/neologd/mecab-ipadic-neologd

5. このパッケージをインストールする

# 日本語の導入解説

## 要件
* Linux OS (Ubuntu 18.04以降推奨)
* RStudio (1.2.5001以降推奨)
* Google Cloud Platform (GCP) アカウント
* ヘッドフォンとマイク

## インストールとセットアップ

1. Google Cloud Console プロジェクトを作成する

https://console.cloud.google.com/

以下のAPIをアクティベートする

* YouTube Ads Reach API
* YouTube Anlytics API
* YouTube Data API
* YouTube Reporting API
* Google Cloud Storage JSON API
* Google Natural Language API
* Google Cloud Translation API
* Google Cloud Speech API

2. クライアントID, クライアントシークレット, そしてjson形式の認証情報を発行する

クライアントIDは "XXXX.apps.gooleusercontent.com" の形式で得られるものです.

詳細は以下を参照

https://cloud.google.com/storage/docs/authentication#generating-a-private-key

3. Pythonとサウンドデバイスライブラリのインストール

まず`portaudio`ライブラリをインストールする.

```
sudo apt install portaudio19-dev
```

python3.x をインストールし, `pyaudio` モジュールをインストールする

例えば,

```
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update 
sudo apt install python3.8 python3-pip
pip3.8 install pyaudio
```

python環境は色々あるので各自対応すること


4. `meacab` と `mecab-ipadic-neologd` をインストールする

リンク先に日本語で書いてあるので解説省略.

https://taku910.github.io/mecab/

https://github.com/neologd/mecab-ipadic-neologd


5. このパッケージをインストールする
