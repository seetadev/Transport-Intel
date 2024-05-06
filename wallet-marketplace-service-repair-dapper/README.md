# NFT Marketplace with Dapper Wallet

We are using Niftory API to great a walletless experience for payments related to driver license procurement, insurance payment, ride sharing, first aid delivery via ambulance. We are integrating it with Transport Flow NFC payments experience. We are at an early stage of experimentation and learning from the walletless example implementation using Niftory API and extending it for the driver license procurement use-case.

### Config

This app uses [dotenv](https://github.com/motdotla/dotenv) for configuration, so you can set your app's environment variables by creating a `.env` file in this directory.

See [.env.example](./.env.example) for an example of how to configure these environment variables. The only thing you need to configure is:

- `NEXT_PUBLIC_API_KEY`
- `NEXT_PUBLIC_CLIENT_ID`
- `CLIENT_SECRET`

**Follow [this guide](https://docs.niftory.com/home/v/api/getting-started/api-quickstart#get-your-api-keys) to get your Niftory API keys.** Note that your project and contract will also need to be approved by Dapper in order to successfully execute transactions with Dapper Wallet

### Running the app

Once your `.env` file is set up, you can run the app locally with:

```
yarn install
yarn dev
```

## Overview

### Stack:

- Web framework: [Next.js](https://nextjs.org/)
- UI framework: [Chakra UI](https://chakra-ui.com/)
- Auth framework: [NextAuth](https://next-auth.js.org/)
- Graph QL Client: [urql](https://formidable.com/open-source/urql/)
- GraphQL codegen: [graphql-codeg-generator](https://www.graphql-code-generator.com/)

### Wallet Setup

This app demonstrates how to take the user through the wallet setup steps with the [Flow client library](https://docs.onflow.org/fcl/).

See the [WalletSetup component](./lib/components/../../components/wallet/WalletSetup.tsx) to explore how this flow works.

### Dapper Wallet transactions

The advantage of Niftory is that we handle the complex blockchain stuff for you. In that vein, Niftory has implemented all the cadence scripts and transactions needed to handle purchase, minting, listing and transfer using Dapper Wallet.

While you will be using the Niftory APIs to get/sign the transactions, you can view the Cadence code here:

- [Purchase transaction](./public/cadence/buy_from_dapper_with_duc_testnet.cdc) (used to handle everything associated with checkout with Dapper Wallet -- purchase, minting, transfer, etc.)
- [Metadata script](./public/cadence/metadata_script_testnet.cdc) (used to display the item being checked out in the Dapper Wallet pop-up)

### Authentication

This app demonstrates various forms of authentication using the Niftory API.

#### User authentication

This is a pure dApp -- the "user" is just the Dapper Wallet address. We show how to register this wallet with Niftory and configure it to accept NFTs from this app, and use FCL and cookies to manage the session state for this wallet.

#### API-key-only authentication

The browser's [GraphQL client](src/lib/GraphQLClientProvider.tsx) specifies the project's API key as part of the headers of every request.
This allows users to view available NFTs without signing in.

Before purchasing an NFT, the app will prompt the user to set up their wallet.
