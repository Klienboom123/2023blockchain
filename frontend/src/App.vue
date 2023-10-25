<script>import Addresses from '../contract-addresses.json';  
import BorrowYourCar from '../BorrowYourCar.sol/BorrowYourCar.json';  
import MyERC4907 from '../MyERC4907.sol/MyERC4907.json';  
import Web3 from 'web3';  
import { ref } from 'vue'; 
export default {  
  data() {  
    return {  
      BorrowYourCarAddress:null,
      BorrowYourCarABI:null,
      myERC4907Address:null,
      myERC4907ABI:null,
  
      // 获取合约实例  
      BorrowYourCarContract:null,
      myERC4907Contract:null,  
      web3:null,
      rentalTime: '',  
      availableCars:null,
      allCars:null,
      userCars: null,
      availableUserCars:null,
      UserRentCar:null,
      info:false,  
      account:"",
      ifaccount:false,
      carOwner:'',
      carBorrower:'',
      haveB:false,
    };  
  },  
  mounted() {  
    this.initializeWeb3();  
  },  
  computed:{
    
  },
  methods: {  
    imageSrc(token){
      return  './src/image/car' +token+ '.png';
    },
      async GetaCar()  {
        if(this.account === '') {
            alert('You have not connected wallet yet.')
            return
        }
      const account = this.account[0];
        if (this.myERC4907Contract&&this.BorrowYourCarContract) {
            try {
                await this.BorrowYourCarContract.methods.GetaCar().send({
                    from: account,
                    gasLimit: 300000 
                    
                })
                console.log('You have got a new car.')
                await this.GetAllCar();
            } catch (error) {
              console.log(error.message)
            }
        } else {
            alert('Contract not exists.')
        }
    },
    async changeConnectWallet(){
        this.account="";
        this.ifaccount=false;
        await this.onClickConnectWallet();

    },
     async onClickConnectWallet()  {
      try {  
        const {ethereum} = window;
        if (!Boolean(ethereum && ethereum.isMetaMask)) {
            alert('MetaMask is not installed!');
            return
        }
            // 如果当前小狐狸不在本地链上，切换Metamask到本地测试链
            if (ethereum.chainId !== '0x539') {
                const chain = {
                    chainId: '0x539', // Chain-ID
                    chainName: "test", // Chain-Name
                    rpcUrls: "HTTP://127.0.0.1:8545", // RPC-URL
                };

                try {
                    // 尝试切换到本地网络
                    await ethereum.request({method: "wallet_switchEthereumChain", params: [{chainId: chain.chainId}]})
                } catch (switchError) {
                    // 如果本地网络没有添加到Metamask中，添加该网络
                    if (switchError.code === 4902) {
                        await ethereum.request({ method: 'wallet_addEthereumChain', params: [chain]
                        });
                    }
                }
            }
        await window.ethereum.request({ method: 'eth_requestAccounts' });  
        this.account=await window.ethereum.request({ method: 'eth_requestAccounts' });  
        this.ifaccount=true;
        await this.GetAllCar();
        this.info=true;
        // 用户已授权访问  
        // 可以执行其他操作，如获取账户余额等  
      } catch (error) {  
        console.log(error.message);
      }  
    },

    async  GetAllCar(){
      const currentTimeStamp = Date.now(); // 当前时间的时间戳（单位：毫秒）  
      const currentTimestampInSeconds = Math.floor(currentTimeStamp / 1000); 
      const account = this.account[0];
        this.allCars = await this.BorrowYourCarContract.methods.GetALLCarList().call({
                    from: account,
                });  
        console.log(this.allCars); 
        this.availableCars = await this.BorrowYourCarContract.methods.GetALLCarListNB(currentTimestampInSeconds).call({
                    from: account,
                });  
        console.log(this.availableCars); 
        this.userCars = await this.BorrowYourCarContract.methods.GetCarList().call({
                    from: account,
                });  
        console.log(this.userCars); 
        this.availableUserCars= await this.BorrowYourCarContract.methods.GetCarListNB(currentTimestampInSeconds).call({
                    from: account,
                }); 
                this.UserRentCar=await this.BorrowYourCarContract.methods.GetRentCarList(currentTimestampInSeconds).call({from:account});
                console.log(this.UserRentCar); 
        console.log(this.availableUserCars); 
        const user= await this.BorrowYourCarContract.methods.GetBorrower(3,currentTimestampInSeconds).call({
                    from: account,
                });
        console.log(user); 
        this.info=true;
      }  ,
     async searchCar(){
      const currentTimeStamp = Date.now(); // 当前时间的时间戳（单位：毫秒）  
      const currentTimestampInSeconds = Math.floor(currentTimeStamp / 1000); 
      const cartoken = document.getElementById("carsearch").value;  
      if(cartoken==='')
      alert(" 请选择要查看的汽车")
      const account = this.account[0];
      this.carOwner= await this.BorrowYourCarContract.methods.GetOwner(cartoken).call({
                    from: account,
                    gasLimit: 300000 
                });
      this.carBorrower= await this.BorrowYourCarContract.methods.GetBorrower(cartoken,currentTimestampInSeconds).call({
                    from: account,
                    gasLimit: 300000 
                })
            if(this.carBorrower!==0x0000000000000000000000000000000000000000)
              this.haveB=true;
      await this.GetAllCar();
     },
    async rentCar() {  
      // 处理租车逻辑，根据选择的租车时间进行操作  
      const currentTimeStamp = Date.now(); // 当前时间的时间戳（单位：毫秒）  
      const currentTimestampInSeconds = Math.floor(currentTimeStamp / 1000); 
      const cartoken = document.getElementById("carrent").value;  
      const duration = document.getElementById("duration").value;  
      if(cartoken===''||duration==='')
      alert(" 请选择要租用的汽车以及租用时间")
      const account = this.account[0];
      const carborrower= await this.BorrowYourCarContract.methods.GetBorrower(cartoken,currentTimestampInSeconds).call({
        from: account,
        gasLimit: 300000
      })
      if(this.availableCars.includes(cartoken.toString())){const out =await this.BorrowYourCarContract.methods.BorrowCar(cartoken,currentTimestampInSeconds,duration).send({
        from: account,
        gasLimit: 300000
      })
        console.log('Renting a car for', this.rentalTime, 'hours');
        console.log(out);
        await this.GetAllCar();}
      else{
        alert("该车不可借用");
      }

    },  
    async initializeWeb3() {  
      // 创建 web3 实例  
      let web3;  
      // 在针对不同浏览器的情况下，选择合适的 provider  
      if (window.ethereum) {  
        web3 = new Web3(window.ethereum);  
      } else if (window.web3) {  
        web3 = new Web3(window.web3.currentProvider);
      } else {  
        console.log('Please install MetaMask to connect to the Ethereum network.');  
        return;  
      }  
      this.BorrowYourCarAddress = Addresses.BorrowYourCar;  
      this.BorrowYourCarABI = BorrowYourCar.abi;  
      this.myERC4907Address = Addresses.MyERC4907;  
      this.myERC4907ABI = MyERC4907.abi;  
  
      // 获取合约实例  
      this.BorrowYourCarContract = new web3.eth.Contract(this.BorrowYourCarABI, this.BorrowYourCarAddress);  
      this.myERC4907Contract = new web3.eth.Contract(this.myERC4907ABI, this.myERC4907Address);  
      // 修改地址为部署的合约地址  
      
  
      // 在这里进行你的合约操作或其他逻辑  
      // 例如：调用合约方法  
    },  
  },  
};   </script>

