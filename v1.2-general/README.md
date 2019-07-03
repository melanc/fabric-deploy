# Fabric deploy

## 版本
* fabric 1.2.1

## 组织结构
### 现有4个组织
* orderOrg<<--隶属--order1,2,3
* Org1<<--隶属--peer0.org1
* Org2<<--隶属--peer0.org2
* Org3<<--隶属--peer0.org3

### 需要三个机器：
* 机器1：zookeeper1,kafka1,order1,peer1,couchDB
* 机器2：zookeeper2,kafka2,order2,peer2,couchDB
* 机器3：zookeeper3,kafka3,order3,peer3,couchDB

## 脚本说明
* generateArtifacts.sh:生成msp和通道信息
* get-docker-images.sh:获取命令文件或者下载docker 镜像
* stop.sh:停止该机器的fabric网络并且删除数据
* 其他：参见部署章节

## 配置
### 修改hosts
如果没有使用域名，则要修改hosts
```shell
sudo vim /etc/hosts
# 根据实际情况配置ip
192.168.101.134 peer0.org1.uniledger.com 
192.168.101.135 peer0.org2.uniledger.com
192.168.101.136 peer0.org3.uniledger.com

192.168.101.134 orderer1.uniledger.com
192.168.101.135 orderer2.uniledger.com
192.168.101.136 orderer3.uniledger.com

```

## 修改环境变量配置文件`./env`
```shell
#net
COMPOSE_PROJECT_NAME=peer  

# zookeeper volumes
ZOOKEEPER_HOST_NAME=z1
ZOOKEEPER_ID=1
ZOOKEEPER_VOLUMES=./chainData/zookeeper/z1/ #zookpeer运行数据挂载点（docker-compose）
Z1_ADDR=192.168.101.134 #zookpeer1 ip
Z2_ADDR=192.168.101.135 #zookpeer2 ip
Z3_ADDR=192.168.101.136 #zookpeer3 ip

# kafka
KAFKA_HOST_NAME=k1
KAFKA_BROKER_ID=1
KAFKA_VOLUMES=./chainData/kafka/k1/ #kafka运行数据挂载点（docker-compose）
K1_ADDR=192.168.101.134 #kafka1 ip
K2_ADDR=192.168.101.135 #kafka2 ip
K3_ADDR=192.168.101.136 #kafka3 ip

# orderer
ORDERER_HOST_NAME=orderer1.uniledger.com
ORDERER1_ADDR=192.168.101.134 #order1 ip
ORDERER2_ADDR=192.168.101.135 #order2 ip
ORDERER3_ADDR=192.168.101.136 #order3 ip
ORDERER_DATA=./chainData/orderer/ #order运行数据挂载点（docker-compose）
ORDERER_MSP=./crypto-config/ordererOrganizations/uniledger.com/orderers/orderer1.uniledger.com/msp 
ORDERER_TLS=./crypto-config/ordererOrganizations/uniledger.com/orderers/orderer1.uniledger.com/tls 
ORDERER_BLOCK=./channel-artifacts/genesis.block

# peer
PEER_HOST_NAME=peer0.org1.uniledger.com
PEER_ID=peer0.org1.uniledger.com
PEER_ADDRESS=peer0.org1.uniledger.com:7051
PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.uniledger.com:7051
PEER_GOSSIP_BOOTSTRAP=peer0.org1.uniledger.com:7051
PEER_LOCALMSPID=Org1MSP
PEER_DATA_DIR=./chainData/peer/data/ #peer运行数据挂载点（docker-compose）
PEER_MSP_DIR=./crypto-config/peerOrganizations/org1.uniledger.com/peers/peer0.org1.uniledger.com/msp
PEER_TLS_DIR=./crypto-config/peerOrganizations/org1.uniledger.com/peers/peer0.org1.uniledger.com/tls
PEER0_ORG1_ADDR=192.168.101.134  #peer1 ip
PEER0_ORG2_ADDR=192.168.101.135  #peer2 ip
PEER0_ORG3_ADDR=192.168.101.136  #peer3 ip

```

## 部署

1. 先在三台机器上部署Kafka && zookeeper
   ```shell
    ./kafkaStart.sh <1,2,3># 数据为机器编号，每天机器编号使用部署脚本要一致
    # 如机器二
    ./kafkaStart.sh 2
   ```
2. 部署order
   ```shell
    ./orderStart.sh <1,2,3># 数据为机器编号，每天机器编号使用部署脚本要一致
    # 如机器二
    ./orderStart.sh 2
   ```
3. 部署peer
   ```shell
    ./peerStart.sh 0 <1,2,3> #peer id 和组织编号，与机器编号一致
    # 如peer0.org2
    ./peerStart.sh 0 2
   ```

4. cmdCfg/cli.sh
用于测试操作fabric网络，可以不用修改在peer0.org1.com上使用
   * ORGCODE=n:则操作peer0.org(n).com节点
