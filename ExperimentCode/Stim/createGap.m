function mask = createGap(gratingtex, innerEdgeRadius, outerEdgeRadius, rampSize)
    
    [~,imsize] = size(gratingtex);
    
    innerEdgeRadius_low = innerEdgeRadius - rampSize;
    innerEdgeRadius_high = innerEdgeRadius;
    
    outerEdgeRadius_low = outerEdgeRadius;
    outerEdgeRadius_high = outerEdgeRadius + rampSize;
    
    % initialize mask
    mask = zeros(imsize,imsize);
    
    [xN, yN] = meshgrid(-imsize/2+0.5:imsize/2-0.5, -imsize/2+0.5:imsize/2-0.5);
    [~, r] = cart2pol(xN,yN);

    cosX = linspace(-pi, 0, 1001); cosY = (cos(cosX)+1)/2;
    
    aa = r - outerEdgeRadius_low;
    test = aa(aa < outerEdgeRadius_high-outerEdgeRadius_low);
    test = test(test > outerEdgeRadius_low-outerEdgeRadius_low);
    maxRo = max(test); minRo = min(test);
    
    aa = r - innerEdgeRadius_low;
    test = aa(aa < innerEdgeRadius_high-innerEdgeRadius_low);
    test = test(test > innerEdgeRadius_low-innerEdgeRadius_low);
    maxRi = max(test); minRi  = min(test);
    
%     outerror = 0;
    
    % Loop through each pixel in the image
      for ii = 1:imsize
        for jj = 1:imsize
            if (r(ii,jj) >= innerEdgeRadius_high) && (r(ii,jj) <= outerEdgeRadius_low)
                mask(ii,jj) = 1;
            elseif (r(ii,jj) < innerEdgeRadius_high) && (r(ii,jj) > innerEdgeRadius_low)
                dist = r(ii,jj)-innerEdgeRadius_low;
                pick = (dist - minRi) / (maxRi - minRi) *1000;
                choose = round(pick);
                mask(ii,jj) = cosY(choose+1);
            elseif (r(ii,jj) < outerEdgeRadius_high) && (r(ii,jj) > outerEdgeRadius_low)
                dist = r(ii,jj)-outerEdgeRadius_low;
                pick = (dist - minRo) / (maxRo - minRo) *1000;
                choose = round(pick);
%                 try
                    mask(ii,jj) = 1-cosY(choose+1);
%                 catch
%                     mask(ii,jj) = 1-cosY(end);
%                     disp('OUTERFIX')
%                     dist
%                     outerror = outerror+1;
%                 end
            else
                mask(ii,jj) = 0;
            end
         end
      end
          end