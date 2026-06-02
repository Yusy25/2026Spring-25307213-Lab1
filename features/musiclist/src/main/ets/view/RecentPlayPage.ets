/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BreakpointConstants, StyleConstants } from 'constantscommon';
import { RecentPlayManager, SongItem } from 'mediacommon';
import { RecentPlayComponent } from '../components/RecentPlayComponent';

/**
 * 最近播放页面
 * 显示完整的最近播放记录列表
 */
@Component
export struct RecentPlayPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('pageIndexInfos') pageIndexInfos: NavPathStack = new NavPathStack();
  @StorageLink('recentPlayRecords') recentPlays: SongItem[] = [];
  
  private recentPlayManager: RecentPlayManager = RecentPlayManager.getInstance();
  
  // 是否显示清除确认对话框
  @State showClearDialog: boolean = false;

  aboutToAppear() {
    this.loadRecentPlays();
  }

  private async loadRecentPlays() {
    await this.recentPlayManager.initialize();
    this.recentPlays = this.recentPlayManager.getRecentPlays();
    AppStorage.setOrCreate('recentPlayRecords', this.recentPlays);
  }

  /**
   * 清除所有播放记录
   */
  private async clearAllRecords() {
    await this.recentPlayManager.clearAll();
    this.recentPlays = [];
    this.showClearDialog = false;
  }

  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          // 返回按钮
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.pageIndexInfos.pop();
            })

          Text('最近播放')
            .fontColor(Color.Black)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
            .layoutWeight(1)

          // 清除按钮
          if (this.recentPlays.length > 0) {
            Text('清空')
              .fontColor($r('app.color.button_background_color'))
              .fontSize(14)
              .onClick(() => {
                this.showClearDialog = true;
              })
          }
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(56)
        .padding({
          left: 16,
          right: 16
        })
        .backgroundColor(Color.White)

        // 最近播放列表
        RecentPlayComponent({ 
          currentBreakpoint: this.currentBreakpoint,
          showHeader: false 
        })
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(StyleConstants.FULL_HEIGHT)
      .backgroundColor('#F5F5F5')

      // 清除确认对话框
      if (this.showClearDialog) {
        Column() {
          Column() {
            Text('确认清空')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            Text('确定要清空所有播放记录吗？')
              .fontSize(16)
              .fontColor(Color.Gray)
              .margin({ bottom: 24 })

            Row() {
              Button('取消')
                .width('45%')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .onClick(() => {
                  this.showClearDialog = false;
                })

              Blank()

              Button('确定')
                .width('45%')
                .onClick(() => {
                  this.clearAllRecords();
                })
            }
            .width('100%')
          }
          .width('80%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.showClearDialog = false;
        })
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
  }
}
