# Tokenized Equipment Maintenance Contracts

A blockchain-based system for managing industrial equipment maintenance using smart contracts on the Stacks blockchain.

## Overview

This project implements a set of Clarity smart contracts that enable:

1. **Asset Registration**: Record and track industrial equipment as NFTs
2. **Service Agreements**: Define and manage maintenance terms and schedules
3. **Performance Tracking**: Monitor equipment uptime and issues
4. **Payment Automation**: Process payments based on service performance

## Contracts

### Asset Registration Contract

The Asset Registration contract allows equipment owners to:

- Register new industrial equipment with detailed information
- Transfer equipment ownership
- Update equipment location
- Query equipment details

Equipment is represented as non-fungible tokens (NFTs), with each token associated with detailed equipment information.

### Service Agreement Contract

The Service Agreement contract enables:

- Creation of maintenance agreements between equipment owners and service providers
- Scheduling of maintenance based on defined intervals
- Tracking completion of maintenance tasks
- Termination of agreements when necessary

### Performance Tracking Contract

The Performance Tracking contract provides:

- Equipment uptime and downtime monitoring
- Status tracking (operational, maintenance, down)
- Issue reporting and resolution
- Reliability calculation

### Payment Automation Contract

The Payment Automation contract handles:

- Calculation of payment amounts based on performance metrics
- Escrow for service payments
- Payment processing for completed maintenance
- Payment disputes

## How It Works

1. **Equipment Registration**:
    - Equipment owner registers their industrial equipment
    - An NFT is minted to represent the equipment

2. **Service Agreement Creation**:
    - Equipment owner creates a service agreement with a maintenance provider
    - Agreement defines maintenance intervals and payment terms

3. **Maintenance Scheduling**:
    - System automatically schedules maintenance based on defined intervals
    - Service provider completes maintenance and records completion

4. **Performance Tracking**:
    - System tracks equipment status and uptime/downtime
    - Issues are reported and resolved

5. **Payment Processing**:
    - Payment amounts are calculated based on equipment performance
    - Payments are processed from escrow to service provider
    - Disputes can be raised if necessary

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Node.js](https://nodejs.org/) - For running tests

### Installation

1. Clone the repository:
