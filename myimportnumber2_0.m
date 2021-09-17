%% Create training data from handwritten digit/手書き文字から学習用データの作成
clear all;clc;close all;
f1 = figure('Units','normalized'), % Create figure window/Figureウィンドウを作る
    disp = uicontrol(f1,'Style','text',... % Create window for description/説明文のウィンドウを作る
        'Units','normalized',...
        'Position',[0.05, 0.5, 0.4, 0.2],... 
        'FontSize',20,...
        'String','type your name in alphabet');
    txt = uicontrol('Style','edit',... % Create an editable text field/文字入力を入れる
        'Units','normalized',...
        'Position',[0.05, 0.4, 0.4, 0.1]);
    button= uicontrol('Style','pushbutton',... % button (when pushing this button, go to next step)/% ボタン(押したら次のプロセスに進む)
        'Units','normalized',...        
        'Position',[0.6 0.4 0.2 0.2],...
        'String', 'OK',...
        'Callback', 'uiresume(gcbf)');
    uiwait(f1); % Wait until the button pressed/ボタンが押されるまで待つ

%% Read an image file that includes 100 handwritten letters by a scanner/スキャナーで読み取った100個の手書き文字が書かれた画像を読み込み
%I = imread('1.jpg');  %Change file name as appropriate
I = imread('chao.jpeg');
%imfinfo('chao.jpeg');
I = imrotate(I,-90);
I = rgb2gray(I);
figure,imshow(I);
%% Create a box that includes each digit/数値が書かれた領域のボックスを作成
BW = imbinarize(I); %Binarize/二値化
BW = imclearborder(BW); % Area connected to image boarder/周囲に接している部分を
BWbbox = imfill(BW,'holes'); % Fill holes/穴を埋める
BWbbox = imclose(BWbbox,ones(30)); % Morphologically close image/クローズ処理
BWbbox = bwareaopen(BWbbox,100); % Remove small objects less than 100/100より小さいごみを処理
% figure, imshow(BWbbox);
%% Extract each digit and save in each folder/各数字をトリミングで切り出しフォルダに保存
% Identify the area range of each digit/各数字の領域の範囲を指定
%thresh = [0 320 520 720 920 1100 1280 1480 1680 1880 2080];
% Get position and size of each digit/各数字の位置とサイズの情報を取得
statsbbox = regionprops('table',BWbbox,'Centroid','BoundingBox');
% Process based on number/数字の種類ごとに処理
for n= 1:10
    % Find where number = n/数字nの場所だけを取り出す
    %idx = statsbbox.Centroid(:,2) < thresh(n+1) & statsbbox.Centroid(:,2) > thresh(n);
    % sort rows of statsbbox to get indices of centroids in the same row
    idx = false(100,1);
    [~,sort_idx] = sortrows(table2array(statsbbox),2);
    idx(sort_idx((n-1)*10+1:n*10)) = true;
    % Get centroid of each region/各数字のエリアの中心座標を取り出す
    r = statsbbox.Centroid(idx,2); 
    c = statsbbox.Centroid(idx,1);
    % Get position and size of the box containing area/取り出すエリアの情報とサイズの調整
    rect = statsbbox.BoundingBox(idx,:);
    rect(:,1) = rect(:,1)+ 5;
    rect(:,2) = rect(:,2)+ 5;
    rect(:,3) = rect(:,3)- 10;
    rect(:,4) = rect(:,4)- 10;
    BW2 = bwselect(BWbbox,c,r,4);
    % Make a new folder/保存用のディレクトリを作成
    if n == 10 
        mkdir mypic\train\0
        mkdir mypic\test\0
    else
        mkdir(['mypic\train\' num2str(n)])
        mkdir(['mypic\test\' num2str(n)])
    end
    % Crop image, Reverse black and white, then save/トリミングし輝度反転し名前を付けて保存
    for i=1:10
        BW3 = bwselect(BW2,c(i),r(i),4); % Select an object out of 10/10個のうち一つを指定 
        I2 = imcrop(I,rect(i,:)); %Crop the image/指定領域をトリミング
        I3 = imadjust(255 - I2); % Reverse black and white and normalize/輝度反転し、正規化
        I4 = imresize(I3,[28 28]); % Resize image to 28x28 /サイズを28ｘ28に変換
        % Save in each folder/ 各フォルダに保存
        % display one by one/一枚ずつ表示
        imshow(I4);shg;
        if i < 6 % training data from 1st to 5th/5番目までは学習用
            ftype = 'train';
            fnum=i;
        else % validation data after 6th/6番目以降は評価用
            ftype = 'test';
            fnum=i-5;
        end
        % Save image/画像を保存
        if n ==10
            imwrite(I4,['mypic\' ftype '\0' '\' ftype '_' num2str(0) '_' num2str(fnum) '_' txt.String  '.jpg'] );
        else
            imwrite(I4,['mypic\' ftype '\' num2str(n) '\' ftype '_' num2str(n) '_' num2str(fnum) '_' txt.String   '.jpg'] );
        end
        clear I2 I3 
    end
end
winopen('mypic') % Open the file in Windows Explorer/Windowsのエクスプローラでフォルダを開く
%% 
function buttonaction
    if isempty(txt.String)
    else
        b =false;
    end
end
% Copyright 2020 The MathWorks, Inc.