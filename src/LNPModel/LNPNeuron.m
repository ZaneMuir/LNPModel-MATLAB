classdef LNPNeuron
    %LNPNEURON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        NLTransform
    end
    
    methods
        function obj = LNPNeuron(name, nl)
            obj.Name = name;
            obj.NLTransform = nl;
        end
        
        function output = predict(obj, X)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            output = obj.NLTransform(obj.linear_predictor(X));
        end
        
        function output = nll(obj, X, y, dt)
            % nll(obj, X, y, dt) -> double
            % negative log-likelihood
            %
            y_prime = obj.predict(X) * dt;
            output = -sum(y(:) .* log(y_prime) - y_prime - gammaln(y(:) + 1));
        end
        
    end
    
    methods (Static=true)
        function [F, G] = nll_fg(T, X, y, w0, dt, grid_size, nl, der_nl)
            n = T(w0, grid_size, nl);
            F = n.nll(X, y, dt);
            
            xl = n.linear_predictor(X);
            
            dFdl = y ./ (nl(xl) * dt) - 1;
            
            dfdw = der_nl(xl) * dt;
            dldt = n.dldt(X, dfdw);
            
            G = -1 * sum(dFdl .* dldt, 1)';
        end
        
    end
end

