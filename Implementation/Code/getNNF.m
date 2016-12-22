function [ NNF, offsets ] = getNNF( t_im, s_im, ps, inv_matte_expanded, tp_inv_matte, t_im_inv_matte_expanded, NNF )
%GETNNF Creates and returns NNF for t_im to map patches to s_im

hps = floor(ps/2); % half of patch size

tp_inv_matte_4channels = repmat(tp_inv_matte,1,1,4);

% pad t_im with NaNs
t_im_NaN = padarray(t_im, [hps,hps], NaN, 'both');

t_im_inv_matte_expanded_NaN = padarray(t_im_inv_matte_expanded, [hps,hps], NaN, 'both');

% disp(size(t_im));
% disp(size(t_im_NaN));

% TODO: initialize only if there is no previous NNF
% initialize NNF randomly to the size of t_im
% with coordinate values within s_im
NNF = rand(size(t_im,1),size(t_im,2),2);
NNF(:,:,1) = ceil((size(s_im,1)-2*hps) * NNF(:,:,1))+hps;
NNF(:,:,2) = ceil((size(s_im,2)-2*hps) * NNF(:,:,2))+hps;
NNF = padarray(NNF, [hps,hps], NaN, 'both');

% initialize offsets (calculate L1-distances from NNF)
% ignore NaN values while calculating this
offsets = zeros(size(t_im));
offsets = padarray(offsets, [hps,hps], NaN, 'both');
for i = hps+1:size(t_im_NaN,1)-hps
    for j = hps+1:size(t_im_NaN,2)-hps
        t_patch = t_im_NaN(i-hps:i+hps,j-hps:j+hps,:);
        
        si = NNF(i,j,1);
        sj = NNF(i,j,2);
        
        % if (si,sj) is in unknown_bbox, re-initialize those coordinates
        while isnan(si) || isnan(sj) || ...
              si < 1+hps || si > size(s_im,1)-hps || ...
              sj < 1+hps || sj > size(s_im,2)-hps || ...
              mean(mean(inv_matte_expanded(si-hps:si+hps,sj-hps:sj+hps))) < 0.99
            NNF(i,j,1) = randi([1+hps,size(s_im,1)-hps]);
            NNF(i,j,2) = randi([1+hps,size(s_im,2)-hps]);
            si = NNF(i,j,1);
            sj = NNF(i,j,2);
        end
        
%         disp(size(s_im));
%         disp(si-hps);
%         disp(si+hps);
%         disp(sj-hps);
%         disp(sj+hps);
        
        s_patch = s_im(si-hps:si+hps,sj-hps:sj+hps,:);
        diff = t_patch-s_patch;
        diff(:,:,5:8) = diff(:,:,5:8) .* tp_inv_matte_4channels;
        diff = diff(~isnan(diff(:))); % ignore NaN values
        offsets(i,j) = norm(diff,1);
    end
end


% ITERATION
max_iter = 5;

for iter = 1:max_iter

    if mod(iter,2) == 1
        % odd iteration
        start_i = hps+1;
        end_i   = size(t_im_NaN,1)-hps;
        start_j = hps+1;
        end_j   = size(t_im_NaN,2)-hps;
        step    = 1;
    else
        % even iteration
        start_i = size(t_im_NaN,1)-hps;
        end_i   = hps+1;
        start_j = size(t_im_NaN,2)-hps;
        end_j   = hps+1;
        step    = -1;
    end
    
%     disp(start_i);
%     disp(end_i);
%     disp(start_j);
%     disp(end_j);
%     disp(step);
    
    for i = start_i:step:end_i
        for j = start_j:step:end_j
%             disp(i);
%             disp(j);
%             disp(size(t_im_inv_matte_expanded));
            if t_im_inv_matte_expanded_NaN(i,j) == 1
                continue;
            end
            
            % PROPAGATION

            % at every t_im(i,j), t_im(i-step,j), t_im(i, j-step)
            % get patch offset
            if mod(iter,2) == 1
                % odd iteration
                blue_o  = offsets(i,j);
                red_o   = offsets(max(1,i-step),j);
                green_o = offsets(i,max(1,j-step));
            else
                % even iteration
                blue_o  = offsets(i,j);
                red_o   = offsets(min(size(s_im,1),i-step),j);
                green_o = offsets(i,min(size(s_im,2),j-step));
            end
            
            % get the minimum of these
            [min_val, min_ind] = min([blue_o,red_o,green_o]);
            
            if min_ind == 1
                % no change
            elseif min_ind == 2
                % use (NNF(i-step,j,1)+step,NNF(i-step,j,2)) for blue
                if mod(iter,2) == 1
                    NNF(i,j,:) = [min(size(s_im,1)-hps,NNF(i-step,j,1)+step),NNF(i-step,j,2)];
                else
                    NNF(i,j,:) = [max(1+hps,NNF(i-step,j,1)+step),NNF(i-step,j,2)];
                end
            elseif min_ind == 3
                % use (NNF(i,j-step,1),NNF(i,j-step,2)+step) for blue
                if mod(iter,2) == 1
                    NNF(i,j,:) = [NNF(i,j-step,1),min(size(s_im,2)-hps,NNF(i,j-step,2)+step)];
                else
                    NNF(i,j,:) = [NNF(i,j-step,1),max(1+hps,NNF(i,j-step,2)+step)];
                end
            end
            
            % recalculate offset if NNF is changed above
            if min_ind == 2 || min_ind == 3
                t_patch = t_im_NaN(i-hps:i+hps,j-hps:j+hps,:);
                si = NNF(i,j,1);
                sj = NNF(i,j,2);
                
                % if (si,sj) is in unknown_bbox
                % switch back to red's or green's coordinates
                while isnan(si) || isnan(sj) || ...
                      si < 1+hps || si > size(s_im,1)-hps || ...
                      sj < 1+hps || sj > size(s_im,2)-hps || ...
                      mean(mean(inv_matte_expanded(si-hps:si+hps,sj-hps:sj+hps))) < 0.99
