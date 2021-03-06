%% Main Script
% M4. Video Analysis Project
% This script computes all the tasks that are done for the block 3 of the
% project.
% 

%% Initialize global parameters
setup;

%% Set up enviroment and get the best model from the block 2
if ~exist([seq.basePaths{1} folderBaseResults ], 'dir')
    allSequencesSegmentation(seq, folderBaseResults, fileFormat, colorIm, colorTransform);
end

%% Task 1
% Generate precision and recall
minAlpha=0; stepAlpha=1; maxAlpha=20;
alphaValues = minAlpha:stepAlpha:maxAlpha;
taskId = '1';
connectivity = [4 , 8];
if ~exist(['savedResults' filesep 'dataTask1.mat'], 'file')
    morphFunction = @applyMorphoTask1;
    evaluateMorpho(seq, fileFormat, alphaValues, connectivity, morphFunction, colorIm, colorTransform, false, taskId);
else
   disp('Task 1 results found (savedResults/dataTask1.mat). Skipping Task 1...'); 
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask1']);
legendStr = {'Baseline', 'Connectivity=4', 'Connectivity=8'};
[AUCsB2, AUCsT1] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

% Get best connectivity and metrics
[maxAUCT1, bestIndTask1] = max(mean(AUCsT1));
task1BestResults.prec = results.prec2(:,:,bestIndTask1);
task1BestResults.rec = results.rec2(:,:,bestIndTask1);
task1BestResults.f1score = results.f1score2(:,:,bestIndTask1);
bestConnectivity = connectivity(bestIndTask1);

disp(['Task 1 best connectivity is ' num2str(bestConnectivity)]); 
%% Task 2
taskId = '2';
minPixels = 1; stepPixels = 100; maxPixels = 1001;
pixels = minPixels:stepPixels:maxPixels;
if ~exist(['savedResults' filesep 'dataTask2.mat'], 'file')
    morphFunction = @(masks,p) applyMorphoTask2(masks, p, bestConnectivity);
    evaluateMorpho(seq, fileFormat, alphaValues, pixels, morphFunction, colorIm, colorTransform, false, taskId);
else
   disp('Task 2 results found (savedResults/dataTask2.mat). Skipping Task 2...');  
end

% Generate figures and calculate AUC
% To compare with task one best result we have to change the baseline
results = load(['savedResults' filesep 'dataTask2']);
results.prec1 = task1BestResults.prec;
results.rec1 = task1BestResults.rec;
results.f1score1 = task1BestResults.f1score;

legendStr = {'Baseline Task1'};
% The pixels will change depending on the parameters
for p = pixels
    legendStr{end+1} = sprintf('Pixels=%d',p);
end
[~ , AUCsT2] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

plotAucCurve(seq, pixels, AUCsT2, folderFigures, taskId);

% Get best number of pixels and metrics
[maxAUCT2, bestIndTask2] = max(mean(AUCsT2));
bestPixels = pixels(bestIndTask2);

disp(['Task 2 best number of pixels is ' num2str(bestPixels)]);

%% Task 3
taskId = '3';
legendStr = {'Baseline'};
if maxAUCT2>maxAUCT1
    results = load(['savedResults' filesep 'dataTask2']);
    legendStr{end+1} = 'Task2';
    bestInd = bestIndTask2;
else
    results = load(['savedResults' filesep 'dataTask1']);
    legendStr{end+1} = 'Task1';
    bestInd = bestIndTask1;
end
results.prec2 = results.prec2(:,:,bestInd);
results.rec2 = results.rec2(:,:,bestInd);
results.f1score2 = results.f1score2(:,:,bestInd);

calculateAUCs(seq, results, folderFigures, legendStr, taskId);

disp(['The best result is obtained with ' num2str(legendStr{2})]);

%% Task 4
taskId = '4';
pixelsClose = [1,3,5];
if ~exist(['savedResults' filesep 'dataTask4.mat'], 'file')
    morphFunction = @(masks,x) applyMorphoTask4(masks, bestPixels, bestConnectivity, x);
    evaluateMorpho(seq, fileFormat, alphaValues, pixelsClose, morphFunction, colorIm, colorTransform, false, taskId);
else
   disp('Task 4 results found (savedResults/dataTask4.mat). Skipping Task 4...'); 
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask4']);
legendStr = {'Baseline'};
% The pixels will change depending on the parameters
for p = pixelsClose
    legendStr{end+1} = sprintf('Pixels=%d',p);
end
[~, AUCsT4] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

% Get best connectivity and metrics
[maxAUCT4, bestIndTask4] = max(mean(AUCsT4));
task4BestResults.prec = results.prec2(:,:,bestIndTask4);
task4BestResults.rec = results.rec2(:,:,bestIndTask4);
task4BestResults.f1score = results.f1score2(:,:,bestIndTask4);
bestClose = pixelsClose(bestIndTask4);

%% Task 5
taskId = '5';
colorTransformCell = {colorTransform, @(x) applycform(x, makecform('lab2srgb'))};
if ~exist(['savedResults' filesep 'dataTask5.mat'], 'file')
    morphFunction = @(masks, x) applyMorphoTask4(masks, bestPixels, bestConnectivity, bestClose);
    evaluateMorpho(seq, fileFormat, alphaValues, [NaN], morphFunction, colorIm, colorTransformCell, @shadowRemoval, taskId);
else
   disp('Task 5 results found (savedResults/dataTask5.mat). Skipping Task 5...'); 
end

% Generate figures and calculate AUC
results = load(['savedResults' filesep 'dataTask5']);
legendStr = {'Baseline', 'Optional 5'};
[~, AUCsT5] = calculateAUCs(seq, results, folderFigures, legendStr, taskId);

% Get best connectivity and metrics
[maxAUCT5, bestIndTask5] = max(mean(AUCsT5));
task5BestResults.prec = results.prec2(:,:,bestIndTask5);
task5BestResults.rec = results.rec2(:,:,bestIndTask5);
task5BestResults.f1score = results.f1score2(:,:,bestIndTask5);
%bestConnectivity = connectivity(bestIndTask5);