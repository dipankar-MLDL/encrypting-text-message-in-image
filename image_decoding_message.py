import numpy as np
from PIL import Image

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

REV_CHAR_MAP = {
    "".join(BASE_6BIT_MAP[c] for c in code): char
    for char, code in CUSTOM_CIPHER.items()
}

STOP_TOKEN = '1' * 36

def decode_text_from_alpha_plane(image_path: str) -> str:
    img = Image.open(image_path)
    if img.mode != 'RGBA':
        raise ValueError("Image does not contain an Alpha plane!")

    alpha_plane = np.array(img)[:, :, 3].flatten()
    decoded_chars = []
    current_bits = []

    for val in alpha_plane:
        if val == 250:  # Space delimiter
            decoded_chars.append(' ')
        elif val in (254, 255):
            current_bits.append('1' if val == 255 else '0')

            # Matches the 36-bit chunk per character
            if len(current_bits) == 36:
                bit_str = "".join(current_bits)
                if bit_str == STOP_TOKEN:
                    break
                if bit_str in REV_CHAR_MAP:
                    decoded_chars.append(REV_CHAR_MAP[bit_str])
                current_bits = []
        elif val == 253:  # Padding delimiter reached
            break

    return "".join(decoded_chars)


# --- Execution ---
print("Select the encoded image to decode:")
encoded_image_path = input("Enter the exact filename or path (e.g., 'encoded_custom_image.png'): ")

if encoded_image_path:
    try:
        extracted_message = decode_text_from_alpha_plane(encoded_image_path)
        print("\n" + "=" * 40)
        print(f"[+] Decoded Message: '{extracted_message}'")
        print("=" * 40)
    except Exception as e:
        print(f"\n[!] Error: {e}")