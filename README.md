# Encrypting Text Messages in Image Alpha Planes

A lightweight steganography tool written in Python (with companion MATLAB scripts) that hides secret text messages inside the alpha (transparency) channel of PNG images. Developed as a **5th Semester Digital Image and Video Processing (DIVP) Mini Project**.

Instead of tweaking RGB values like traditional LSB (Least Significant Bit) steganography—which can subtly alter colors or introduce noise artifacts—this method leaves the visible image entirely untouched and encodes data strictly into the 4th (Alpha) channel.

---

## 👥 Authors

- **Dipankar Chakraborty** ([@dipankar-MLDL](https://github.com/dipankar-MLDL))
- **Debraj Chanda**

*B.Tech in Electronics and Communication Engineering*  
*5th Semester — Digital Image and Video Processing (DIVP) Mini Project*

---

## How It Works

The encoding and decoding process follows a custom substitution and bit-mapping workflow:

1. **Character to 6-Char Token**: Each alphanumeric character and punctuation mark is mapped to a unique 6-character cipher string (e.g., `'A'` becomes `'ACGEO5'`).
2. **Token to 36 Bits**: Each character in that 6-character token is converted into a 6-bit binary sequence using a custom Base-6 map. This creates an exact **36-bit representation** for every character.
3. **Alpha Channel Injection**:
   - `250` represents a space character (`' '`).
   - `254` represents binary `0`.
   - `255` represents binary `1`.
   - A 36-bit sequence of `1`s (`STOP_TOKEN`) marks the end of the secret text.
   - The remaining pixels in the alpha plane are padded with `253`.
4. **Extraction**: The decoder iterates over the flattened alpha plane, groups incoming bits into 36-bit blocks, and maps them back to the original characters. When it encounters `253` or the stop token, it stops immediately.

---

## Project Structure

```text
encrypting-text-message-in-image/
│
├── image_encoding_message.py     # Python script to embed secret text into cover image
├── image_decoding_message.py     # Python script to extract and read the secret text
├── message_encoding_rgba.m       # MATLAB counterpart for encoding
├── message_decoding_rgba.m       # MATLAB counterpart for decoding
└── README.md
