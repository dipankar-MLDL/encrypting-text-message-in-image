%% Script: encode_image.m
% Encodes text into the Alpha channel of a PNG image using a 36-bit cipher.

clear; clc;

%% 1. Base 6-bit Map and Clean ASCII Cipher Mapping
base_chars = ['A':'Z', '0':'9'];
base_keys  = num2cell(base_chars);
base_vals  = arrayfun(@(x) dec2bin(x, 6), 0:35, 'UniformOutput', false);
BASE_6BIT_MAP = containers.Map(base_keys, base_vals);

cipher_pairs = {
    % Uppercase Letters
    'A', 'ACGEO5'; 'B', 'E7GHPO'; 'C', 'B9AF5Q'; 'D', 'FI3B76'; 'E', 'DGA8VK'; ...
    'F', 'IL2B69'; 'G', 'OD3B8N'; 'H', '3GED93'; 'I', '7BXVYZ'; 'J', 'JK1WBI'; ...
    'K', '7JLWV6'; 'L', '9BSG5M'; 'M', 'OZ24KJ'; 'N', 'QPO34L'; 'O', 'L9IAF4'; ...
    'P', 'K7L2VP'; 'Q', 'Z1M4D7'; 'R', 'E033VO'; 'S', 'GL8SV4'; 'T', '9BNZC4'; ...
    'U', '1C098S'; 'V', '7LB98V'; 'W', '5JLXCT'; 'X', 'I1MBIW'; 'Y', 'B7LLAY'; 'Z', 'EQTYU3'; ...
    % Lowercase Letters
    'a', 'MA194B'; 'b', 'NB285C'; 'c', 'OC376D'; 'd', 'PD467E'; 'e', 'QE558F'; ...
    'f', 'RF649G'; 'g', 'SG730H'; 'h', 'TH821I'; 'i', 'UI912J'; 'j', 'VJ003K'; ...
    'k', 'WK194L'; 'l', 'XL285M'; 'm', 'YM376N'; 'n', 'ZN467O'; 'o', 'AO558P'; ...
    'p', 'BP649Q'; 'q', 'CQ730R'; 'r', 'DR821S'; 's', 'ES912T'; 't', 'FT003U'; ...
    'u', 'GU194V'; 'v', 'HV285W'; 'w', 'IW376X'; 'x', 'JX467Y'; 'y', 'KY558Z'; 'z', 'LZ6490'; ...
    % Digits
    '0', 'AECEN6'; '1', 'BMK3CU'; '2', 'LHI3CI'; '3', 'JMI26C'; '4', 'NKL9GE'; ...
    '5', 'GHZAOV'; '6', 'MNK2BG'; '7', 'LMZADW'; '8', 'EGIWX7'; '9', 'LEG4VO'; ...
    % Standard ASCII Symbols & Punctuation
    '.', 'GGCAGE'; ',', 'L9EWET'; '"', 'G7934G'; '''', 'PMQUGX'; ...
    '?', 'HCDWB9'; '!', 'LIMWNI'; '+', 'OEQWNZ'; '=', '9CQWNZ'; ...
    '-', 'QLDWNZ'; '%', 'L9BLHT'
};

% Build 36-bit lookup dictionary
CHAR_MAP_36BIT = containers.Map('KeyType', 'char', 'ValueType', 'char');
for i = 1:size(cipher_pairs, 1)
    ch = cipher_pairs{i, 1};
    code = cipher_pairs{i, 2};
    bin36 = '';
    for c = code
        bin36 = [bin36, BASE_6BIT_MAP(c)]; %#ok<AGROW>
    end
    CHAR_MAP_36BIT(ch) = bin36;
end

STOP_TOKEN = repmat('1', 1, 36);

%% 2. File Loading & Input
[base_file, base_path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files (*.png, *.jpg, *.bmp)'}, 'Select Cover Image');
if isequal(base_file, 0)
    disp('User canceled image selection.');
    return;
end

input_image_path = fullfile(base_path, base_file);
output_path = 'encoded_custom_image.png';

[rgb_img, ~, ~] = imread(input_image_path);

% Ensure image is 3-channel RGB
if size(rgb_img, 3) == 1
    rgb_img = repmat(rgb_img, [1, 1, 3]);
elseif size(rgb_img, 3) == 4
    rgb_img = rgb_img(:, :, 1:3);
end

[height, width, ~] = size(rgb_img);
max_pixels = height * width;

user_message = input('Enter message to encode: ', 's');

%% 3. Construct Payload
alpha_payload = [];

for idx = 1:length(user_message)
    ch = user_message(idx);
    if ch == ' '
        alpha_payload(end + 1) = 250; %#ok<AGROW>
    elseif isKey(CHAR_MAP_36BIT, ch)
        bits = CHAR_MAP_36BIT(ch);
        for b = bits
            if b == '1'
                alpha_payload(end + 1) = 255; %#ok<AGROW>
            else
                alpha_payload(end + 1) = 254; %#ok<AGROW>
            end
        end
    else
        fprintf("Warning: Character '%s' not found in cipher. Skipped.\n", ch);
    end
end

% Append 36-bit Stop Delimiter
for b = STOP_TOKEN
    if b == '1'
        alpha_payload(end + 1) = 255; %#ok<AGROW>
    else
        alpha_payload(end + 1) = 254; %#ok<AGROW>
    end
end

if length(alpha_payload) > max_pixels
    error('Message exceeds image capacity! Required: %d pixels, Capacity: %d pixels.', ...
          length(alpha_payload), max_pixels);
end

% Pad remaining pixels with 253
padding_len = max_pixels - length(alpha_payload);
alpha_payload = [alpha_payload, repmat(253, 1, padding_len)];

%% 4. Assemble and Export
% Reshape with transpose to guarantee row-major (C-order) compatibility with Python
alpha_plane = uint8(reshape(alpha_payload, [width, height])');

imwrite(rgb_img, output_path, 'png', 'Alpha', alpha_plane);
fprintf("\nMessage successfully embedded! Saved as '%s'.\n", output_path);

figure('Name', 'Encoded Image Preview');
imshow(rgb_img);
title('Encoded Image Preview');