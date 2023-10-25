import Addresses from './contract-addresses.json'
import BorrowYourCar from './BorrowYourCar.sol/BorrowYourCar.json'
import MyERC4907 from './MyERC4907.sol/MyERC4907.json'
import Web3 from 'web3'

let web3 = new Web3(window.web3.currentProvider)

// 修改地址为部署的合约地址
const BorrowYourCarAddress = Addresses.BorrowYourCar
const BorrowYourCarABI = BorrowYourCar.abi
const myERC4907Address = Addresses.MyERC4907
const myERC4907ABI = MyERC4907.abi

// 获取合约实例
const BorrowYourCarContract = new web3.eth.Contract(BorrowYourCarABI, BorrowYourCarAddress);
const myERC4907Contract = new web3.eth.Contract(myERC4907ABI, myERC4907Address);

// 导出web3实例和其它部署的合约
export {web3, BorrowYourCarContract, myERC4907Contract}