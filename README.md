# "Game of the Bank" test assignment

## Description

This project is a Solidity language contract to implement the "Bank Game". In the game, participants can send ethereal funds to the contract, and the player who sends the highest amount will receive all the funds in the contract.

## Tests.

There are tests developed for this project which can be run to check if the contract works correctly. The tests use the Hardhat framework to develop and test smart contracts on Ethereum.

#### Running the tests

1. Install Hardhat if it is not already installed by running the following command at the command line:
   ```
   npm install --save-dev hardhat
   ```

2. Go to the project directory and run the following command to install the project dependencies:
   ```
   npm install
   ```

3. Run the tests with the command:
   ```
   npx hardhat test
   ```

   The tests will automatically check various aspects of the contract, including sending funds, checking balances, and withdrawals.