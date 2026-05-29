# RISC-V Mini-Transformer

A simplified Transformer-inspired attention model implemented in RISC-V Assembly for the **Introduction to Computer Architecture** course at **Instituto Superior Técnico**.

### Features
- Complete Mini-Transformer inference pipeline implemented in RISC-V Assembly
- File-based loading of vocabulary, input tokens, embeddings, and weight matrices
- Token-to-index conversion using a fixed vocabulary
- Input embedding matrix construction from vocabulary embeddings
- Matrix multiplication for Q, K, and V generation
- Attention score calculation through dot products between Q and K vectors
- Argmax-based selection of the most relevant token
- Next-token prediction by comparing the final vector with vocabulary embeddings
- Modular helper routines for file reading, matrix parsing, matrix multiplication, dot product, argmax, vector selection, and debug printing
- Overflow detection in dot product operations

### Pipeline
```txt
Sentence -> Tokens -> Input Embedding Matrix (E) -> Q, K, V -> Scores -> Most Relevant Token Selection -> Final Vector -> Next Token Prediction
```

### Files in This Repository
- `main.s` - main RISC-V Assembly implementation of the Mini-Transformer pipeline
- `vocab.txt` - fixed vocabulary used by the model
- `input.txt` - input sentence, with one token per line
- `embeddings.txt` - embedding matrix for all vocabulary tokens
- `W_Q.txt` - Query weight matrix
- `W_K.txt` - Key weight matrix
- `W_V.txt` - Value weight matrix
- `expected_outputs_from_inputs.txt` - example inputs and their expected predictions

### Run
This project is intended to run in **Ripes** using a 32-bit RISC-V processor with the multiplication extension enabled.

Make sure the following files are in the same execution directory as `main.s`:

- `vocab.txt`
- `input.txt`
- `embeddings.txt`
- `W_Q.txt`
- `W_K.txt`
- `W_V.txt`

Then open `main.s` in Ripes and run the program.

For the default `input.txt`:
```txt
a
boy
eats
```

The expected output is:
```txt
=== Decision ===
food
```

Additional provided test cases are listed in:
- `expected_outputs_from_inputs.txt`

### Author
*Ricardo Vicente*
