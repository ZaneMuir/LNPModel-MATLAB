classdef GLMNeuron < LNPNeuron
    %GLMNEURON: plain GLM neuronal model
    
    properties
        STA
    end
    
    methods
        function obj = GLMNeuron(weights, grid_size, nl)
            if nargin == 2
                nl = @exp;
            end
            obj@LNPNeuron('GLMNeuron', nl)
            s_size = grid_size * grid_size;
            t_size = length(weights) / s_size;
            obj.STA = reshape(weights, [grid_size, grid_size, t_size]);
        end
        
        function w = initiate_STS_weights(obj)
            amplitudes = sum(abs(obj.STA), [1,2]);
            [~, I] = max(amplitudes);
            
            s_rf = obj.STA(:, :, I) / max(abs(obj.STA(:, :, I)), [], 'all');
            t_rf = sum(obj.STA, [1,2]);
            t_rf = t_rf / t_rf(I);
            
            w = [t_rf(:); s_rf(:)];
        end
        
        function output = linear_predictor(obj, X)
            output = X * obj.STA(:);
        end
        
        function output = dldt(obj, X, dfdw)
            dldw = dfdw' * X;
            dwdth = eye(numel(obj.STA));
            
            output = dldw * dwdth;
        end
    end
end

