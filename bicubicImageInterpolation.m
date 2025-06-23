function point = interpolateAtT(P0, P1, P2, P3, t)
    point = 0.5 * ((2 * P1) + (-P0 + P2) * t + ...
                   (2 * P0 - 5 * P1 + 4 * P2 - P3) * t^2 + ...
                   (-P0 + 3 * P1 - 3 * P2 + P3) * t^3);
end

function result = bicubicInterpolate(matrix, u, v)
    rowInterpolations = zeros(1, 4);
    for i = 1:4
        rowInterpolations(i) = interpolateAtT(matrix(i,1), ...
                                               matrix(i,2), ...
                                               matrix(i,3), ...
                                               matrix(i,4), u);
    end
    result = interpolateAtT(rowInterpolations(1), ...
                            rowInterpolations(2), ...
                            rowInterpolations(3), ...
                            rowInterpolations(4), v);
end

function paddedMatrix = addPadding(matrix)
    [nRows, nCols] = size(matrix);
    paddedMatrix = zeros(nRows + 2, nCols + 2);
    paddedMatrix(2:end-1, 2:end-1) = matrix;
    paddedMatrix(1, 2:end-1) = matrix(1, :);
    paddedMatrix(end, 2:end-1) = matrix(end, :);
    paddedMatrix(2:end-1, 1) = matrix(:, 1);
    paddedMatrix(2:end-1, end) = matrix(:, end);
    paddedMatrix(1,1) = matrix(1,1);
    paddedMatrix(1,end) = matrix(1,end);
    paddedMatrix(end,1) = matrix(end,1);
    paddedMatrix(end,end) = matrix(end,end);
end

function scaledMatrix = bicubicScaling(matrix, s)
    n = size(matrix, 1);
    paddedMatrix = addPadding(matrix);
    scaledMatrix = zeros(n + (n - 1) * (s - 1));
    for x = 2:n
        for y = 2:n
            P = paddedMatrix((x-1):(x+2), (y-1):(y+2));
            for i = 1:(s+1)
                for j = 1:(s+1)
                    u = (j - 1) / s;
                    v = (i - 1) / s;
                    scaledMatrix(s * (x - 2) + i, s * (y - 2) + j) = ...
                        bicubicInterpolate(P, u, v);
                end
            end
        end
    end
    scaledMatrix = round(scaledMatrix);
end