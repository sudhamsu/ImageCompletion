function [ level_set ] = getLevelSet( c_map )
%GETLEVELSET Level Set building step in Fragment-based Image Completion

    c_map_mean = mean(c_map(:));
    c_map_std  = std(c_map(:));
    
    level_set = zeros(size(c_map));
    for i = 1:size(level_set,1)
        for j = 1:size(level_set,2)
            if c_map(i,j) <= c_map_mean
                level_set(i,j) = c_map(i,j) + c_map_std*rand();
            end
        end
    end
end

