import {
  Pivot,
  Rotation,
  Scale,
  Translation,
  matrix4,
  curves
} from '@kit.ArkUI';

@AnimatableExtend(Rect)
function needleAngle(angle: number): void {
  .rotate({
    x: 0,
    y: 0,
    z: 1,
    angle: angle,
    centerX: '50%',
    centerY: '100%'
  })
}

@AnimatableExtend(Progress)
function ringProgress(value: number): void {
  .value(value)
}

const WATCH_PIVOT: Pivot = { x: 0.5, y: 1.0 };
const Z_AXIS: Rotation = { x: 0, y: 0, z: 1 };

@Entry
@Component
struct Index {
  @State hourAngle: number = 214;
  @State minuteAngle: number = 42;
  @State ringValue: number = 76;
  @State heartScale: number = 1;
  @State notificationOffset: number = 0;
  @State selectedScreen: number = 0;
  @State showDetail: boolean = false;
  @State status: string = 'Tap dial';

  private readonly screenNames: Array<string> = ['Face', 'Alerts'];

  private get pulseScale(): Scale {
    return { x: this.heartScale, y: this.heartScale };
  }

  private get cardTranslation(): Translation {
    return { x: this.notificationOffset, y: 0 };
  }

  private get watchTransform() {
    return matrix4.identity()
      .translate({ x: 0, y: 1 })
      .scale({ x: 0.98, y: 0.98 })
      .rotate({ x: Z_AXIS.x, y: Z_AXIS.y, z: Z_AXIS.z, angle: 0.4 });
  }

  aboutToAppear(): void {
    this.startHeartbeat();
  }

  aboutToDisappear(): void {
    // No timer is used. The heartbeat is triggered by the watch-face tap so
    // the demo remains inexpensive on a small wearable device.
  }

  private startHeartbeat(): void {
    this.getUIContext().animateTo({ duration: 720, curve: Curve.EaseInOut }, () => {
      this.heartScale = 1.14;
    });
    setTimeout(() => {
      this.getUIContext().animateTo({ duration: 720, curve: Curve.EaseInOut }, () => {
        this.heartScale = 1;
      });
    }, 720);
  }

  private animateClock(): void {
    this.getUIContext().animateTo({ duration: 900, curve: Curve.EaseInOut }, () => {
      this.hourAngle = this.hourAngle >= 350 ? 214 : this.hourAngle + 24;
      this.minuteAngle = this.minuteAngle >= 330 ? 42 : this.minuteAngle + 96;
      this.ringValue = this.ringValue >= 94 ? 68 : this.ringValue + 6;
    });
    this.status = 'Interpolating';
    this.startHeartbeat();
  }

  private showNotifications(): void {
    this.selectedScreen = 1;
    this.getUIContext().animateTo({ duration: 520, curve: Curve.EaseOut }, () => {
      this.notificationOffset = 0;
    });
    this.status = 'Cards sliding';
  }

  private selectScreen(index: number): void {
    if (this.selectedScreen === index) {
      return;
    }
    this.selectedScreen = index;
    this.notificationOffset = index === 1 ? 28 : -28;
    this.getUIContext().animateTo({ duration: 480, curve: Curve.EaseInOut }, () => {
      this.notificationOffset = 0;
    });
    this.status = index === 0 ? 'Face restored' : 'Cards sliding';
  }

  private toggleDetail(): void {
    this.showDetail = true;
    this.status = 'Modal Transition: complication detail';
  }

  @Builder
  ScreenTab(label: string, index: number): void {
    Text(label)
      .fontSize(9)
      .fontWeight(this.selectedScreen === index ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.selectedScreen === index ? '#07111E' : '#AAB8C8')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(26)
      .backgroundColor(this.selectedScreen === index ? '#8CE6D0' : '#202733')
      .borderRadius(13)
      .onClick(() => this.selectScreen(index));
  }

