import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      forking: {
        url: "https://polygon-mainnet.public.blastapi.io",
      },
    },
  },
  mocha: {
    timeout: 100000000,
  },
};

export default config;
