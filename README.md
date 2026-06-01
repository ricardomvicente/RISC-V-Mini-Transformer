# RISC-V Mini-Transformer

A simplified Transformer-inspired attention model implemented in RISC-V Assembly for the **Introduction to Computer Architecture** course at **Instituto Superior Técnico**.

### Features
- Mini-Transformer inference pipeline in RISC-V Assembly
- File loading for tokens, embeddings, and weight matrices
- Token-to-index conversion with a fixed vocabulary
- Embedding matrix construction for input tokens
- Q, K, and V matrix generation
- Attention scoring with dot products
- Argmax-based relevant token selection
- Next-token prediction from vocabulary embeddings
- Modular routines for parsing, matrix operations, and debugging
- Dot product overflow detection

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
*<a href="https://github.com/ricardomvicente" style="text-decoration: none !important; color: inherit !important;">Ricardo Vicente</a>
& 
<a href="https://github.com/franciscof2007" style="text-decoration: none !important; color: inherit !important;">Francisco Frieza</a> 
& 
<a style="text-decoration: none !important; color: inherit !important;">Francisco Pereira</a>*
