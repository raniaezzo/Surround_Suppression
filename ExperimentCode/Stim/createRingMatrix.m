function ringMatrix = createRingMatrix(innerRadius, outerRadius, matrixSize)
    % Create a matrix of zeros with the specified size
    ringMatrix = zeros(matrixSize);
    
    % Define the center of the matrix
    centerX = (matrixSize + 1) / 2;
    centerY = (matrixSize + 1) / 2;
    
    % Loop through each element in the matrix and determine if it falls within the ring
    for i = 1:matrixSize
        for j = 1:matrixSize
            % Calculate the distance from the center to the current element
            distance = sqrt((i - centerX)^2 + (j - centerY)^2);
            
            % Check if the distance falls within the specified radii
            if distance >= innerRadius && distance <= outerRadius
                ringMatrix(i, j) = 1; % Fill in the ring with ones
            end
        end
    end
end

