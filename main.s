###########################################################################
# Upper bound constants for static memory reservation
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# System call constants
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64

###########################################################################
# ASCII character constants
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

.data
###########################################################################
# Data section with static memory reservations.
# Feel free to add more if needed.
###########################################################################
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"

W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME
    la a1, VOCAB_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    

    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME
    la a1, INPUT_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file


    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    la a0, W_Q_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file


    ###########################################################################
    # Parse W_Q matrix from buffer
    ###########################################################################
    la a0, W_Q_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer


    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    la a0, W_K_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file


    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    la a0, W_K_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer


    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    la a0, W_V_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file


    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer


    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    la a0, EMBEDDINGS_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file


    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer

    la t0, VOCAB_TOTAL_TOKENS
    sw a1, 0(t0)


    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR
    la a2, INPUT_BUFFER
    la a3, VOCAB_BUFFER
    jal ra, tokens_to_indices
    
    la t0, INPUT_TOTAL_TOKENS
    sw a1, 0(t0)

    
    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX
    la a1, VOCAB_EMBEDDINGS_MATRIX
    la a2, INPUT_INDICES_VECTOR
    
    la t0, INPUT_TOTAL_TOKENS
    lw a3, 0(t0)
    
    jal ra, build_input_embeddings_matrix
    
    
    ###########################################################################
    # Build matrix Q
    ###########################################################################
    la a0, Q_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)
    
    li a3, CONST_DIMENSION
    la a4, W_Q_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal ra, matrix_multiply
    

    ###########################################################################
    # Build matrix K
    ###########################################################################
    la a0, K_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)
    
    li a3, CONST_DIMENSION
    la a4, W_K_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal ra, matrix_multiply


    ###########################################################################
    # Build matrix V
    ###########################################################################
    la a0, V_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)
    
    li a3, CONST_DIMENSION
    la a4, W_V_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal ra, matrix_multiply


    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    la a0, SCORES_VECTOR
    la a1, Q_MATRIX
    la a2, K_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a3, 0(t0)
    
    li a4, CONST_DIMENSION
    addi a5, a3, -1
    
    jal ra, compute_scores


    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    la a1, SCORES_VECTOR
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)
    
    jal ra, argmax
    

    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    mv t1, a1
    la a1, V_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)
    
    li a3, CONST_DIMENSION
    mv a4, t1
    
    jal ra, select_vector_in_matrix


    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    la a1, VOCAB_EMBEDDINGS_MATRIX
    
    la t0, VOCAB_TOTAL_TOKENS
    lw a2, 0(t0)
    
    jal ra, decide_next_token
    
    # Walk through the vocabulary up to the desired index and print that word
    mv t1, a0                            # t1 = a0 - predicted token index
    la a0, VOCAB_BUFFER                  # a0 - pointer to the start of the vocabulary
    li t0, 0                             # t0 - current token index
    
    find_token:
        beq t0, t1, print_token          # t0 == t1 - found the predicted token
    
    skip_token:
        lb t2, 0(a0)                     # t2 - current vocabulary character
        li t3, CONST_CHAR_NEWLINE        # t3 - newline character
        beq t2, t3, next_token           # t2 == '\n' - move to the next token
        addi a0, a0, 1                   # a0 += 1 - advance within the current token
        j skip_token
    
    next_token:
        addi a0, a0, 1                   # a0 += 1 - point to the start of the next token
        addi t0, t0, 1                   # t0 += 1 - increment the current token index
        j find_token
    
    print_token:
        jal ra, print_predicted_token    # print the predicted token
    
    
    ###########################################################################
    # Terminate program successfully
    ###########################################################################
    
    li a0, 0
    j exit_with_code                                # Exit with code 0


# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read
read_file:
    mv t0, a0                               # t0 = a0 - save the filename
    mv t1, a1                               # t1 = a1 - save the buffer address
    mv t2, a2                               # t2 = a2 - save the maximum bytes to read
    
    # Open File
    mv a0, t0                               # a0 = t0 - filename
    li a1, 0                                # a1 = 0 - read mode
    
    li a7, CONST_SYSCALL_OPEN               # a7 - open syscall code
    ecall                                   # open the file
    
    mv t3, a0                               # t3 = a0 - file descriptor

    # Read File
    mv a0, t3                               # a0 = t3 - file descriptor
    mv a1, t1                               # a1 = t1 - destination buffer
    mv a2, t2                               # a2 = t2 - maximum number of bytes
    
    li a7, CONST_SYSCALL_READ               # a7 - read syscall code
    ecall                                   # read the file
    
    mv t4, a0                               # t4 = a0 - number of bytes read
    
    # Close File
    mv a0, t3                               # a0 = t3 - file descriptor
    
    li  a7, CONST_SYSCALL_CLOSE             # a7 - close syscall code
    ecall                                   # close the file
    
    mv a1, t4                               # a1 = t4 - return the number of bytes read
    jr ra
    

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer:
    mv t0, a0                         # t0 - pointer to the output matrix
    mv t1, a1                         # t1 - pointer to the start of the buffer
    
    li t5, 0                          # t5 - number currently being read
    li t3, 0                          # t3 - row counter
    li t4, 0                          # t4 - flag ---> 1-(has hyphen) | 0-(no hyphen)
    
