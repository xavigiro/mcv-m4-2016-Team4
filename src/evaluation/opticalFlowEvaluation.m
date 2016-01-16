function [ msen , pepn ] = opticalFlowEvaluation( pathGroundtruth , pathResults , testId , pepnThresh , VERBOSE )
%OPTICALFLOWEVALUATION Evaluates one folder of optical flow
%   Recieve the information:
%       * pathGroundtruth: Path to the ground truth.
%       * pathResults: Path to the results to evaluate
%       * testId: Test id for identifying the files in pathResults.
%       * pepnThresh: Threshold for the pepnThresh
%       * VERBOSE: Plot further information.
%   The output are:
%       * msen: N array where each position has the Mean Square Error in 
%               Non-occluded areas for a given result.
%       * pepn: N array where each position has the Percentage of Erroneous
%               Pixels in Non-occluded areas for a given result.

    % If no test is provided, we assume that we have to compute it for the
    % whole folder
    if ~exist( 'testId' , 'var' )
        testId = '';
    end % if
    if ~exist( 'pepnThresh' , 'var' )
        pepnThresh = 3;
    end % if
    if ~exist( 'VERBOSE' , 'var' )
        VERBOSE = false;
    end % if
    
    % List of files for the test
    list = dir([ pathResults filesep testId  '*' ]);
    isfile= ~[list.isdir]; %determine index of files vs folders
    filesResultsTest={list(isfile).name}; %create cell array of file names
    % filter files starting with '.'
    filesResultsTestInd = cellfun(@(x) x(1)=='.',filesResultsTest);
    filesResultsTest = filesResultsTest(~filesResultsTestInd);
    
    % Setup variables
    msen = zeros( length(filesResultsTest) , 1 );
    pepn = zeros( length(filesResultsTest) , 1 );
    
%     Optical flow maps are saved as 3-channel uint16 PNG images: The first channel
%     contains the u-component, the second channel the v-component and the third
%     channel denotes if a valid ground truth optical flow value exists for that
%     pixel (1 if true, 0 otherwise). To convert the u-/v-flow into floating point
%     values, convert the value to float, subtract 2^15 and divide the result by 64:
% 
%     flow_u(u,v) = ((float)I(u,v,1)-2^15)/64.0;
%     flow_v(u,v) = ((float)I(u,v,2)-2^15)/64.0;
%     valid(u,v)  = (bool)I(u,v,3);
    for i = 1:length(filesResultsTest)
        % Read test image
        [testU , testV , ~ ] = readFlow( [ pathResults filesResultsTest{i} ] );
        
        % Read groundtruth
        nameGroundtruth = strrep(filesResultsTest{i} , testId , '');
        [gtU , gtV , gtVal ] = readFlow( [ pathGroundtruth filesep nameGroundtruth] );
        
        % Mean square error
        msenAux = sqrt((testU - gtU).^2 + (testV - gtV).^2);
        
        % Ocluded
        msenAux( gtVal==0 ) = 0;
        
        pepnAux = msenAux>pepnThresh;
        pepn(i) = sum(pepnAux(:))/sum(gtVal(:));
        msen(i) = sum(msenAux(:))/sum(gtVal(:));
        if VERBOSE
            fprintf( 'Evaluation %s:\n' , filesResultsTest{i})
            fprintf( '\tMSEN = %f\n\tPEPN = %f\n' , msen(i) , pepn(i))
        end % if
    end % for
end % function


