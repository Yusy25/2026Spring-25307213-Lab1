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

import { StyleConstants } from 'constantscommon';

/**
 * 沉浸式动态背景组件
 * 根据当前播放歌曲的封面动态显示背景
 */
@Component
export struct DynamicBackground {
  // 当前播放歌曲的封面图（从 AppStorage 获取）
  @StorageLink('currentCover') currentCover: ResourceStr = '';
  // 是否正在播放
  @StorageLink('isPlay') isPlay: boolean = false;
  // 背景透明度（用于动画过渡）
  @State bgOpacity: number = 1;
  // 模糊程度
  @Prop blurRadius: number = 30;
  // 亮度调整（0-1，越小越暗）
  @Prop brightnessValue: number = 0.5;
  // 默认背景图
  private defaultBg: Resource = $r('app.media.background');

  build() {
    Stack() {
      // 背景层
      if (this.currentCover && this.isPlay) {
        // 播放状态：显示歌曲封面模糊背景
        Image(this.currentCover)
          .width(StyleConstants.FULL_WIDTH)
          .height(StyleConstants.FULL_HEIGHT)
          .objectFit(ImageFit.Cover)
          .blur(this.blurRadius)
          .brightness(this.brightnessValue)
          .opacity(this.bgOpacity)
      } else {
        // 未播放状态：显示默认渐变背景
        Column()
          .width(StyleConstants.FULL_WIDTH)
          .height(StyleConstants.FULL_HEIGHT)
          .linearGradient({
            angle: 135,
            colors: [
              ['#1a1a2e', 0.0],
              ['#16213e', 0.5],
              ['#0f3460', 1.0]
            ]
          })
          .opacity(this.bgOpacity)
      }

      // 遮罩层：增强文字可读性
      Column()
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
  }
}

/**
 * 沉浸式页面容器组件
 * 自动包裹动态背景和内容层
 */
@Component
export struct ImmersivePageContainer {
  @BuilderParam content: () => void;
  @StorageLink('currentCover') currentCover: ResourceStr = '';
  @StorageLink('isPlay') isPlay: boolean = false;
  @Prop blurRadius: number = 30;
  @Prop brightnessValue: number = 0.5;

  build() {
    Stack() {
      // 底层：动态背景
      DynamicBackground({
        blurRadius: this.blurRadius,
        brightnessValue: this.brightnessValue
      })

      // 上层：页面内容
      Column() {
        this.content()
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(StyleConstants.FULL_HEIGHT)
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
  }
}
