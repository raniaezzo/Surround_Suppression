clear all; clc; close all;

%addpath(genpath('/Users/rania/Downloads/edfreadZip'))

fn = '/Users/rania/Downloads/S23_10b/trigger_test/E23-1606_0011.edf'; % E23-1566_0015.edf';

[data, annotations] = edfread(fn);

info = edfinfo(fn);

sys1 = data.POLCCEP_Ref{1,1};

for i = 2:length(data.POLCCEP_Ref)

    sys2 = data.POLCCEP_Ref{i, 1};

    sys1 = vertcat(1, sys1, sys2);

end


%%

thresholdRange = [sys1(end), 5000000]; % hard coded value - not sure how this is determined

% Detect impulses
impulses = detectImpulses(sys1, thresholdRange);

% Display the original data and the impulses
figure;
subplot(2, 1, 1);
plot(sys1);
title('Original Data');

subplot(2, 1, 2);
stem(impulses, 'Marker', 'none');
title('Impulses (1: Above thresholdMax or below thresholdMin, 0: Otherwise)');

disp('Total impulses:')
sum(impulses)

[even_intervals, odd_intervals] = compute_intervals(impulses);

%% Plot the range of trigger intervals
stem(2:2:numel(even_intervals)*2, even_intervals, 'r.')
hold on
stem(1:2:numel(odd_intervals)*2, odd_intervals, 'g.')
hold on
yline(900)
hold on
yline(500)
ylim([400 1350])
ylabel('Duration (ms)')
xlabel('Trigger instance (count)')
legend({'stimulus','ISI'})

%% Print values to check trigger periods:

disp('Stimulus period range:')
disp('MIN:')
min(even_intervals)
disp('MAX:')
max(even_intervals)
disp('ISI period range:')
disp('MAX (between blocks):')
[sorted_data, indices] = sort(odd_intervals);
top_5_indices = indices(end-4:end); % these are the intervals between blocks
betw_block_ISIs = odd_intervals(top_5_indices)
disp('INTERVALS (within blocks):')
other_ISI_indices = indices(1:end-5);
formal_ISIs = odd_intervals(other_ISI_indices);
disp('min:')
min(formal_ISIs)
disp('max:')
max(formal_ISIs)


%%
function cleanedImpulses = detectImpulses(data, thresholdRange)
    % Input:
    %   - data: an n x 1 array of numeric values
    %   - thresholdRange: a 1x2 array specifying the threshold range [min, max]

    % Validate input arguments
    if ~isnumeric(data) || ~isvector(data) || ~isnumeric(thresholdRange) || numel(thresholdRange) ~= 2
        error('Invalid input. Input data should be a numeric vector, and thresholdRange should be a 1x2 numeric array.');
    end

    % Extract threshold values
    thresholdMin = thresholdRange(1);
    thresholdMax = thresholdRange(2);

    % Find impulses (values above thresholdMax or below thresholdMin)
    impulses = (data > thresholdMax) | (data < thresholdMin);
    cleanedImpulses = impulses;
    for i = 1:length(impulses) - 1
        if impulses(i) == 1
            cleanedImpulses(i + 1:min(i + 100, end)) = false;
        end
    end
end

function [even_intervals, odd_intervals] = compute_intervals(impulses)
    even_intervals = [];
    odd_intervals = [];
    
    even_count = 0;
    odd_count = 0;
    is_even = false;
    
    for i = 1:length(impulses)
        impulse = impulses(i);
        
        if impulse == 1
            if is_even
                even_intervals = [even_intervals, even_count];
                even_count = 0;
            else
                odd_intervals = [odd_intervals, odd_count];
                odd_count = 0;
            end
            
            is_even = ~is_even;
        else
            if is_even
                even_count = even_count + 1;
            else
                odd_count = odd_count + 1;
            end
        end
    end
   
end