parse_loop:
    lbu t2, 0(t1)                     # t2 - current buffer character
    
    li t6, CONST_CHAR_EOF             # t6 = CHAR_EOF
    beq t2, t6, parse_end             # if t2 = t6, reached the end of the buffer - stop
    
    li t6, CONST_CHAR_SPACE           # t6 = CHAR_SPACE
    beq t2, t6, parse_space           # if t2 = t6, handle space (end of the number read)
    
    li t6, CONST_CHAR_NEWLINE         # t6 = CHAR_NEWLINE
    beq t2, t6, parse_new_line        # if t2 = t6, handle the newline
    
    li t6, CONST_CHAR_HYPHEN          # t6 = CHAR_HYPHEN
    beq t2, t6, parse_hyphen          # if t2 = t6, handle the hyphen (activate the flag)

    li t6, 10                         # t6 = 10
    mul t5, t5, t6                    # t5 = t5 * t6
    
    li t6, CONST_CHAR_ZERO            # t6 = CHAR_ZERO
    sub t2, t2, t6                    # t2 -= t6      |  convert char to digit
    add t5, t5, t2                    # t5 = t5 + t2  |  -> t5 = (t5 * 10) + (character - 48) <-

    j parse_skip_char

parse_skip_char:
    addi t1, t1, 1                    # t1 += 1 - advance to the next character
    j parse_loop

parse_space:
    bnez t4, parse_symmetric          # t4 != 0 - if the flag is active, store the negative number
    j parse_store_num

parse_new_line:
    addi t3, t3, 1                    # t3 += 1 - increment the row counter
    j parse_space
    
parse_hyphen:
    li t4, 1                          # t4 = 1 - activate the flag
    j parse_skip_char

parse_store_num:
    sw t5, 0(t0)                      # store the number in the matrix
    addi t0, t0, 4                    # t0 += 4 - advance to the next position
    li t5, 0                          # t5 = 0 - reset the number read
    li t4, 0                          # t4 = 0 - reset the flag
    j parse_skip_char
 
parse_symmetric:
    neg t5, t5                        # t5 = -t5 - negate value
    j parse_store_num
   
parse_end:
    mv a1, t3                         # a1 = t3 - return the number of rows
    jr ra


# Converts the input tokens into their corresponding indices in the vocabulary.
# (in/out) a0: address of input indices vector to fill (int*)
# (out)    a1: size of input indices vector (number of tokens in input)
# (in)     a2: address to input buffer
# (in)     a3: address to vocabulary buffer
tokens_to_indices:
    mv t0, a0                             # t0 - pointer to the indices vector 
    mv t3, a3                             # t3 - save the start of the vocabulary

    
    li a1, 0                              # a1 - found tokens counter
    
next_input_word:
    li t1, 0                              # t1 - current index in the vocabulary
    mv a3, t3                             # a3 - return to the start of the vocabulary
    mv t2, a2                             # t2 - save the start of the current input token
    
loop:
    lbu t4, 0(a2)                         # t4 - current input character
    lbu t5, 0(a3)                         # t5 - current vocabulary character
    
    li t6, CONST_CHAR_EOF                 # t6 - end of buffer
    beq t4, t6, tokens_to_indices_end     # t4 == EOF - end the conversion
    
    bne t4, t5, next_vocab_word           # t4 != t5 - search in the next vocabulary token
    
    # If t4 and t5 are \n, the current input word is complete
    li t6, CONST_CHAR_NEWLINE             # t6 - newline
    bne t4, t6, continue_verifying        # t4 != '\n' - keep comparing characters
    bne t5, t6, continue_verifying        # t5 != '\n' - keep comparing characters
    
    j add_indice

continue_verifying:  
    addi a2, a2, 1                        # a2 += 1 - advance in the input
    addi a3, a3, 1                        # a3 += 1 - advance in the vocabulary
    
    j loop
    
