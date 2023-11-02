#### BlockChain HW2

- 项目介绍

  - 项目名称：汽车租用Dapp

  - 项目内容：

    该项目创建了一个智能合约，在该合约中发行NFT集合，每个NFT代表一辆车。
  
    该项目构建了一个汽车租用系统，调用部署在本地链上的智能合约的方法来处理相关的逻辑。实现包括获取一辆汽车（NFT），借用一辆汽车，获取当前可租用汽车列表，查询汽车主人以及借用人等功能。
  
    为了测试方便项目有一个汽车的airdrop接口，用户调用这个接口就可以直接获得一辆车。
  
  - 项目功能：
  
    该项目能够连接metamask中的账户，连接部署在本地链上的合约，调用相关逻辑完成以下功能：
  
    - 查看自己拥有的汽车列表。查看当前还没有被借用的汽车列表
    - 查询一辆汽车的主人，以及该汽车当前的借用者
    - 选择并借用某辆未被租用的汽车一段时间
  
  - 实现分析：
  
    NFT的实现
  
    - 要发行一个NFT，需要引用ERC721合约，由ERC721合约派生出MyERC4907进行发行
  
      - 合约变量介绍
  
        ```
         struct UserInfo
         {
             address user;   // address of user role
             uint64 expires; // unix timestamp, user expires
          }
         mapping (uint256  => UserInfo) internal _users;
         uint256  amount;
        ```
  
        UsesrInfo结构存储用户信息；_users存储每个token和用户的对应关系；amount存储当前发行的NFT总量
  
      - 合约关键方法介绍
  
        ```
         function airdrop(address User) public{
                _mint(User,amount);
                amount++;
                UserInfo memory user;
                user.user=User;
                user.expires=1697778000;
                _users[amount-1]=user;
            }
            function getAmount() public view returns(uint256){
                return amount;
            }
        ```
  
        airdrop方法：将该用户地址与token进行保定，增加amount，设置user信息并将user与token绑定；
  
        getAmount方法：获取当前发行的NFT总量
  
    - 接下来就是管理汽车借用系统合约（BorrowYouCar）的设计
  
      - 合约变量介绍
  
        ```
        struct Car {
                address owner;
                address borrower;
                uint256 borrowUntil;
            }
            mapping(uint256 => Car) public cars; 
            MyERC4907 public my=new MyERC4907("CarTokens","CarTokensSymbol");
        ```
  
        Car结构存储用户信息，内容包括该车辆的主人，借用人和借用期限；cars存储每个token和用户的对应关系；my用来引用MyERC4907中的方法
  
      - 合约关键方法介绍
  
        ```
        function GetCarList() view external  returns(uint256[] memory){
                uint16 count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].owner==address(msg.sender))
                    count++;
                }
                uint256[] memory carS=new uint256[](count);
                count=0;
                    for(uint16 i=0;i<my.getAmount();i++)
                    {
                        if(cars[i].owner==address(msg.sender)){
                            carS[count]=i;
                            count++;
                        }
                    }
                return carS;
            }
        ```
  
        GetCarList方法，获取当前用户的拥有的汽车，先遍历一遍cars获取该用户拥有的汽车数量，再设置一个动态数组，将汽车对应的token存在该数组中返回
  
        ```
        function GetALLCarList() view external  returns(uint256[] memory){
                uint256[] memory carS=new uint256[](my.getAmount());
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    carS[i]=i;
                }
                return carS;
            }
        ```
  
        GetALLCarList方法：获取当前发行的所有汽车，直接将cars中存储的token全部返回
  
        ```
         function GetALLCarListNB(uint64 now) view external  returns(uint256[] memory){
                uint16 count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].borrowUntil<now)
                        count++;
                }
                uint256[] memory carS=new uint256[](count);
                count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].borrowUntil<now){
                        carS[count]=i;
                        count++;
                    }
                }
                return carS;
            }
        ```
  
        GetALLCarListNB方法：获取当前发行的还未被借出的汽车，先遍历一遍cars获取数量，再存储值并返回，与GetCarList逻辑相似
  
        ```
        function GetCarListNB(uint64 now) view external returns(uint256[] memory){
                uint16 count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].owner==address(msg.sender)&&cars[i].borrowUntil<now)
                        count++;
                }
                uint256[] memory carS=new uint256[](count);
                count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].owner==address(msg.sender)&&cars[i].borrowUntil<now){
                        carS[count]=i;
                        count++;
                    }
                }
                return carS;
            }
        ```
  
        GetCarListNB方法：获取当前用户拥有的的还未被借出的汽车，先遍历一遍cars获取数量，再存储值并返回，与GetCarList逻辑相似
  
        ```
        function GetRentCarList(uint64 now) view external returns(uint256[] memory){
                uint16 count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].borrower==address(msg.sender)&&cars[i].borrowUntil>now)
                        count++;
                }
                uint256[] memory carS=new uint256[](count);
                count=0;
                for(uint16 i=0;i<my.getAmount();i++)
                {
                    if(cars[i].borrower==address(msg.sender)&&cars[i].borrowUntil>now){
                        carS[count]=i;
                        count++;
                    }
                }
                return carS;
            }
        ```
  
        GetRentCarList方法：获取当前用户借用的汽车，先遍历一遍cars获取数量，再存储值并返回，与GetCarList逻辑相似
  
        ```
        function GetOwner(uint256 CAR) external returns(address){
                if (CAR>=my.getAmount()){
                    return address(0);
                }
                return cars[CAR].owner;
            }
        ```
  
        GetOwner方法：获取某辆汽车的主人的私钥，若该车不存在，则返回0.
  
        ```
        function GetBorrower(uint256 CAR,uint64 now) external returns(address){
                if (CAR>=my.getAmount()){
                    return address(0);
                }
                if(cars[CAR].borrower==address(0)||cars[CAR].borrowUntil<now){
                    return address(0);
                }
                return cars[CAR].borrower;
            }
        ```
  
        GetBorrower方法：获取某辆汽车的借用者公钥
  
        ```
        function BorrowCar(uint256 car, uint64 now,uint64 duration) external returns(bool,string memory){
                if(my.getAmount()<=car)
                    return (false,"there is no such car");
                else if(cars[car].borrowUntil>=now)
                    return (false,"this car has been borrowed");
                else{
                    cars[car].borrowUntil=now+duration;
                    cars[car].borrower=msg.sender;
                    return (true,"borrow successfully");
                }
            }
        ```
  
        BorrowCar方法：借用一辆车至某期限
  
        ```
         function GetaCar() public {
                my.airdrop(msg.sender);
                Car memory car;
                car.owner=msg.sender;
                car.borrower=address(0);
                car.borrowUntil=0;
                cars[my.getAmount()-1]=car;
            }
        ```
  
        GetaCar方法调用MyERC4907中的airdrop方法为当前用户发行一辆车
  
    
  
