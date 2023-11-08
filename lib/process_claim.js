const _ = require('lodash');
const mysql = require('mysql');
const uuid = require('uuid');

class InvalidClaimantError extends Error {}
exports.InvalidClaimantError = InvalidClaimantError;

async function processClaim(db, claimObj) {
    // FIXME: Implement.
    return;
}

exports.processClaim = processClaim;
