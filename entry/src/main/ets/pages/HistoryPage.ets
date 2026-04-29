import { ActivityRecord, ActivityStore } from '../data/ActivityStore';
import { ArcList, ArcListItem } from '@ohos.arkui.ArcList';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export struct HistoryPage {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Button('Back')
          .onClick(() => {
            this.pageStack.pop()
          })
          .width('45%')
          .height(32)
          .backgroundColor('#ff353535')
          .borderRadius(16)
          .margin({ top: 10, bottom: 5 })

        Text('Activities')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .padding({
            top: 10,
            bottom: 10
          })
        ArcList() {
          ForEach(ActivityStore.getRecords(), (r: ActivityRecord, idx) => {
            ArcListItem() {
              Column({ space: 6 }) {
                Text(`#${ActivityStore.getRecords().length - idx}  -  ${(r.distance / 1000).toFixed(2)} km`)
                  .fontSize(12)
                Text(`Avg: ${(r.avgSpeed * 3.6).toFixed(1)} km/h  |  Pts: ${(r.points.length)}`)
                  .fontSize(8)
                  .opacity(0.7)
                Text(`${new Date(r.startTime).toLocaleString()} - ${r.endTime ? new Date(r.endTime).toLocaleString() : ''} `)
                  .fontSize(8)
                  .opacity(0.7)
              }
              .padding({ top: 10, bottom: 10 })
            }
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .padding(16)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .borderRadius('50%')
      .backgroundColor(Color.White)
      .clip(true)
    }
    .hideTitleBar(true)
  }
}
