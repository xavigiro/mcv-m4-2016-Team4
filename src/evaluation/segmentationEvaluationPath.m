function [ tp , fp , fn , tn, totalForeground, totalBackground ] = segmentationEvaluationPath( pathGroundtruth , pathResults , testId , offsetDesynch , VERBOSE )
%SEGMENTATIONEVALUATION Evaluates one folder
%   Recieve the information:
%       * pathGroundtruth: Path to the ground truth.
%       * pathResults: Path to the results to evaluate
%       * testId: Test id for identifying the files in pathResults.
%       * offsetDesynch: number of frames to shift in order to create a
%                  desynchronization for experimentation / debug purposes. 
%                  offsetDesynch = 0 means no desynch at all, offsetDesynch = 
%                  N (where N > 0) creates a shift of N frames between the 
%                  results and the groundtruth.
%       * VERBOSE: Plot further information.
%   The output are:
%       * True Positives (TP)
%       * False Positives (FP)
%       * True Negatives (FN)
%       * False Negatives (TN)

    % If no test is provided, we assume that we have to compute it for the
    % whole folder
    if ~exist( 'testId' , 'var' )
        testId = '';
    end % if
    if ~exist( 'offsetDesynch' , 'var' )
        offsetDesynch = 0;
    end % if
    if ~exist( 'VERBOSE' , 'var' )
        VERBOSE = false;
    end % if
    
    % List of files for the test
    list = dir([ pathResults , testId ]); % get info of files/folders in directory
    isfile= ~[list.isdir]; %determine index of files vs folders
    filesResultsTest={list(isfile).name}; %create cell array of file names
    % filter files starting with '.'
    filesResultsTestInd = cellfun(@(x) x(1)=='.',filesResultsTest);
    filesResultsTest = filesResultsTest(~filesResultsTestInd);
    
    % Setup variables
    tp = zeros(length(filesResultsTest),1);
    fp = zeros(length(filesResultsTest),1);
    tn = zeros(length(filesResultsTest),1);
    fn = zeros(length(filesResultsTest),1);
    totalForeground = zeros(length(filesResultsTest),1);
    totalBackground = zeros(length(filesResultsTest),1);
    
    
    % Annotations on the groundtruth
    %     0 : Static
    %     50 : Hard shadow
    %     85 : Outside region of interest
    %     170 : Unknown motion (usually around moving objects, due to semi-transparency and motion blur)
    %     255 : Motion
    % We will use:
    %     Background: 0, 50
    %     Foreground: 255
    %     Unknown (not evaluated): 85, 170 
    for i = 1:length(filesResultsTest)
        % Read test image
        im_test = imread( [ pathResults filesResultsTest{i} ] );
        im_test = logical( im_test );

        % Read Ground truth image
        splittedStr1 = strsplit(filesResultsTest{i} , '_');
        splittedStr2 = strsplit(splittedStr1{end} , '.');

        numFile=sprintf(['%0' num2str(length(splittedStr2{1})) 'd'] , str2double(splittedStr2{1}) + offsetDesynch );
        nameGroundtruth = [strjoin({splittedStr1{1:end-1}, numFile},'_') '.' splittedStr2{end}];
        nameGroundtruth = strrep(nameGroundtruth , testId , '');
        im_gt = imread( [ pathGroundtruth  nameGroundtruth] );
        foreground = im_gt == 255;
        background = im_gt==0 | im_gt==50;

        % Compare both images
        tp(i) = tp(i) + sum( sum( im_test .* foreground ) );
        fp(i) = fp(i) + sum( sum( im_test .* background ) );
        tn(i) = tn(i) + sum( sum( (~im_test) .* background ) );
        fn(i) = fn(i) + sum( sum( (~im_test) .* foreground ) );

        % Compute total foreground and total background
        totalForeground(i) = totalForeground(i) + sum( sum( foreground ) );
        totalBackground(i) = totalBackground(i) + sum( sum( background ) );
    end % for
    
    if VERBOSE
        [ p , r , f1 ] = getMetrics( sum( tp ) , sum( fp ) , sum( fn ) , sum( tn ) );
        fprintf( 'Test %s:\n' , testId );
        fprintf( '\ttp = %d , fp = %d , fn = %d , tn = %d\n' , sum( tp ) , sum( fp ) , sum( fn ) , sum( tn ) );
        fprintf( '\tPrecision = %f , Recall = %f , F1-score = %f\n' , p , r , f1 );
    end

end