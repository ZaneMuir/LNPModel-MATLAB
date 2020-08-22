classdef CSSNeuron < LNPNeuron
    %CSSNEURON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OnTemporalFilter
        OnSpatialFilter
        OffTemporalFilter
        OffSpatialFilter
    end
    
    methods
        function obj = CSSNeuron(weights, grid_size, nl)
            if nargin == 2
                nl = @exp;
            end
            obj@LNPNeuron('CSSNeuron', nl);
            
            s_size = grid_size*grid_size;
            t_size = (length(weights) - s_size*2) / 2;
            
            obj.OnTemporalFilter = weights(1:t_size);
            obj.OffTemporalFilter = weights(t_size+s_size+1:t_size*2+s_size);
            obj.OnSpatialFilter = reshape(weights(t_size+1:t_size+s_size), grid_size, grid_size);
            obj.OffSpatialFilter = reshape(weights(t_size*2+s_size+1:end), grid_size, grid_size);
        end
        
        function output = linear_predictor(obj, X)
            X_on = X;
            X_on(X_on < 0) = 0;
            X_off = X;
            X_off(X_off > 0) = 0;
            
            L_on = obj.OnSpatialFilter .* reshape(obj.OnTemporalFilter, 1, 1, []);
            L_off = obj.OffSpatialFilter .* reshape(obj.OffTemporalFilter, 1, 1, []);
            
            output = X_on * L_on(:) + X_off * L_off(:);
        end
        
        function output = dldt(obj, X, dfdw)
            X_on = X;
            X_on(X_on < 0) = 0;
            X_off = X;
            X_off(X_off > 0) = 0;
            
            dldw_on = dfdw .* X_on;
            dldw_off = dfdw .* X_off;
            
            s_len = numel(obj.OnSpatialFilter);
            t_len = numel(obj.OnTemporalFilter);
            dwdth_on = zeros(s_len*t_len, 2*(s_len+t_len));
            dwdth_off = zeros(s_len*t_len, 2*(s_len+t_len));
            for idx = 1:t_len
                dwdth_on((idx-1)*s_len+1:idx*s_len, idx) = obj.OnSpatialFilter(:);    
                dwdth_on((idx-1)*s_len+1:idx*s_len, 2*t_len+1:2*t_len+s_len) = eye(s_len) * obj.OnTemporalFilter(idx);
                
                dwdth_off((idx-1)*s_len+1:idx*s_len, idx+t_len) = obj.OffSpatialFilter(:);
                dwdth_off((idx-1)*s_len+1:idx*s_len, 2*t_len+s_len+1:end) = eye(s_len) * obj.OffTemporalFilter(idx);
            end
            
            output = dldw_on * dwdth_on + dldw_off * dwdth_off;
        end
    end
end

