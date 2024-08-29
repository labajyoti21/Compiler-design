# Python Compiler

This project includes a lexer and parser for processing input files. Here are the instructions for using it:

## Running the Lexer and Parser

1. Clone the repository to your local machine.
2. Navigate to the project directory.
3. Run the following command to generate the lexer and parser and compile the program:

    ```
    make pdf 
    ```

   This will generate an `output.pdf` file which contains the Abstract Syntax Tree (AST) for the input in the `tests/test1.py` file.
   You can also run the make svg command if you want to generate a svg file instead of pdf.

## Manual Input

If you want to supply your own input files and/or output, follow these steps:


1. Run the following command to generate the lexer and parser:

    ```
    make 
    ```

   This will compile the lexer and parser and generate an executable named `output`.

2. Run the following command to manually execute the lexer and parser:

    ```
    ./output your_input_file 
    ```
    You can also supply your input and output files with `-input` and `-output` arguments respectively.
    Run the executable with `-help` arguments for more information. 

3. The above command will generate a dot file. The default name for the dot file is `output.dot`.

4. Run one of the following command to generate the corresponding AST in pdf or svg form correspondingly:

     ```
    dot -Tpdf dot_file_name -o output.pdf
    dot -Tsvg dot_file_name -o output.svg
    ```
    Replace the dot_file_name with the name of your dot file.
    This will generate a output.pdf or output.svg accordingly file which contains the AST.

## Additional Information

- Make sure you have `flex`, `bison` and `graphviz` installed on your system to build the lexer, parser and to generate the AST.

