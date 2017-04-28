function MIMLNC
ds_name='LetterFrost';
gamma=0;
MIML_NC_Core(ds_name,gamma);
end


function MIML_NC_Core(ds_name,gamma)
fullfilename = strcat('./Dataset/',ds_name,'/allclasses/newlabels.mat');
EMiterations = 50;
load(fullfilename);clear Data;
kernel = 'feature';
[K,X] = PreprocessingX(X); 

w0 = LoadExistFile(X,Y);

for cross = 1:5
    [Y_test, X_test, y_test, Y_train, X_train, ~] = TrainandTest(Y,X,y,10,cross);
    [w,~,~,~] = ExpectMaximizationMIMIL(w0,K,X_train,Y_train,EMiterations,gamma);
    [accuracy(cross)] = Predict(w,Y_test,X_test,y_test);
end

results = [accuracy; mean(accuracy); std(accuracy)];
dlmwrite(strcat(ds_name,'results.txt'),results);
end

function [K,X_out] = PreprocessingX(X)
    X = DataNormalize(X);
    X_out = AddOne(X);
    K = zeros(size(X_out{1},1));
end
 
function w = LoadExistFile(X,Y)
w = Initializew(X,Y); 
w = w/1000;
w = normalize(w);
end

function X_out = DataNormalize(X)
firstmm = zeros(size(X{1},1),length(X));
secondmm = zeros(size(X{1},1),length(X));
n=0;
for i = 1:length(X)
    if(size(X{i},2)>0)
        firstmm(:,i) = sum(X{i},2);
        secondmm(:,i) = sum(X{i}.*X{i},2);
        n = n+size(X{i},2);
    end
end

mean2 = sum(firstmm,2)/n;
secondmm2 = sum(secondmm,2)/n;
 
variance2 = secondmm2-mean2.*mean2;
std2 = sqrt(variance2*n/(n-1));
ind = find(std2==0);
std2(ind) = abs(mean2(ind))+1;

for i = 1:length(X)
    if(size(X{i},2)>0)
        for j = 1:size(X{i},2)
            temp = X{i}(:,j)- mean2;
            X{i}(:,j) = temp./std2;
        end
    end
end
 
X_out = X;
end

function X_out = AddOne(X)
for i = 1:length(X)
    if(size(X{i},2)>0)
        X_out{i} = [X{i}; ones(1,size(X{i},2))];
    end
end
end

function w_new = normalize(w)
sum_column = ones(1,size(w,2))./sum(w);
w_new = w*diag(sum_column);
end

function w = Initializew(X,Y)
w = randi(1000,size(X{1},1),size(Y,2)+1);
end


function [accuracy] = Predict(w,Y_test,X_test,y_test)
Y = zeros(length(X_test),size(w,2));

for i = 1:length(X_test)
    p = PriorOneBag(X_test{i},w);
    Y(i,:) = ptoY(p');
end
Y(:,size(Y,2)) = [];

for i = 1:length(X_test)
    if(size(X_test{i},2)>0)
        p = PriorOneBag(X_test{i},w);
        p = p';
        for j = 1:size(p,1)
            [~, indtruth] = max(y_test{i}(j,:));
            [~, indpred] = max(p(j,:));
        end
        [score(i), total(i)] = Eval_Common(y_test{i},p);
    end
end

accuracy=sum(score)/sum(total);
end

function Y = ptoY(p)
Y = zeros(1,size(p,2));
for i = 1:size(p,1)
    if(sum(p(i,:))>0)
        [~, indclass] = max(p(i,:));
        Y(indclass) = 1;
    end
end
end

function [score, total] = Eval_Common(y,p)
pred = [];
truth = [];
for i = 1:size(y,1)
    [valuetruth, indtruth] = max(y(i,:));
    [valuepred, indpred] = max(p(i,:));
    pred = [pred indpred];
    truth = [truth indtruth];
end
err = abs(pred-truth);
score = length(find(err==0));
total = length(pred);
end


function [Y_test, X_test, y_test, Y_train, X_train, y_train] = TrainandTest(Y,X,y,ratio,cross)
totalbags = length(X);
sizecross = zeros(1,ratio);
part = floor(totalbags/ratio);
residual = totalbags-part*ratio;
for i = 1:length(sizecross)
    sizecross(i) = part;
    if(residual>=1)
    sizecross(i) = sizecross(i)+1;
    residual = residual-1;
    end
end
if(cross<ratio)
    if(cross>1)
        testindex = [sum(sizecross(1:cross-1))+1 : sum(sizecross(1:cross))];
    else
        testindex = [1 : sum(sizecross(1:cross))];
    end
else
    testindex = [sum(sizecross(1:cross-1))+1 : totalbags];    
end
index = zeros(length(X),1);for i=1:length(X)index(i)=i;end
index(testindex) = [];
trainindex = index;
 
Y_test = Y(testindex,:);Y_train=Y(trainindex,:);
X_test = X(testindex);X_train=X(trainindex);
y_test = y(testindex);y_train=y(trainindex);
end