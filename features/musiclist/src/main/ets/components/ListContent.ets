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

import { BreakpointConstants, GridConstants, StyleConstants } from 'constantscommon';
import { AlbumCover } from './AlbumCover';
import { MusicTabHeader, MusicTabType } from './MusicTabHeader';
import { RecentPlayContent } from './RecentPlayContent';
import { PlayListContent } from './PlayListContent';

/**
 * 音乐列表主内容组件
 * 左侧：专辑封面
 * 右侧：Tab切换（最近播放 / 歌单列表）
 */
@Component
export struct Content {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;
  @State currentTab: MusicTabType = MusicTabType.RECENT_PLAY;

  build() {
    GridRow({
      breakpoints: {
        value: BreakpointConstants.BREAKPOINT_VALUE,
        reference: BreakpointsReference.WindowSize
      },
      columns: {
        sm: BreakpointConstants.COLUMN_LG,
        md: BreakpointConstants.COLUMN_LG,
        lg: BreakpointConstants.COLUMN_LG
      }
    }) {
      // 左侧：专辑封面
      GridCol({ span: { sm: GridConstants.SPAN_TWELVE, md: GridConstants.SPAN_SIX, lg: GridConstants.SPAN_FOUR } }) {
        AlbumCover({ currentBreakpoint: this.currentBreakpoint })
          .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
      }
      .backgroundColor($r('app.color.album_background'))

      // 右侧：Tab切换内容
      GridCol({ span: { sm: GridConstants.SPAN_TWELVE, md: GridConstants.SPAN_SIX, lg: GridConstants.SPAN_EIGHT } }) {
        Column() {
          // Tab切换头部
          MusicTabHeader({ currentTab: $currentTab })
          
          // 内容区域
          if (this.currentTab === MusicTabType.RECENT_PLAY) {
            // 最近播放
            RecentPlayContent({ currentBreakpoint: $currentBreakpoint })
          } else {
            // 歌单列表
            PlayListContent({ currentBreakpoint: $currentBreakpoint })
          }
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .padding({
          top: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 0 :
            this.getUIContext().px2vp(this.topRectHeight)
        })
      }
      .borderRadius($r('app.float.playlist_border_radius'))
    }
    .height(StyleConstants.FULL_HEIGHT)
  }
}
