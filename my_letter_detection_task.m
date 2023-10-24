function my_letter_detection_task(scr, const, color, trialLetterString)
x_mid = scr.windCenter_px(1);
y_mid = scr.windCenter_px(2);
textstring = cellstr(trialLetterString);
sizeT = size(textstring);
lines = sizeT(1)+2;
bound = Screen('TextBounds',const.window,textstring{1,:});
espace = ((const.text_size)*1.50);
first_line = y_mid - ((round(lines/2))*espace);

for t_lines = 1:sizeT(1)
    Screen('DrawText',const.window,textstring{t_lines,:},x_mid-bound(3)/2,first_line*espace, color);
end