next_vocab_word:
    lbu t5, 0(a3)                         # t5 - current vocabulary character
    
    li t6, CONST_CHAR_NEWLINE             # t6 - newline     
    beq t5, t6, back_on_loop_vocab        # t5 == '\n' - reached the next vocabulary token
    
    addi a3, a3, 1                        # a3 += 1 - keep skipping the current token
    j next_vocab_word
    
back_on_loop_vocab:
    addi t1, t1, 1                        # t1 += 1 - next vocabulary token index
    addi a3, a3, 1                        # a3 += 1 - point to the start of the next token
    mv a2, t2                             # a2 = t2 - return to the start of the input token

    j loop

add_indice:
    sw t1, 0(t0)                          # store the found index in the vector
    addi t0, t0, 4                        # t0 += 4 - advance in the indices vector
    addi a1, a1, 1                        # a1 += 1 - increment the number of tokens
    
    addi a2, a2, 1                        # a2 += 1 - move to the next input token
    j next_input_word                     

tokens_to_indices_end:
    jr ra


# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    mv t0, a0                                  # t0 - pointer to the output matrix
    mv t2, a2                                  # t2 - pointer to the indices vector
    
    li t3, 0                                   # t3 - processed token counter
    li t5, 4                                   # t5 - number of values per embedding
    
indices_array_loop:
    bge t3, a3, build_matrix_end               # t3 >= a3 - all tokens were processed
    
    lw t4, 0(t2)                               # t4 - current array value
    
    slli t1, t4, 4                             # t1 = t4 * 16 - embedding offset in the vocabulary
    add t1, a1, t1                             # t1 - pointer to the initial location to read the vocabulary matrix (each embedding has 4 columns)
    
    li t6, 0                                   # t6 - copied values counter
    
store_values:
    bge t6, t5, indices_array_next_loop        # t6 >= 4 - current embedding is finished
    
    lw a4, 0(t1)                               # a4 - current vocabulary embedding value
    sw a4, 0(t0)                               # store the value in the destination matrix
    
    addi t1, t1, 4                             # t1 += 4 - next vocabulary embedding value
    addi t0, t0, 4                             # t0 += 4 - next output matrix position
    addi t6, t6, 1                             # t6 += 1 - increment the counter
    
    j store_values

indices_array_next_loop:
    addi t3, t3, 1                             # t3 += 1 - next token
    addi t2, t2, 4                             # t2 += 4 - next input index

    j indices_array_loop
    
build_matrix_end:
    jr ra


# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*)
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*)
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)
matrix_multiply:
    mv t0, a0                             # t0 - pointer to the output matrix
    
    li t1, 0                              # t1 - row index of the first matrix

rows_loop:
    bge t1, a2, matrix_multiply_end       # t1 >= a2 - all rows were computed
    
    li t2, 0                              # t2 - column index of the second matrix
    
columns_loop:
    bge t2, a6, next_row                  # t2 >= a6 - move to the next row
    
    li t3, 0                              # t3 - dot product counter
    li t4, 0                              # t4 - result accumulator

multiply_loop:
    bge t3, a3, strore_value              # t3 >= a3 - dot product finished
    
    mul t5, t1, a3                        # t5 = row * number of columns in the first matrix
    add t5, t5, t3                        # t5 = t5 + t3 - element index in the first matrix
    slli t5, t5, 2                        # t5 = t5 * 4 - byte offset
    add t5, a1, t5                        # t5 - address of the first matrix element
    lw t5, 0(t5)                          # t5 - first matrix value
    
    mul t6, t3, a6                        # t6 = second matrix row * number of columns
    add t6, t6, t2                        # t6 = t6 + column - element index
    slli t6, t6, 2                        # t6 = t6 * 4 - byte offset
    add t6, a4, t6                        # t6 - address of the second matrix element
    lw t6, 0(t6)                          # t6 - second matrix value
    
    mul t6, t5, t6                        # t6 = t5 * t6 - product of both elements
    add t4, t4, t6                        # t4 += t6 - accumulate the result
    
    addi t3, t3, 1                        # t3 += 1 - next dot product element
    j multiply_loop

strore_value:
    sw t4, 0(t0)                          # store the computed value in the result matrix
    addi t0, t0, 4                        # t0 += 4 - next result matrix position
    j next_column
    
next_column:
    addi t2, t2, 1                        # t2 += 1 - next column
    j columns_loop
    
next_row:
    addi t1, t1, 1                        # t1 += 1 - next row
    j rows_loop

