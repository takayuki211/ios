//
//  ViewController.m
//  ble_test
//
//  Created by Takayuki on 2015/09/27.
//  Copyright (c) 2015年 Takayuki Yamamoto. All rights reserved.
//

#define UUID_BLESERIAL2 @"BD011F22-7D3C-0DB6-E441-55873D44EF40"
#define UUID_WRITE	@"0503b819-c75b-ba9b-3641-6a7f338dd9bd" // BLESerialから見て受信：iPhone->BLESerial
#define UUID_READ @"2a750d7d-bd9a-928f-b744-7d5a70cef1f9" // BLESerialから見て送信：iPhone<-BLESerial

#import "ViewController.h"

@import CoreBluetooth;

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *txcharacteristic;
@property (nonatomic, strong) CBCharacteristic *rxcharacteristic;
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
    if([self.centralManager state] == CBCentralManagerStatePoweredOn)
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
    
    // キャラクタリスティックを確保する
    for(CBCharacteristic *characteristic in characteristics){
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_READ]]){
            self.txcharacteristic = characteristic;
            NSLog(@"READ Characteristic TX");
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_WRITE]]){
            self.rxcharacteristic = characteristic;
            NSLog(@"WRITE Characteristic RX");
            
            //            // 書き込む（iPhone >> BLESerial2）
            //            NSUInteger num = 1;
            //            NSData *data = [NSData dataWithBytes:&num length:sizeof(num)];
            //            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}


#pragma mark Responce Data Read/Write

// キャラクタリステイックからデータを読み出した時に呼ばれる
-(void) peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error) {
        NSLog(@"Error reading characteristic value: %@",[error localizedDescription]);
    }
    else{
        NSLog(@"データ読み出し成功！ service uuid:%@, characteristic uuid:%@, value%@",characteristic.service.UUID, characteristic.UUID, characteristic.value);
    }
}

// キャラクタリステイックにデータを書き込んだ時に呼ばれる
-(void) peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error) {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
    else{
        NSLog(@"データ書き込み成功！");
    }
}

#pragma mark BLE Connection Button Actions

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


#pragma mark Control Button Action
// Wtite 1
- (IBAction)sendHigh:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=1;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"書き込み実行：1");
        }
    }
}

// Weite 0
- (IBAction)sendLow:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=0;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"書き込み実行：0");
        }
    }
}

- (IBAction)forward:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=2;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"Forward");
        }
    }
}

- (IBAction)Back:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=3;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"Back");
        }
    }
}

- (IBAction)Left:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=4;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"Left");
        }
    }
}

- (IBAction)Right:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=5;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"Right");
        }
    }
}

- (IBAction)Stop:(id)sender {
    if (self.peripheral){
        uint8_t	buf[1];
        buf[0]=0;
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (self.rxcharacteristic)	{
            [self.peripheral writeValue:data forCharacteristic:self.rxcharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSLog(@"Stop");
        }
    }
}


- (IBAction)readButton:(id)sender {

}

// 任意データを書き込む
-(void)writeData:(CBPeripheral *)peripheral
  characteristic:(CBCharacteristic *)characteristic
            data:(uint8_t)buf
{
    if (peripheral){
        NSData*	data = [NSData dataWithBytes:&buf length:sizeof(buf)];
        if (characteristic)	{
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

@end
