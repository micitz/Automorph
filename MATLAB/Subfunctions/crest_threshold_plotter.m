% This script plots the crest threshold over time during the run for both
% passes
%
% Michael Itzkin, 6/1/2018
%-----------------------------------------------------------------------%

Title = sprintf('Crest Thresholds for %s %s', location(1:end-1), year);
threshold_figure = figure('name', Title);

hold on
grid on
box on

line([0 length(all_thresholds(1,:))],...
    [nanmean(all_thresholds(1,:)) nanmean(all_thresholds(1,:))],...
    'Color', 'b',...
    'LineStyle', '--') 
line([0 length(all_thresholds(2,:))],...
    [nanmean(all_thresholds(2,:)) nanmean(all_thresholds(2,:))],...
    'Color', 'r',...
    'LineStyle', '--') 
plot(all_thresholds(1,:), 'b', 'LineWidth', 2)
plot(all_thresholds(2,:), 'r', 'LineWidth', 2)

xticks(1:15:length(all_thresholds(1,:)))
xlim([1 length(all_thresholds)])

set(gca, 'FontWeight', 'bold')
xlabel('Profile Number')
ylabel('Crest Threshold (m NAVD88)')
title(Title)

save_name = sprintf('%s%s%s%s%s.png', location(1:end-1), filesep, year, filesep, Title);
saveas(threshold_figure, save_name, 'png')
close()