  @Builder
  DialMarks(): void {
    ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], (mark: number) => {
      Text(mark === 0 ? '12' : `${mark}`)
        .width(16)
        .height(14)
        .fontSize(mark % 3 === 0 ? 8 : 7)
        .fontWeight(FontWeight.Bold)
        .fontColor(mark % 3 === 0 ? '#E7F8F1' : '#7A8798')
        .textAlign(TextAlign.Center)
        .position({
          x: 65 + Math.sin(mark * Math.PI / 6) * 49,
          y: 66 - Math.cos(mark * Math.PI / 6) * 49
        });
    }, (mark: number) => `${mark}`);
  }

  @Builder
  WatchFace(): void {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(142)
        .height(142)
        .fill('#101923')
        .stroke('#30485B')
        .strokeWidth(2)

      Circle()
        .width(128)
        .height(128)
        .fill('#0B1119')
        .stroke('#1E3545')
        .strokeWidth(1)

      this.DialMarks();

      // Pivot is expressed as a normalized point. The equivalent percentage
      // anchor is used by rotate because the component modifier accepts
      // centerX/centerY values.
      Rect()
        .width(3)
        .height(38)
        .fill('#8CE6D0')
        .position({ x: 71, y: 35 })
        .needleAngle(this.hourAngle)

      Rect()
        .width(2)
        .height(50)
        .fill('#F7C873')
        .position({ x: 72, y: 23 })
        .needleAngle(this.minuteAngle)

      Circle()
        .width(7)
        .height(7)
        .fill('#F7C873')
        .scale(this.pulseScale)

      Text('06:42')
        .width(70)
        .height(20)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F5F7FA')
        .textAlign(TextAlign.Center)
        .position({ x: 38, y: 63 })
        .transform(this.watchTransform)
    }
    .width(146)
    .height(146)
    .onClick(() => this.animateClock());
  }

  @Builder
  Complication(label: string, value: string, color: string): void {
    Column({ space: 2 }) {
      Text(label).fontSize(7).fontColor('#8D9BAD')
      Text(value).fontSize(11).fontWeight(FontWeight.Bold).fontColor(color)
    }
    .width('31%')
    .height(32)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#17212C')
    .borderRadius(12)
    .onClick(() => this.toggleDetail());
  }

  @Builder
  FaceScreen(): void {
    Column({ space: 4 }) {
      this.WatchFace();
      Row({ space: 5 }) {
        this.Complication('HEART', '82', '#FF829C');
        this.Complication('MOVE', '76%', '#8CE6D0');
        this.Complication('TEMP', '21°', '#F7C873');
      }
      .width('100%');

      Row({ space: 6 }) {
        Progress({ value: this.ringValue, total: 100, type: ProgressType.Ring })
          .width(24)
          .height(24)
          .color('#8CE6D0')
          .backgroundColor('#263440')
          .ringProgress(this.ringValue);
        Text(`Activity ${this.ringValue}%`)
          .fontSize(7)
          .fontColor('#AAB8C8');
      }
      .height(24)
      .justifyContent(FlexAlign.Center);

      Text('Tap dial · rotate hands · pulse heart')
        .fontSize(7)
        .fontColor('#8493A4')
        .maxLines(1);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.translate({ x: 160, y: 0 }),
      TransitionEffect.translate({ x: -160, y: 0 })
    ));
  }

  @Builder
  NotificationCard(title: string, subtitle: string, accent: string, index: number): void {
    Row({ space: 8 }) {
      Circle().width(24).height(24).fill(accent).scale({ x: 0.88, y: 0.88 });
      Column({ space: 2 }) {
        Text(title).fontSize(9).fontWeight(FontWeight.Bold).fontColor('#F5F7FA');
        Text(subtitle).fontSize(7).fontColor('#9AA8B7').maxLines(1);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
      Text(index === 0 ? 'Now' : '12m')
        .fontSize(7)
        .fontColor('#8CE6D0');
    }
    .width('100%')
    .height(46)
    .padding({ left: 10, right: 10 })
    .backgroundColor('#17212C')
    .borderRadius(14)
    .translate(this.cardTranslation)
    .transition(TransitionEffect.translate({ x: 110, y: 0 }));
  }

  @Builder
  AlertsScreen(): void {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text('NOTIFICATIONS').fontSize(10).fontWeight(FontWeight.Bold).fontColor('#F5F7FA');
        Text('2').fontSize(8).fontColor('#07111E').backgroundColor('#F7C873').borderRadius(8).padding(3);
      }
      .width('100%');
      this.NotificationCard('Focus timer', 'Your 25 minute focus block is complete.', '#8CE6D0', 0);
      this.NotificationCard('Weather', 'Clear skies · 21 degrees · Istanbul', '#F7C873', 1);
      Text('Horizontal + vertical translation on cards')
        .fontSize(7)
        .fontColor('#8493A4')
        .maxLines(1);
    }
    .width('100%')
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.translate({ x: 160, y: 0 }),
      TransitionEffect.translate({ x: -160, y: 0 })
    ));
  }

  @Builder
  DetailOverlay(): void {
    Column({ space: 10 }) {
      Text('COMPLICATION DETAIL').fontSize(10).fontWeight(FontWeight.Bold).fontColor('#F5F7FA');
      Circle()
        .width(80)
        .height(80)
        .fill('#1B3A3D')
        .stroke('#8CE6D0')
        .strokeWidth(4)
        .scale({ x: this.heartScale, y: this.heartScale });
      Text('82 BPM').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FF829C');
      Text('The overlay uses bindContentCover with ModalTransition.DEFAULT.\nThe content itself slides from below with TransitionEffect.')
        .fontSize(8)
        .fontColor('#AAB8C8')
        .textAlign(TextAlign.Center)
        .maxLines(4)
        .width('84%');
      Text('Close').fontSize(9).fontColor('#07111E').backgroundColor('#8CE6D0').borderRadius(14).padding({ left: 22, right: 22, top: 7, bottom: 7 })
        .onClick(() => { this.showDetail = false; });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#0B1119')
    .transition(TransitionEffect.translate({ x: 0, y: 260 }).animation({ curve: curves.springMotion(0.6, 0.8) }));
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 6 }) {
          Column({ space: 1 }) {
            Text('TRANSFORM LAB')
              .width('100%')
              .fontSize(6)
              .fontColor('#8CE6D0')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .maxLines(1);
            Text('Animatable\nwatch face')
              .width('100%')
              .fontSize(10)
              .fontColor('#F5F7FA')
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .maxLines(2);
          }
          .width('64%')
          .alignItems(HorizontalAlign.Center);

          Row({ space: 5 }) {
            this.ScreenTab(this.screenNames[0], 0);
            this.ScreenTab(this.screenNames[1], 1);
          }
          .width('76%');

          Text(this.status)
            .fontSize(6)
            .fontColor('#8493A4')
            .maxLines(1)
            .textAlign(TextAlign.Center)
            .width('60%');

          if (this.selectedScreen === 0) {
            this.FaceScreen();
          } else {
            this.AlertsScreen();
          }

          Button('Open complication detail')
            .width('72%')
            .height(24)
            .fontSize(8)
            .fontColor('#07111E')
            .backgroundColor('#F7C873')
            .borderRadius(12)
            .onClick(() => this.toggleDetail());
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 24, bottom: 10 });
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#070B10')
    .alignItems(HorizontalAlign.Center)
    .bindContentCover(this.showDetail, this.DetailOverlay(), {
      modalTransition: ModalTransition.DEFAULT,
      backgroundColor: '#070B10',
      onDisappear: () => {
        this.showDetail = false;
      }
    });
  }
}