- 项目运行

  - 环境配置

    - 在电脑中下载ganache，配置本地链

    - 创建一个metamask账户，连接本地链，导入账户

    - 在contracts文件夹下用npm安装hardhat依赖项

      ```
      npm install --save-dev hardhat  
      ```

    - 前端配置

      控制台进入frontend安装依赖项

      ```
      npm install
      ```

  - 运行项目

    - 编译合约

      进入contracts文件夹编译合约

      ```
      npx hardhat compile
      ```

    - 将合约部署和前端配置

      ```
      npx hardhat run --network ganache scripts/deploy.ts 
      ```

      控制台会输出相关合约的地址：

      

      ![image-20231025153122442](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025153122442.png)

      将该地址输入frontend/contract-addresses.json文件中

      并将contracts/artifacts/contracts/BorrowYourCar.sol/BorrowYourCar.json和contracts/artifacts/contracts/MyERC4907/BorrowYourCar.json中的内容

      分别粘贴在frontend/BorrowYourCar.sol/BorrowYourCar.json和frontend/MyERC4907.sol/MyERC4907.json中

    - 运行前端
  
      ```
      npm run dev
      ```

  - 运行过程

    初始界面

    ![image-20231025160749529](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025160749529.png)

    点击连接一个账户

    ![image-20231025161025246](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025161025246.png)

    选择提前导入metamask的本地链上的用户

    连接成功后便可以显示相关的车辆信息（当前用户还未拥有任何汽车）：

    ![image-20231025162025256](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025162025256.png)

    点击获取一辆车，即可连接metamask发送交易

    ![image-20231025162351770](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025162351770.png)

    点击确认，发现所有车辆以及当前用户拥有的车辆有增加

    ![image-20231025162530765](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025162530765.png)

    

    

    连接另一个用户（删除前一个用户，再点击切换当前账户）发现可租用车辆不变，但是当前用户的车辆状态发生变化

    ![image-20231025162959926](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025162959926.png)

    

    

    

    在租车功能下租用3车辆，60秒钟，点击借用一辆车；交易完成后，可以看到：

    ![image-20231025163238112](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025163238112.png)

    

    查询3车的主人和借用人：

    ![image-20231025163310176](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025163310176.png)

    

    ​	

    60秒后，发现借用失效
  
    ![image-20231025163353050](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025163353050.png)

再次借用3车，并回到主人账户，可以看到车辆3已经借用出去了

![image-20231025171957019](https://github.com/Klienboom123/2023blockchain/tree/master/ScreenShot/image-20231025171957019.png)

当我想再次借用车辆3时，显示该车不可借用

