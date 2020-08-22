classdef DataSet
    % Dataset data structure. Makes joining of two datasets,
    % as well as dividing the dataset into train and test sets easy.
    
    properties
        variable_mat % Design matrix with flattened stimulus concatenated as rows (dim: [num_stim, stim_length])
        label_vec % binned spikes (dim: [num_stim, 1])
        label_id % references for equal division
    end
    
    methods
        function obj = DataSet(variable_mat,label_vec,label_id)
            %DATASET Construct an instance of this class
            obj.variable_mat = variable_mat;
            obj.label_vec = label_vec;
            if nargin == 2
                obj.label_id = zeros(size(label_vec));
            else
                obj.label_id = label_id;
            end
        end
        
        function [train_var, train_lab, test_var, test_lab, train_id, test_id] = divide_train_test_data_equally(obj, test_size, n_frame_types, as_sparse)
            % Divide the dataset into train and test sets.
            % with the reference id, make sure that each type of frames are
            % having equal numbers in test set.
            % assuming that number of each type is equal in the whole set.
            
            if nargin == 2
                n_frame_types = 512;
                as_sparse = false;
            elseif nargin == 3
                as_sparse = false;
            end
            
            train_var = zeros(size(obj.variable_mat, 1) - n_frame_types*test_size, size(obj.variable_mat, 2));
            train_lab = zeros(size(obj.variable_mat, 1) - n_frame_types*test_size, 1);
            train_id = zeros(size(obj.variable_mat, 1) - n_frame_types*test_size, 1); % debug
            
            test_var = zeros(n_frame_types*test_size, size(obj.variable_mat, 2));
            test_lab = zeros(n_frame_types*test_size, 1);
            test_id = zeros(n_frame_types*test_size, 1); % debug
            
            train_n = 0;
            test_n = 0;
            
            for i = 0:(n_frame_types-1)
                candidates = find(obj.label_id == i);
                rand_queue = randperm(length(candidates));
                
                test_var(test_n+1:test_n+test_size, :) = obj.variable_mat(candidates(rand_queue(1:test_size)), :);
                test_lab(test_n+1:test_n+test_size) = obj.label_vec(candidates(rand_queue(1:test_size)));
                test_id(test_n+1:test_n+test_size) = i;
                test_n = test_size + test_n;
                
                train_bin_n = length(candidates) - test_size;
                train_var(train_n+1:train_n+train_bin_n, :) = obj.variable_mat(candidates(rand_queue(test_size+1:end)), :);
                train_lab(train_n+1:train_n+train_bin_n) = obj.label_vec(candidates(rand_queue(test_size+1:end)));
                train_id(train_n+1:train_n+train_bin_n) = i;
                train_n = train_bin_n + train_n;
            end
            
            if as_sparse
                train_var = sparse(train_var);
                test_var = sparse(test_var);
            end
        end
        
        function [train_var, train_lab, test_var, test_lab, train_id, test_id] = divide_train_test_data(obj, train_pct)
            % Divides the dataset into train and test sets
            [data_len,~] = size(obj.variable_mat);
            idx = randperm(data_len);
            train_var = obj.variable_mat(idx(1:round(train_pct*data_len)),:);
            test_var = obj.variable_mat(idx(round(train_pct*data_len)+1:end),:);
            train_lab = obj.label_vec(idx(1:round(train_pct*data_len)));
            test_lab = obj.label_vec(idx(round(train_pct*data_len)+1:end));
            
            train_id = obj.label_id(idx(1:round(train_pct*data_len)));
            test_id = obj.label_id(idx(round(train_pct*data_len)+1:end));
        end
        
        function obj = join(obj, dataset)
            % joins two dataset objects
            obj.variable_mat = [obj.variable_mat;dataset.variable_mat];
            obj.label_vec = [obj.label_vec; dataset.label_vec];
        end
    end
end

