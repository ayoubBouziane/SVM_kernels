%% Reset all
clear all;
close all;
hTree=findall(0,'Tag','tree viewer'); close(hTree)
clc;
%% Move to working directory
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
%% BLOCK 1 - Juli
% 1)
Dataset = load('../Data/example_dataset_1');
labels = Dataset.labels;
data = (Dataset.data)';
% 2)
sigma = 1;
K = exp( -L2_distance(data',data')/(2*sigma^2));
figure; imagesc(K); title('Gram matrix for sigma = 1');
% 3)
minvals = (K == min(min(K)));
maxvals = (K == max(max(K)));
figure;
subplot(1,2,1); imagesc(maxvals); title(strcat('Maximum values of K, with value: ',num2str(max(max(K)))));
subplot(1,2,2); imagesc(minvals); title(strcat('Minimum values of K, with value: ',num2str(min(min(K)))));
positivedefinite = all(eig(K) > 0);

% 4) & 5)
lambda = 1;
sigma = 1;
[model, v] = train_rbfSVM( labels, data, lambda, sigma );

% 6)
name = strcat('rbf SVM soft with lambda ',num2str(lambda),' and sigma ',num2str(sigma));
plotRbfSVM( data, labels, model, name );

%% BLOCK 2 - Juli
% 1)
% 2)
Dataset = load('../Data/example_dataset_1');
labels = Dataset.labels;
data = Dataset.data';

% 3)
t1 = classregtree(data, labels);
view(t1);
sfit = eval(t1,data);
ACC = mean(sfit==labels)
ERR = 1-ACC


% 4)
t2 = classregtree(data, labels, 'minparent',1);
view(t2);
sfit = eval(t2,data);
ACC = mean(sfit==labels)
ERR = 1-ACC

%% BLOCK 3 - Juli
% 1)
Dataset = load('../Data/example_dataset_1');
labels = Dataset.labels;
data = Dataset.data';
% 2)
k = 10;
kfolds = kfoldIndexer(data,k);
% 3)
freqPos = mean(labels == 1)
freqNeg = mean(labels == -1)
freqPosk = zeros(1,k);
freqNegk = freqPosk;
for i=1:k
    freqPosk(i) = mean(labels(kfolds{i}) == 1);
    freqNegk(i) = mean(labels(kfolds{i}) == -1);
end
freqPosk
freqNegk


%% BLOCK 4 - Juli
% 1)
Dataset = load('../Data/example_dataset_1');
labels = Dataset.labels;
data = Dataset.data';
% 2)
k = 5;
kfolds = kfoldIndexer(data,k);
%% 3)
lambdas = [0.01,0.1,1,10];
sigmas = [0.1,0.25,0.5,0.75,1,2.5,5,7.5,10];
errParamMat = zeros(size(lambdas,2),size(sigmas,2));
bestValidationsErrSVM = ones(1,k);
for i=1:1:size(lambdas,2)
    for j=1:1:size(sigmas,2) 
        auxACC = zeros(1,k);
        for n=1:1:k
            trainI = cell2mat(kfolds(setdiff((1:1:k),n)));
            testI = kfolds{n};

            trainX = data(trainI,:);
            trainY = labels(trainI);
            testX = data(testI,:);
            testY = labels(testI);

            model = train_rbfSVM( trainY, trainX, lambdas(i), sigmas(j) );
            K_dense = exp( -L2_distance(trainX(model.svs,:)',testX')/(2*model.sigma^2));
            predY = model.vy(model.svs)' * K_dense;
            auxACC(n) = mean(testY==sign(predY)');
        end
        errParamMat(i,j) = 1-mean(auxACC);
        if (1-mean(auxACC)) < mean(bestValidationsErrSVM) 
            bestValidationsErrSVM = 1-auxACC;
        end
    end
end

%% Plot best combination found of lambda and sigma
[bestRow,bestCol] = find(min(min(errParamMat))==errParamMat,1,'first');
model = train_rbfSVM( labels, data, lambdas(bestRow), sigmas(bestCol) );
name = strcat('rbf SVM soft with lambda ',num2str(lambdas(bestRow)),...
    ' and sigma ',num2str(sigmas(bestCol)));
plotRbfSVM( data, labels, model, name );

% Plot the cross-validation error obtained for each pair lambda sigma choosen 
% 3D surface
figure;
surf(sigmas,lambdas,errParamMat);
% 3D interpolated surface
figure;
surf(sigmas,lambdas,errParamMat);shading interp;
% 2D colormap
figure;
imagesc(sigmas,lambdas,errParamMat);
% Error obtained from cross-validation table for lambda as rows and sigma
% as columns
errParamMat

%% 4)

minparents = (1:1:100);
errParamMat = zeros(1,size(minparents,2));
bestValidationsErrTree = ones(1,k);
for i=1:1:size(minparents,2)
    auxACC = zeros(1,k);
    for n=1:1:k
        trainI = cell2mat(kfolds(setdiff((1:1:k),n)));
        testI = kfolds{n};

        trainX = data(trainI,:);
        trainY = labels(trainI);
        testX = data(testI,:);
        testY = labels(testI);

        model = classregtree(trainX, trainY, 'minparent', minparents(i));
        predY = eval(model,testX);
        auxACC(n) = mean(testY==sign(predY));
    end
    errParamMat(i) = 1-mean(auxACC);
    if (1-mean(auxACC)) < mean(bestValidationsErrTree) 
        bestValidationsErrTree = 1-auxACC;
    end
end

% Plot best minparent found with cross-validation
bestMinparent = minparents(find(min(errParamMat)==errParamMat,1,'first'));
model = classregtree(data, labels, 'minparent',bestMinparent);
view(model);
    
% Plot the cross-validation error obtained for each pair minparent choosen
% 2D plot of the cross-validation mean error 
figure;
plot(minparents,errParamMat,'-');
% Error obtained from cross-validation table for lambda as rows and sigma
% as columns
errParamMat


% 5)
bestValidationsErrSVM
bestValidationsErrTree

%% BLOCK 5 - Xavi

%% BLOCK 6 - Xavi

%% BLOCK 7 - Xavi

%% BLOCK 8 - Xavi



