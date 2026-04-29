import { BackgroundTaskService } from '../services/BackgroundTaskService';
import { common } from '@kit.AbilityKit';
import { HistoryPage } from './HistoryPage';
import { DashboardPage } from './DashboardPage';

@Entry
@Component
struct MainPage {
  @State isTracking: boolean = false;
  @StorageLink('liveStartTime') liveStartTime: number = 0;
  @StorageLink('liveDistance') liveDistance: number = 0;
  @StorageLink('livePoints') livePoints: number = 0;
  @State durationStr: string = '00:00:00';
  private context: common.Context = AppStorage.get('context')!;
  private timer: number = -1;

  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === 'HistoryPage') {
      HistoryPage()
    } else if (name === 'DashboardPage') {
      DashboardPage()
    }
  }

  updateDuration() {
    if (this.liveStartTime > 0) {
      const now = Date.now();
      const diff = Math.floor((now - this.liveStartTime) / 1000);
      const h = Math.floor(diff / 3600).toString().padStart(2, '0');
      const m = Math.floor((diff % 3600) / 60).toString().padStart(2, '0');
      const s = (diff % 60).toString().padStart(2, '0');
      this.durationStr = `${h}:${m}:${s}`;
    } else {
      this.durationStr = '00:00:00';
    }
  }

  onPageShow() {
    this.timer = setInterval(() => {
      this.updateDuration();
    }, 1000);
  }

  onPageHide() {
    clearInterval(this.timer);
  }

  build() {
    Navigation(this.pageStack) {
      Column({ space: 8 }) {
        Text('Move Tracker')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        if (this.isTracking) {
          Column({ space: 2 }) {
            Text(this.durationStr)
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
            Text(`${(this.liveDistance / 1000).toFixed(2)} km`)
              .fontSize(14)
              .opacity(0.8)
            Text(`${this.livePoints} points collected`)
              .fontSize(10)
              .opacity(0.6)
          }
          .margin({ top: 10, bottom: 10 })
        } else {
          Text('Ready to start')
            .fontSize(14)
            .opacity(0.8)
            .margin({ top: 20, bottom: 20 })
        }

        Button(this.isTracking ? 'Stop Tracking' : 'Start Tracking')
          .onClick(async () => {
            if (this.isTracking) {
              await BackgroundTaskService.stop(this.context);
              this.isTracking = false;
            } else {
              await BackgroundTaskService.start(this.context);
              this.isTracking = true;
            }
          })
          .fontSize(14)
          .borderRadius(12)
          .backgroundColor('#ff353535')
          .width('76%')
          .height(32)

        Row({ space: 12 }) {
          Button('History')
            .onClick(() => {
              this.pageStack.pushPathByName('HistoryPage', null)
            })
            .fontSize(12)
            .borderRadius(16)
            .backgroundColor('#ff353535')
            .width('45%')
            .height(32)
          Button('Dashboard')
            .onClick(() => {
              this.pageStack.pushPathByName('DashboardPage', null)
            })
            .fontSize(12)
            .borderRadius(16)
            .backgroundColor('#ff353535')
            .width('45%')
            .height(32)
        }
        .margin({ top: 8 })
      }
      .padding(16)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .borderRadius('50%')
      .backgroundColor(Color.White)
      .clip(true)
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}
