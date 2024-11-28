```markdown
# Property Tokenization Smart Contract (Clarity 2.0)

## Overview

This Clarity smart contract, **`property-tokenization.clar`**, provides a robust framework for tokenizing real estate properties as NFTs (Non-Fungible Tokens). The contract enables seamless property registration, ownership management, transfer validation, and maintenance tracking. By leveraging the capabilities of the Stacks blockchain, this contract ensures a transparent and immutable record of property-related transactions, enhancing trust and efficiency in real estate management.

---

## Features

- **Tokenization of Real Estate Properties**  
  Each property is represented as an NFT, uniquely identified by a `property-id`.

- **Ownership Management**  
  Ownership is tracked and verified on-chain, ensuring only valid owners can perform operations on their properties.

- **Property Details Management**  
  Store and retrieve details like property category, location, value, maintenance logs, zoning information, and more.

- **Transfer Mechanisms**  
  Secure ownership transfers with built-in validation to prevent unauthorized transactions.

- **Comprehensive Property Tracking**  
  Track additional attributes such as property age, appraisal history, insurance status, and tax information.

- **Batch Operations**  
  Support for bulk property registration.

- **Listing and Delisting**  
  Mark properties as listed or delisted for sale.

- **Property Validation**  
  Built-in functions to validate property data and ownership.

---

## Usage

### Prerequisites
- **Clarity 2.0** is required to deploy and interact with this contract.
- This contract must be deployed on a Stacks blockchain-compatible environment.

---

## Deployment

To deploy this smart contract:

1. Save the contract code as `property-tokenization.clar`.
2. Deploy it using your preferred method, such as the Stacks CLI or a blockchain explorer with deployment capabilities.
3. Assign the deploying principal as the contract owner.

---

## Contract Architecture

### Constants
- **`contract-owner`**: The principal address of the contract owner.
- **Error Codes**:  
  - **`err-owner-only`** (`u100`): Only the contract owner can perform the operation.  
  - **`err-not-property-owner`** (`u101`): Caller is not the owner of the specified property.  
  - **`err-property-not-found`** (`u103`): Specified property does not exist.  

### Data Variables
- **`property`**: NFT representing unique properties.
- **`last-property-id`**: Tracks the most recently assigned property ID.

### Mappings
- **`property-data`**: Maps `property-id` to its details (ASCII string, max 256 chars).
- **`property-owners`**: Maps `property-id` to the owner's principal address.
- Additional mappings cover:
  - Listing status
  - Category, location, and value
  - Maintenance logs
  - Insurance and tax information

---

## Key Functions

### Public Functions
1. **`add-property(property-details)`**
   - Registers a new property with valid details (contract owner only).
2. **`transfer-property(property-id, recipient)`**
   - Transfers ownership of a property to a specified recipient.
3. **`list-property(property-id)`**
   - Marks a property as listed for sale.
4. **`set-property-category(property-id, category)`**
   - Assigns a category to a property.

### Read-Only Functions
1. **`get-property-owner(property-id)`**
   - Retrieves the owner's principal address.
2. **`get-property-data(property-id)`**
   - Retrieves property details.
3. **`is-property-registered(property-id)`**
   - Checks if the property is registered.
4. **`get-last-property-id()`**
   - Retrieves the last assigned property ID.

---

## Example Use Cases

1. **Property Registration**
   - Owners can tokenize real-world properties by registering them as NFTs with unique details.
2. **Ownership Transfers**
   - Enables secure and transparent transfer of property ownership.
3. **Property Marketplace**
   - Owners can list properties for sale or lease and manage their statuses seamlessly.

---

## Security Considerations

- **Ownership Validation**  
  Only property owners can perform sensitive actions like transfers or updates.
- **Immutable Records**  
  Property history is stored immutably on-chain, ensuring accountability.
- **Error Handling**  
  Comprehensive error codes help users and developers identify and resolve issues.

---

## Future Improvements

- Integration with external oracles for property valuation.
- Enhanced search and filtering capabilities for properties.
- Support for fractional ownership and leasing models.

---

## License

This contract is released under the [MIT License](LICENSE), allowing for modification and redistribution with proper attribution.

---

## Contact

For questions or contributions, please contact the author or submit an issue in the repository.

---
```