<template>  
<div style="display: flex;  
  justify-content: center;  
  align-items: center;  
  height: 100vh; ">
  <div class="container">  
    <h1>汽车租用系统</h1>  
     <br>
     <br>
    <h2>租车功能</h2>  
    <span>  
      <label>所租车辆：</label>  
      <input type="number" id="carrent">  
      <label>租车时间(单位为秒)：</label>  
      <input type="number" id="duration">  
      <button @click="rentCar" v-if="ifaccount">借用一辆车</button>  
    </span>  
    <br>
     <br>
    <h2>查询功能</h2>  
    <span>  
      <label>查询车辆：</label>  
      <input type="number" id="carsearch">  
      <button @click="searchCar" >查询一辆车</button> 
    </span>  
    <div>
      <label v-if="carOwner!==''">车辆主人：{{ carOwner }}</label> 
    </div>
    <div>
      <label v-if="haveB">借车人：{{ carBorrower}}</label> 
      <label v-else-if="carOwner!==''">该车未被借出</label>
    </div>
    <br>
     <br>
    <div>  
      <button @click="GetAllCar">刷新当前汽车列表</button>  
    </div>  
    <br>
    <div v-if="ifaccount">  
      <h4>用户：{{account}} 你好！</h4>  
      <button @click="GetaCar">获取一辆车</button>  
      <button @click="changeConnectWallet">切换当前账户</button>  
    </div>  
    <div v-else>  
      <button @click="onClickConnectWallet">连接一个账户</button>  
    </div>  
  
    <div class="content-container">  
      <div v-if="info" class="center1">  
        <h2>当前可租用车辆</h2>  
        <ul>  
          <li v-for="car in availableCars" :key="car.id">{{ car }}
            <img :src="imageSrc(car)" alt="Dynamic Image" style="width: 80px; height: 60px;">  </li>  
        </ul>  
      </div>  
      <div class="center2">  
        <div v-if="ifaccount">  
          <h2>当前用户拥有的车辆</h2>  
          <ul>  
            <li v-for="car in userCars" :key="car.id">{{ car }}
              <img :src="imageSrc(car)" alt="Dynamic Image" style="width: 80px; height: 60px;"> </li>  
          </ul>  
        </div>  
      </div>  
      <div class="right">  
        <div v-if="ifaccount">  
          <h2>当前用户借用的车辆</h2>  
          <ul>  
            <li v-for="car in UserRentCar" :key="car.id">{{ car }}
              <img :src="imageSrc(car)" alt="Dynamic Image" style="width: 80px; height: 60px;"> </li>  
          </ul>  
        </div>  
      </div>  
      <div class="right2">  
        <div v-if="ifaccount">  
          <h2>当前用户拥有且未出借的车辆</h2>  
          <ul>  
            <li v-for="car in availableUserCars" :key="car.id">{{ car }}
              <img :src="imageSrc(car)" alt="Dynamic Image" style="width: 80px; height: 60px;"> </li>  
          </ul>  
        </div>  
      </div>  
    </div>  
  </div>  
</div>
</template>  
<style>
.container {  
  text-align: center;  
  margin: 20px;  
}  
  
h1 {  
  font-size: 24px;  
  color: #333;  
}  
  
h2 {  
  font-size: 18px;  
  color: #666;  
}  
  
  
  
ul {  
  list-style: none;  
  padding: 0;  
}  
  
li {  
  margin-bottom: 10px;  
}  
  
.content-container {  
  display: flex;  
  justify-content: space-between;  
  margin-top: 20px;  
}  
  
.center1,  
.center2,  
.right,  
.right2 {  
  flex-basis: 30%;  
}  

</style>
  