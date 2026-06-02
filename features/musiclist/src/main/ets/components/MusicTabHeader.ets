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
import { BreakpointType } from 'mediacommon';

/**
 * Tab页签类型
 */
export enum MusicTabType {
  RECENT_PLAY = 0,  // 最近播放
  PLAYLIST = 1      // 歌单列表
}

/**
 * 音乐列表Tab切换组件
 */
@Component
export struct MusicTabHeader {
  @Link currentTab: MusicTabType;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  
  build() {
    Row() {
      // 最近播放 Tab
      Column() {
        Text('最近播放')
          .fontSize(new BreakpointType({
            sm: 16,
            md: 18,
            lg: 20
          }).getValue(this.currentBreakpoint))
          .fontWeight(this.currentTab === MusicTabType.RECENT_PLAY ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === MusicTabType.RECENT_PLAY ? 
            $r('app.color.button_background_color') : Color.Black)
      }
      .layoutWeight(1)
      .height(StyleConstants.FULL_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.currentTab = MusicTabType.RECENT_PLAY;
      })
      
      // 分隔线
      Divider()
        .vertical(true)
        .height(20)
        .color('#E0E0E0')
      
      // 歌单列表 Tab
      Column() {
        Text('我的歌单')
          .fontSize(new BreakpointType({
            sm: 16,
            md: 18,
            lg: 20
          }).getValue(this.currentBreakpoint))
          .fontWeight(this.currentTab === MusicTabType.PLAYLIST ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === MusicTabType.PLAYLIST ? 
            $r('app.color.button_background_color') : Color.Black)
      }
      .layoutWeight(1)
      .height(StyleConstants.FULL_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.currentTab = MusicTabType.PLAYLIST;
      })
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(48)
    .backgroundColor(Color.White)
  }
}
