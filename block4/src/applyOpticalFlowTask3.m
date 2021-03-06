function [ flow, GTfiles ] = applyOpticalFlowTask3( frames, outputPath, orderId, blockSize, areaSearch, saveIm, VERBOSE )
%APPLYOPTICALFLOWTASK3 Apply Block-Matching
    
    if ~exist('VERBOSE','var')
        VERBOSE = 0;
    end
    
    if ~exist('blockSize','var')
        blockSize = [17, 17];
    end
    
    if ~exist('areaSearch','var')
        areaSearch = [7, 7];
    end
    
    if ~exist('saveIm','var')
        saveIm = false;
    end
    
    if size(frames, 3) == 3
        colorIm = true;
        % Convert all frames to grayscale
        framesAux = zeros(size(frames,1),size(frames,2),1,size(frames,4),'like', frames);
        for i=1:size(frames, 4) 
            framesAux(:,:,:,i) = rgb2gray(frames(:,:,:,i));
        end
        frames = framesAux;
    else
        colorIm = false;
    end
    
    % Create the blockmatching
    bm = vision.BlockMatcher('ReferenceFrameSource', 'Input port', ...
    'BlockSize', blockSize, ...
    'MaximumDisplacement', areaSearch, ...
    'MatchCriteria', 'Mean absolute difference (MAD)', ...
    'OutputValue', 'Horizontal and vertical components in complex form');

    

    % Apply the optical flow estimation to each frame
    for i = 2:size(frames,4)
        auxResult = step(bm, frames(:,:,i-1), frames(:,:,i));
        flow{i-1} = opticalFlow(double(real(auxResult)), double(imag(auxResult)));
        
        % Get associated GT file name
        tmp = strsplit(outputPath, filesep);
        GTfiles{i-1} = [tmp{end} orderId(i-1,:) '.png'];
        
        if VERBOSE
            imshow(frame);
            hold on;
            plot(flow{i-1},'DecimationFactor',[5 5],'ScaleFactor',10);
            hold off;
        end

        if saveIm
            tmp = opticalFlow2GT(flow{i-1}.Vx, flow{i-1}.Vy);
            imwrite(tmp , [outputPath, orderId(i-1,:) '.png'])
        end
        
    end

end

