import { ethers } from "hardhat";

async function main() {
  const BorrowYourCar = await ethers.getContractFactory("BorrowYourCar");
  const borrowYourCar = await BorrowYourCar.deploy();
  await borrowYourCar.deployed();

  const erc20 = await borrowYourCar.my();
  console.log(`BorrowYourCar contract has been deployed successfully in ${borrowYourCar.address}`)
  console.log(`MyERC4907 contract has been deployed successfully in ${erc20}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});