#!/usr/bin/env node

const yargs = require('yargs');
const _ = require('lodash');
// load_claims.js

const readline = require('readline');
const { createConnection, process_claim } = require('../lib/process_claim');

function main() {
  const db = createConnection();
  let claimsCount = 0; // Counter to keep track of the number of claims being processed

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  rl.on('line', (line) => {
    claimsCount++; // Increment the counter when a new claim is read
    process_claim(db, line, (error) => {
      claimsCount--; // Decrement the counter when a claim processing is finished
      if (error) {
        if (error.message === 'Claimant not found') {
          // Log additional details if the claimant is not found
          const claimData = JSON.parse(line);
          console.error(`Error processing claim for ${claimData.first_name} ${claimData.last_name}: Claimant not found`);
        } else {
          console.error(`Error processing claim: ${error.message}`);
        }
      } else {
        console.log('Claim processed successfully.');
      }
      // Close the database connection only when all claims have been processed
      if (claimsCount === 0) {
        console.log('All claims processed. Closing the database connection.');
        db.end();
      }
    });
  });

  rl.on('close', () => {
    // If there are no claims to process, close the database connection
    if (claimsCount === 0) {
      console.log('No claims to process. Closing the database connection.');
      db.end();
    }
  });
}

main();

