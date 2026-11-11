import numpy as np
from PIL import Image
import matplotlib.pyplot as plt

BASE_6BIT_MAP = {
    'A': '000000', 'B': '000001', 'C': '000010', 'D': '000011',
    'E': '000100', 'F': '000101', 'G': '000110', 'H': '000111',
    'I': '001000', 'J': '001001', 'K': '001010', 'L': '001011',
    'M': '001100', 'N': '001101', 'O': '001110', 'P': '001111',
    'Q': '010000', 'R': '010001', 'S': '010010', 'T': '010011',
    'U': '010100', 'V': '010101', 'W': '010110', 'X': '010111',
    'Y': '011000', 'Z': '011001',
    '0': '011010', '1': '011011', '2': '011100', '3': '011101',
    '4': '011110', '5': '011111', '6': '100000', '7': '100001',
    '8': '100010', '9': '100011'
}

# 6-char Cipher mapping including Uppercase, Lowercase, Digits, and Punctuation
CUSTOM_CIPHER = {
    # Uppercase Letters
    'A': 'ACGEO5', 'B': 'E7GHPO', 'C': 'B9AF5Q', 'D': 'FI3B76', 'E': 'DGA8VK',
    'F': 'IL2B69', 'G': 'OD3B8N', 'H': '3GED93', 'I': '7BXVYZ', 'J': 'JK1WBI',
    'K': '7JLWV6', 'L': '9BSG5M', 'M': 'OZ24KJ', 'N': 'QPO34L', 'O': 'L9IAF4',
    'P': 'K7L2VP', 'Q': 'Z1M4D7', 'R': 'E033VO', 'S': 'GL8SV4', 'T': '9BNZC4',
    'U': '1C098S', 'V': '7LB98V', 'W': '5JLXCT', 'X': 'I1MBIW', 'Y': 'B7LLAY', 'Z': 'EQTYU3',

    # Lowercase Letters
    'a': 'MA194B', 'b': 'NB285C', 'c': 'OC376D', 'd': 'PD467E', 'e': 'QE558F',
    'f': 'RF649G', 'g': 'SG730H', 'h': 'TH821I', 'i': 'UI912J', 'j': 'VJ003K',
    'k': 'WK194L', 'l': 'XL285M', 'm': 'YM376N', 'n': 'ZN467O', 'o': 'AO558P',
    'p': 'BP649Q', 'q': 'CQ730R', 'r': 'DR821S', 's': 'ES912T', 't': 'FT003U',
    'u': 'GU194V', 'v': 'HV285W', 'w': 'IW376X', 'x': 'JX467Y', 'y': 'KY558Z', 'z': 'LZ6490',

    # Digits
    '0': 'AECEN6', '1': 'BMK3CU', '2': 'LHI3CI', '3': 'JMI26C', '4': 'NKL9GE',
    '5': 'GHZAOV', '6': 'MNK2BG', '7': 'LMZADW', '8': 'EGIWX7', '9': 'LEG4VO',

    # Symbols & Punctuation
    '.': 'GGCAGE', ',': 'L9EWET', '“': 'G7934G', '”': 'ALDTHB', '‘': 'PMQUGX',
    '’': 'LCMWFB', '?': 'HCDWB9', '!': 'LIMWNI', '+': 'OEQWNZ', '=': '9CQWNZ',
    '-': 'QLDWNZ', '%': 'L9BLHT'
}

CHAR_MAP_36BIT = {
    char: "".join(BASE_6BIT_MAP[c] for c in code)
    for char, code in CUSTOM_CIPHER.items()
}
CHAR_MAP_36BIT['"'] = CHAR_MAP_36BIT['“']
CHAR_MAP_36BIT["'"] = CHAR_MAP_36BIT['‘']

# 36-bit delimiter
STOP_TOKEN = '1' * 36

def encode_message_into_user_image(image_path: str, message: str, output_path: str = "encoded_custom_image.png") -> Image.Image:
    img = Image.open(image_path).convert('RGB')
    rgb_arr = np.array(img, dtype=np.uint8)
    height, width, _ = rgb_arr.shape
    max_pixels = height * width

    alpha_payload = []

    for char in message:
        if char == ' ':
            alpha_payload.append(250)
        elif char in CHAR_MAP_36BIT:
            for bit in CHAR_MAP_36BIT[char]:
                alpha_payload.append(255 if bit == '1' else 254)
        else:
            print(f"Warning: Character '{char}' not found in cipher. Skipped.")

    # Append Stop Delimiter (36 bits)
    for bit in STOP_TOKEN:
        alpha_payload.append(255 if bit == '1' else 254)

    if len(alpha_payload) > max_pixels:
        raise ValueError(
            f"Message exceeds image capacity! Required: {len(alpha_payload)} pixels, Capacity: {max_pixels} pixels."
        )

    # Pad remaining pixels with 253 to differentiate from bits 254/255
    alpha_payload.extend([253] * (max_pixels - len(alpha_payload)))

    alpha_plane = np.array(alpha_payload, dtype=np.uint8).reshape((height, width, 1))
    rgba_arr = np.concatenate([rgb_arr, alpha_plane], axis=-1)
    encoded_rgba_img = Image.fromarray(rgba_arr, mode='RGBA')

    encoded_rgba_img.save(output_path, format="PNG")
    print(f"\nMessage successfully embedded! Saved as '{output_path}'.")
    return encoded_rgba_img


# --- Execution ---
print("Step 1: Select cover image")
cover_image_path = input("Enter the filename or path of the cover image (e.g., 'image.png'): ")

if cover_image_path:
    user_message = input("\nStep 2: Enter message to encode: ")

    if user_message:
        # Define the exact absolute path where you want the file saved
        save_directory = r"F:\Python machine learning deep learning quantum projects\encoded_custom_image.png"
        
        # Pass the absolute path to the function
        stego_img = encode_message_into_user_image(cover_image_path, user_message, save_directory)
        
        plt.figure(figsize=(5, 5))
        plt.imshow(stego_img)
        plt.title("Encoded Image Preview")
        plt.axis("off")
        plt.show()
        
        print(f"\nDone! The image has been saved to: {save_directory}")