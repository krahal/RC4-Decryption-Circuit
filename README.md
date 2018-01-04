# RC4-Decryption-Circuit

This projected was created for our CPEN 311: Digital Systems Design course. My partner, Darren, and I developed an RC4 decrpytion circuit programmed in SystemVerilog using Quartus and ModelSim.

We developed an RC4 decryption circuit by designing and programming a finite state machine that reads an encrypted message from a ROM and decrypts it using the RC4 algorithm. We created and instantiated the RAM and ROM using the Quartus MegaWizard.

The decrpytion circuit was augemnted into a cracking circuit which executes a ‘brute-force’ attack on the RC4 by cycling through the entire keyspace, and stopping and writing the result to a RAM when successfully decrypted.

Integration and circuit modules created by us were tested using ModelSim simulations.
