%
%   preprocessing.m
%   @brief Preprocesses the data for use in DLP 1-bit systems
%   @param mnist_location
%
%   @param output_location
%               output folder to store results
%
%   @param resolution (Optional)
%               resolution of individual kernel
%               for example, let an image pixel input be 2
%               then for a 2x2 resolution kernel,
%               the output may be
%                   +---+---+
%                   | 1 | 0 |
%                   +---+---+
%                   | 0 | 1 |
%                   +---+---+
%               where, the sum equals the value of the image pixel
%               the default argument is [8 8] and default sparsity
%   
%   @param sparsity (Optional)
%               sparsity defines how to compute the mapping between
%               kernel output and image pixel value
%               for example, let an image pixel input be 2
%               a resolution of [2 2], and sparsity of 1
%               then, the mapping is a 1-to-1 mapping, where
%               a value of 2 corresponds to two spaces in kernel
%               the default argument is ceil(255/prod([8 8])) and
%               assumes a 8-bit image array.
%               this is the lower bound for sparsity computation
%
%
%   @author     Peter Tso
%   @date       09.18.2023
%   @copyright  see README.md
%   @company    University of Kansas
%
%
%   Dependencies:
%               processImageMNIST.m         (MATLAB, bundled in Utils)
%               ResolutionLayer.m           (Custom, bundled in Layers)
%               numdigits.m                 (Custom, bundled in Utils)
%
%   For use in:
%               R2022b and above.
%               Requires Computer Vision Toolbox,
%                        DSP Toolbox,
%                        Deep Learning Toolbox
%
function preprocessing(mnist_location, output_location, options)
    arguments
        mnist_location  string
        output_location string
        options.Resolution (1, 2) double  = NaN
        options.Sparsity   (1, 1) double  = NaN
        options.Verbosity  (1, 1) logical = false
    end
    % default resolution and sparsity
    if any(isnan(options.Resolution)) && any(isnan(options.Sparsity))
        resolution=[8 8];
        sparsity = ceil(255/prod(resolution)); % lower bound for  computing pixel assignment
    else
        %
        % if resolution is not defined and sparsity is
        if any(isnan(options.Resolution)) && ~any(isnan(options.Sparsity))
            resolution=[8 8];
            sparsity  =options.Sparsity;
        end

        %
        % if sparsity is not defined and resolution is
        if ~any(isnan(options.Resolution)) && any(isnan(options.Sparsity))
            resolution=options.Resolution;
            sparsity  =ceil(255/prod(resolution));
        end

        %
        % if both are defined
        if ~any(isnan(options.Resolution)) && ~any(isnan(options.Sparsity))
            resolution = options.Resolution;
            sparsity   = options.Sparsity;
        end
    end

    %
    % check if resolution is below lower bound
    lb = ceil(255/prod(resolution));

    %
    % Error Handling
    if any(resolution <= 0)
        msg = "Invalid Resolution. Resolution should be non-zero and positive";
        error(msg);
    end

    if any(resolution == Inf)
        msg = "Invalid Resolution. Resolution should not be infinite.";
        error(msg);
    end

    if sparsity < lb
        %
        % throw error message
        msg = "Sparsity is below lower bound. " + ...
            "Lower bound="+string(lb)+", Sparsity="+string(sparsity);
        error(msg);
    end

    %
    % uses ResLayer
    reslayer = ResolutionLayer('reslayer', resolution, [28 28], sparsity);
    
    location=output_location;
    
    X=processImagesMNIST(mnist_location);
    
    extn = '.png';                  % image extension
    len  = size(X, 4);              % size of dataset
    nZeros = numdigits(len);        % number of zeros used for naming files
    
    
    %
    % if verbose
    if options.Verbosity
        b=waitbar(0, "Processing your data...");
    end

    %
    % therefore for every image in inputfolder, we generate an outputfolder
    % image
    for i=1:len
        x=X(:,:,1,i);
        y=reslayer.predict(x);
            
        %
        %
        % Rescale to 500x500 while keeping the values [1 0]
        y=imresize(y,[1000 1000],'nearest');
        
        % Add padding and scale to 1600x2560
        dX=round((1600-size(y,1))/2);
        dY=round((2560-size(y,2))/2);
        z=padarray(y,[dX dY], 0);
        z=logical(z);
    
        %
        % save to file
        q = pad(string(i), nZeros, 'left', '0');
        q = q+extn;
        name = location+"/"+q;
        imwrite(z, name);

        if options.Verbosity
            waitbar(i/len,b,"Processing your data... Image "+string(i)+"/"+string(len)+".");
        end
    end

    if options.Verbosity
        close(b);       % close the toolbar
    end
end
