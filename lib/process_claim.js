const _ = require('lodash');
const mysql = require('mysql2');
const uuid = require('uuid');

class InvalidClaimantError extends Error {}
exports.InvalidClaimantError = InvalidClaimantError;

// Function to create a MySQL connection
function createConnection() {
    return mysql.createConnection({
      host: 'localhost',
      port: 13306,
      user: 'root',
      password: 'tamagotchi',
      database: 'claims'
    });
  }
  
  // Function to process a claim with the signature process_claim(db, claim)
  function process_claim(db, claim, callback) {
    // Parse the claim JSON
    const claimData = JSON.parse(claim);
    // SQL query to find the right claimant_id (either employee_id or dependent_id)
    const query = `
      SELECT employee_id AS claimant_id, 'employee' AS claimant_type
      FROM employees
      WHERE ssn_suffix = ? AND last_name = ? AND first_name = ? AND date_of_birth = ?
      UNION
      SELECT dependent_id AS claimant_id, 'dependent' AS claimant_type
      FROM dependents
      WHERE ssn_suffix = ? AND last_name = ? AND first_name = ? AND date_of_birth = ?
    `;
  
    // Parameters for the SQL query
    const queryParams = [
      claimData.ssn_suffix,
      claimData.last_name,
      claimData.first_name,
      claimData.date_of_birth,
      claimData.ssn_suffix,
      claimData.last_name,
      claimData.first_name,
      claimData.date_of_birth
    ];
  
    // Execute the query to find the claimant_id
    db.query(query, queryParams, (error, results) => {
      if (error) {
        return callback(error);
      }
      if (results.length === 0) {
        return callback(new Error('Claimant not found'));
      }
      
      // If a claimant is found, insert the claim
      const claimant = results[0];
      const insertQuery = `
        INSERT INTO claims (claimant_id, claimant_type, claim_date, claim_amount)
        VALUES (?, ?, ?, ?)
      `;
      const insertParams = [
        claimant.claimant_id,
        claimant.claimant_type,
        claimData.claim_date,
        claimData.claim_amount
      ];
  
      // Execute the insert query
      db.query(insertQuery, insertParams, (insertError) => {
        if (insertError) {
          return callback(insertError);
        }
        callback(null);
      });
    });
  }
  
  module.exports = {
    createConnection,
    process_claim
  };
