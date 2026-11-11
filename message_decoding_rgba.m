%% Script: decode_image.m
% Extracts and decodes the message embedded in the Alpha channel.

clear; clc;

%% 1. Base 6-bit Map and Clean ASCII Reverse Cipher Mapping
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

% Build 36-bit reverse lookup dictionary
REV_CHAR_MAP = containers.Map('KeyType', 'char', 'ValueType', 'char');
for i = 1:size(cipher_pairs, 1)
    ch = cipher_pairs{i, 1};
    code = cipher_pairs{i, 2};
    bin36 = '';
    for c = code
        bin36 = [bin36, BASE_6BIT_MAP(c)]; %#ok<AGROW>
    end
    REV_CHAR_MAP(bin36) = ch;
end

STOP_TOKEN = repmat('1', 1, 36);

%% 2. File Selection & Alpha Extraction
[base_file, base_path] = uigetfile({'*.png', 'PNG Images (*.png)'}, 'Select Encoded Image');
if isequal(base_file, 0)
    disp('User canceled image selection.');
    return;
end

encoded_image_path = fullfile(base_path, base_file);
[~, ~, alpha_plane] = imread(encoded_image_path);

if isempty(alpha_plane)
    error('Image does not contain an Alpha channel!');
end

%% 3. Decode Bitstream
% Transpose before flattening to read row-major pixels identically to Python
alpha_plane_flat = reshape(alpha_plane', 1, []);

decoded_chars = '';
current_bits = '';

for idx = 1:length(alpha_plane_flat)
    val = alpha_plane_flat(idx);
    
    if val == 250
        decoded_chars = [decoded_chars, ' ']; %#ok<AGROW>
    elseif val == 254 || val == 255
        if val == 255
            current_bits = [current_bits, '1']; %#ok<AGROW>
        else
            current_bits = [current_bits, '0']; %#ok<AGROW>
        end
        
        if length(current_bits) == 36
            if strcmp(current_bits, STOP_TOKEN)
                break;
            end
            
            if isKey(REV_CHAR_MAP, current_bits)
                decoded_chars = [decoded_chars, REV_CHAR_MAP(current_bits)]; %#ok<AGROW>
            end
            current_bits = '';
        end
    elseif val == 253
        break;
    end
end

fprintf('\n%s\n', repmat('=', 1, 40));
fprintf("[+] Decoded Message: '%s'\n", decoded_chars);
fprintf('%s\n', repmat('=', 1, 40));