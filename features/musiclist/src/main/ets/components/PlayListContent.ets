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
import { PlayList } from './PlayList';

/**
 * 歌单列表内容页
 * 显示我的收藏和用户自建歌单
 */
@Component
export struct PlayListContent {
  @Link currentBreakpoint: string;
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;

  build() {
    Scroll() {
      Column() {
        // 歌单列表
        PlayList({ currentBreakpoint: this.currentBreakpoint })
      }
      .width(StyleConstants.FULL_WIDTH)
      .padding({
        // 为底部播放栏预留空间
        bottom: 48 + this.getUIContext().px2vp(this.bottomRectHeight) + 8
      })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor('#F5F5F5')
  }
}