matrix_multiply_end:
    jr ra


# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)
compute_scores:
    addi sp, sp, -32                # reserve stack space
    sw ra, 0(sp)                    # save ra
    sw s0, 4(sp)                    # save s0
    sw s1, 8(sp)                    # save s1
    sw s2, 12(sp)                   # save s2
    sw s3, 16(sp)                   # save s3
    sw s4, 20(sp)                   # save s4
    sw s5, 24(sp)                   # save s5
    
    mv s0, a0                       # s0 - pointer to the scores vector
    mv s2, a2                       # s2 - pointer to matrix K
    mv s3, a3                       # s3 - number of rows
    mv s4, a4                       # s4 - number of columns

    mul t0, a5, s4                  # t0 = target index * number of columns
    slli t0, t0, 2                  # t0 = t0 * 4 - byte offset
    add s1, a1, t0                  # s1 - pointer to the target Q vector
    
    li s5, 0                        # s5 - current row index of K

scores_loop:
    bge s5, s3, compute_scores_end  # s5 >= s3 - all scores were computed
    
    mul t0, s5, s4                  # t0 = current row * number of columns
    slli t0, t0, 2                  # t0 = t0 * 4 - byte offset
    add t0, s2, t0                  # t0 - pointer to the current row of K
    
    # Prepare dot
    mv a1, s1                       # a1 - target Q vector
    mv a2, t0                       # a2 - current K vector
    mv a3, s4                       # a3 - vector size
    
    jal ra, dot
    
    sw a1, 0(s0)                    # store the computed score
    
    addi s0, s0, 4                  # s0 += 4 - next scores vector position
    addi s5, s5, 1                  # s5 += 1 - next row of K
    j scores_loop
    
compute_scores_end:
    lw ra, 0(sp)                    # restore ra
    lw s0, 4(sp)                    # restore s0
    lw s1, 8(sp)                    # restore s1
    lw s2, 12(sp)                   # restore s2
    lw s3, 16(sp)                   # restore s3
    lw s4, 20(sp)                   # restore s4
    lw s5, 24(sp)                   # restore s5
    
    addi sp, sp, 32                 # free stack space
    
    jr ra


# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    mul t0, a4, a3            # t0 = selected row * number of columns
    slli t0, t0, 2            # t0 = t0 * 4 - byte offset
    add a0, a1, t0            # a0 - address of the selected vector
    jr ra
    

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:
    addi sp, sp, -20          # reserve stack space

    sw ra, 0(sp)              # save ra
    sw s0, 4(sp)              # save s0
    sw s1, 8(sp)              # save s1
    sw s2, 12(sp)             # save s2
    sw s3, 16(sp)             # save s3

    mv s0, a0                 # s0 - pointer to the target vector
    mv s1, a1                 # s1 - pointer to the vocabulary embeddings
    mv s2, a2                 # s2 - number of vocabulary tokens

    slli t0, s2, 2            # t0 = s2 * 4 - scores vector size
    sub sp, sp, t0            # reserve space for the scores vector

    mv s3, sp                 # s3 - temporary scores vector address

calculate_scores_vector:
    mv a0, s3                 # a0 - temporary scores vector
    mv a1, s0                 # a1 - target vector
    mv a2, s1                 # a2 - vocabulary embeddings
    mv a3, s2                 # a3 - number of vocabulary tokens
    li a4, CONST_DIMENSION    # a4 - embedding dimension
    li a5, 0                  # a5 = 0 - target vector is at the start
    jal ra, compute_scores

search_bigger_score:
    mv a1, s3                 # a1 - temporary scores vector
    mv a2, s2                 # a2 - scores vector size

    jal ra, argmax

    mv t1, a1                 # t1 = a1 - index of the token with the highest score

decide_next_token_end:
    slli t0, s2, 2            # t0 = s2 * 4 - temporary vector size
    add sp, sp, t0            # free the temporary scores vector

    lw ra, 0(sp)              # restore ra
    lw s0, 4(sp)              # restore s0
    lw s1, 8(sp)              # restore s1
    lw s2, 12(sp)             # restore s2
    lw s3, 16(sp)             # restore s3

    addi sp, sp, 20           # free stack space

    mv a0, t1                 # a0 = t1 - return the predicted index

    jr ra

#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bgt t0, zero, overflow                          # If t0 > 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_loop                       # if SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall

#############################################################################################################
# Helper functions for printing and debugging.
#############################################################################################################

.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

# (in) a0: address of the predicted token (char*)
print_predicted_token:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
    # s0 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s0)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret
