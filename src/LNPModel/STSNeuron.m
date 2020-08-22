classdef STSNeuron < LNPNeuron
    %STSNEURON: space time separable LNP model
    
    properties
        SpatialFilter % 2d array
        TemporalFilter % 1d array
    end
    
    methods
        function obj = STSNeuron(weights, grid_size, nl)
            if nargin == 2
                nl = @exp;
            end
            obj@LNPNeuron('STSNeuron', nl);
            
            s_size = grid_size * grid_size;
            t_size = length(weights) - s_size;
            
            obj.TemporalFilter = weights(1:t_size);
            obj.SpatialFilter = reshape(weights(t_size+1:end), grid_size, grid_size);
        end
        
        function [output, L] = linear_predictor(obj, X)
            L = obj.SpatialFilter .* reshape(obj.TemporalFilter, 1, 1, []);            
            output = X * L(:);
        end

        function output = dldt(obj, X, dfdw)
            
            w = [obj.TemporalFilter(:); obj.SpatialFilter(:)];
            
            s_len = numel(obj.SpatialFilter);
            t_len = numel(obj.TemporalFilter);
            dwdth = zeros(s_len*t_len, s_len+t_len); %TODO: optimization
            for idx = 1:t_len
                dwdth((idx-1)*s_len+1:idx*s_len, idx) = w(t_len+1:end);
                dwdth((idx-1)*s_len+1:idx*s_len, t_len+1:end) = eye(s_len) * w(idx);
            end
            
            dldw = dfdw .* X;
            
            output = dldw * dwdth;
        end
    end
end

