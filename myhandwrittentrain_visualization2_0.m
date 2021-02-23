clear; clc; close all;

%% Load layer and set image 層の読み込みと画像のセット
load mylayers
% Define training data/学習用データの定義
imdshandTrain = imageDatastore('mypic\train', 'IncludeSubfolders',true,'LabelSource','foldernames');
% Define validation data/テスト用データの定義
imdshandValidation = imageDatastore('mypic\test', 'IncludeSubfolders',true,'LabelSource','foldernames');
%% Set training option/学習オプションの設定
options = trainingOptions('sgdm', ... % Solver for training network, stochastic gradient descent with momentum/最適化エンジン。確率的勾配降下法を選択
    'MaxEpochs',1, ... % Maximum number of epochs/学習のデータセットの繰り返し頻度
    'ValidationData',imdshandValidation, ... % data to use validation 評価用データの指定
    'ValidationFrequency',10, ... %frequency of network validation/ 評価用データでの検証頻度
    'Verbose',false); % 

%% Visualization of training and results, plot creation/学習と結果の可視化、プロット作成
k=30; % number of epochs/学習の繰り返し回数
f = figure; % create plot object/プロットの作成
f.Units = 'normalized';
f.Position = [0.05 0 0.5 0.8];shg
% Set initial values of variables/変数の初期値設定
% flag when accuracy exceeds 25%,50%,75%/精度が指定の値を超えたかチェックするフラグを指定
flag25 =1;
flag50 =1;
flag75 =1;
m =zeros(4,1);
for nn = 1:k
    if nn == 1
        net = trainNetwork(imdshandTrain,layers,options); % Training/学習
    else
        net = trainNetwork(imdshandTrain,net.Layers,options); % Training/学習
    end
    YPred = classify(net,imdshandValidation);
    for ii = 1:numel(imdshandValidation.Labels)  
        Itest = read(imdshandValidation); % Read images/画像の読み込み
        YPred1 = classify(net,Itest); % Classify each data/画像ごとに予測
        Itest3 = cat(3,Itest,Itest,Itest); % covert the image into RGB/画像をカラーに変換
        if ~(YPred1 == imdshandValidation.Labels(ii))
            Color = 'red'; % show red when result is wrong/予測結果が間違っていたら赤
        else
            Color = 'green'; % show green when result is right/予測が正しければ緑
        end
        Itest3 = insertShape(Itest3,'Rectangle',[1 1 28 28],...
            'Color', Color,'LineWidth',3); % Put a specified frame around the image/画像の周囲に指定した枠をつける
        data{ii} = Itest3; % Store the image in the data the frame is placed/枠が付いたあとの画像をdataに格納
    end
    reset(imdshandValidation); % reset datastore to initial state/imagedatastoreの読み出しをリセット
    subplot(1,2,1), montage(data,'Size',[10 5]); % The result of each image is displayed on the left side of the figure/各画像の判定結果をfigureの左側に表示
    YValidation = imdshandValidation.Labels;
    accuracy(nn) = sum(YPred == YValidation)/numel(YValidation);% Calculate accuracy at this moment/現時点での精度を計算
    % Save file as variable when accuracy exceeds 25%, 50%, 75%, respectively/精度が25%,50%,75%を超えた直後のファイルのみ変数として保持
    if accuracy(nn) < 0.25 
    elseif accuracy(nn) >0.25 & flag25 ==1 % When accuracy exceeds 25%/25%を超えたとき
        net25 = net;
        m(1) =nn;
        flag25=0;
    elseif accuracy(nn) > 0.5 & flag50 ==1 %When accuracy exceeds 50%/ 50%を超えたとき
        net50 = net;
        m(2) =nn;
        flag50=0;
    elseif accuracy(nn) > 0.75 & flag75 ==1 % When accuracy exceeds 75%/75%を超えたとき
        net75 = net;
        m(3) =nn;
        flag75 =0;      
    end
    subplot(1,2,2), plot(accuracy),ylim([0 1]) % Display accuracy at right side of figure/精度をfigureの右側に表示
    shg;
end
accuracy(end) % Dispay accuracy/精度の表示
m(4) = nn(end);
save('netresult.mat','net*','accuracy','m')

% Copyright 2020 The MathWorks, Inc.