%                     NNF(i,j,:) = rand(1,1,2);
%                     NNF(i,j,1) = ceil((size(s_im,1)-2*hps) * NNF(i,j,1))+hps;
%                     NNF(i,j,2) = ceil((size(s_im,2)-2*hps) * NNF(i,j,2))+hps;
                    if min_ind == 2
                        NNF(i,j,:) = NNF(max(1,i-step),j,:);
                    elseif min_ind == 3
                        NNF(i,j,:) = NNF(i,max(1,j-step),:);
                    end
                    si = NNF(i,j,1);
                    sj = NNF(i,j,2);
                end
        
                s_patch = s_im(si-hps:si+hps,sj-hps:sj+hps,:);
                diff = t_patch-s_patch;
                diff(:,:,5:8) = diff(:,:,5:8) .* tp_inv_matte_4channels;
                diff = diff(~isnan(diff(:))); % ignore NaN values
                offsets(i,j) = norm(diff,1);
            end


            % RANDOM SEARCH
            
            k = 1; % random search iteration number
            w = squeeze([size(s_im,1);size(s_im,2)]);
            alpha = 0.5;
            old_nn = squeeze(NNF(i,j,:));
            old_offset = offsets(i,j);
            best_min_val = old_offset; % to keep track of best offset
            while w(1)*(alpha^k) > 1 && w(2)*(alpha^k) > 1
                new_nn = floor(old_nn + (alpha^k)*(w.*(2*(squeeze(rand(2,1))-0.5))));
                
                % clamp new_nn to the size of s_im
                if new_nn(1) < hps+1, new_nn(1) = hps+1; end
                if new_nn(1) > size(s_im,1)-hps, new_nn(1) = size(s_im,1)-hps; end
                if new_nn(2) < hps+1, new_nn(2) = hps+1; end
                if new_nn(2) > size(s_im,2)-hps, new_nn(2) = size(s_im,2)-hps; end
                
                % calculate offset for this new_nn
                t_patch = t_im_NaN(i-hps:i+hps,j-hps:j+hps,:);
                si = new_nn(1);
                sj = new_nn(2);
                
                % if (si,sj) is in unknown_bbox, re-initialize those coordinates
                while isnan(si) || isnan(sj) || ...
                      si < 1+hps || si > size(s_im,1)-hps || ...
                      sj < 1+hps || sj > size(s_im,2)-hps || ...
                      mean(mean(inv_matte_expanded(si-hps:si+hps,sj-hps:sj+hps))) < 0.99
                    new_nn = floor(old_nn + (alpha^k)*(w.*(2*(squeeze(rand(2,1))-0.5))));

                    % clamp new_nn to the size of s_im
                    if new_nn(1) < hps+1, new_nn(1) = hps+1; end
                    if new_nn(1) > size(s_im,1)-hps, new_nn(1) = size(s_im,1)-hps; end
                    if new_nn(2) < hps+1, new_nn(2) = hps+1; end
                    if new_nn(2) > size(s_im,2)-hps, new_nn(2) = size(s_im,2)-hps; end

                    % calculate offset for this new_nn
                    t_patch = t_im_NaN(i-hps:i+hps,j-hps:j+hps,:);
                    si = new_nn(1);
                    sj = new_nn(2);
                end
                
                s_patch = s_im(si-hps:si+hps,sj-hps:sj+hps,:);
                diff = t_patch-s_patch;
                diff(:,:,5:8) = diff(:,:,5:8) .* tp_inv_matte_4channels;
                diff = diff(~isnan(diff(:))); % ignore NaN values
                new_offset = norm(diff,1);
                
                % if new_offset is better than best_min_val, use this nn
                if new_offset < best_min_val
                    best_min_val = new_offset;
                    NNF(i,j,:) = new_nn;
                    offsets(i,j) = new_offset;
                end
                
                k = k+1;
            end
            
        end
    end

end
    
% Remove NaN padding
NNF = NNF(1+hps:end-hps,1+hps:end-hps,:);
offsets = offsets(1+hps:end-hps,1+hps:end-hps,:);
end

