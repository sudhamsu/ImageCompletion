function [ new_x, new_y ] = updateCoordinates(x,y,im,r)
%UPDATECOORDINATES Gets transformed coordinates when images are reoriented

    switch r
        case 2
            new_x = size(im,2) - y + 1;
            new_y = x;
        case 3
            new_x = size(im,1) - x + 1;
            new_y = size(im,2) - y + 1;
        case 4
            new_x = y;
            new_y = size(im,1) - x + 1;
        case 5
            new_x = size(im,1) - x + 1;
            new_y = y;
        case 6
            new_x = y;
            new_y = x;
        case 7
            new_x = x;
            new_y = size(im,2) - y + 1;
        case 8
            new_x = size(im,2) - y + 1;
            new_y = size(im,1) - x + 1;
        otherwise
            new_x = x;
            new_y = y;
    end
    
end