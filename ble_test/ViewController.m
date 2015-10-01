//
//  ViewController.m
//  ble_test
//
//  Created by Takayuki on 2015/09/27.
//  Copyright (c) 2015年 Takayuki Yamamoto. All rights reserved.
//

#define UUID_BLESERIAL2 @"BD011F22-7D3C-0DB6-E441-55873D44EF40"

#import "ViewController.h"

@import CoreBluetooth;

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"state:%ld",(long)central.state);
    
    // PoweredOnになったらScanを開始する
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scan開始処理
            break;
        default:
            break;
    }
}


#pragma mark Scan and Connect Peripheral

// BLEデバイスが見つかった時に呼ばれる
-(void) centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"発見したデバイス:%@", peripheral);
    self.peripheral = peripheral;
    
    // 接続開始
    [self.centralManager connectPeripheral:peripheral options:nil];
}

// Peripheralへの接続が失敗すると呼ばれる
-(void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                error:(NSError *)error
{
    NSLog(@"接続失敗");
    [self.centralManager stopScan];
    NSLog(@"Scan停止");
}

#pragma mark Find Services

// Peripheralへの接続が成功すると呼ばれる
-(void) centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"接続成功！");
    
    // スキャンをストップする
    [self.centralManager stopScan];
    NSLog(@"Scan停止");
    
    // サービス探索結果を受け取るためにデリゲートをセット
    peripheral.delegate = self;
    
    // サービス探索開始
    [peripheral discoverServices:nil];
}


#pragma mark Find Characteristics

// サービス発見時に呼ばれる
-(void) peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    NSArray *services = peripheral.services;
    NSLog(@"%lu 個のサービスを発見！:%@", (unsigned long)services.count, services);
    
    // サービスが見つかった時
    for (CBService *service in services) {
        // キャラクタリスティック探索開始
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// キャラクタリスティック発見時に呼ばれる
-(void) peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    NSArray *characteristics = service.characteristics;
    NSLog(@"%lu 個のキャラクタリスティックを発見！%@", (unsigned long)characteristics.count, characteristics);
    
    for(CBCharacteristic *characteristic in characteristics){
        // プロパティがReadのとき読み出し開始
        if(characteristic.properties == CBCharacteristicPropertyRead){
            NSLog(@"test");
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

// キャラクタリステイックからデータの読み出しが行われた時に呼ばれる
-(void) peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    NSLog(@"データ読み出し成功！ service uuid:%@, characteristic uuid:%@, value%@",characteristic.service.UUID, characteristic.UUID, characteristic.value);
}

#pragma mark Buttons

// Scanボタン
- (IBAction)scanButton:(id)sender {
    NSLog(@"Scan開始");
    NSArray *serviceUUIDs = @[[CBUUID UUIDWithString:UUID_BLESERIAL2]];
    [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:nil];
}

// Stopボタン
- (IBAction)stopButton:(id)sender {
    NSLog(@"接続解除");
    [self.centralManager cancelPeripheralConnection:self.peripheral];
}




@end
